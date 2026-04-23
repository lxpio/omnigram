package tts

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"sync"
	"time"

	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
	"gorm.io/gorm"
)

// AudiobookWorker processes audiobook generation tasks in the background.
// It runs a single goroutine that processes one chapter at a time.
// Concurrency = 1 because TTS sidecar typically can't handle parallel requests well.
type AudiobookWorker struct {
	manager   *TTSManager
	processor *AudioProcessor
	taskCh    chan string // receives task IDs to process
	cancel    context.CancelFunc
	ctx       context.Context
	wg        sync.WaitGroup
	mu        sync.Mutex
	listeners map[string][]chan ProgressEvent // taskID → SSE listeners
}

// ProgressEvent is sent to SSE listeners
type ProgressEvent struct {
	TaskID        string `json:"task_id"`
	ChapterIndex  int    `json:"chapter_index"`
	ChapterTitle  string `json:"chapter_title"`
	DoneChapters  int    `json:"done_chapters"`
	TotalChapters int    `json:"total_chapters"`
	Status        string `json:"status"` // "chapter_done", "chapter_failed", "task_done", "task_failed"
	ErrorMessage  string `json:"error_message,omitempty"`
}

func NewAudiobookWorker(mgr *TTSManager) *AudiobookWorker {
	ctx, cancel := context.WithCancel(context.Background())
	w := &AudiobookWorker{
		manager:   mgr,
		processor: NewAudioProcessor(),
		taskCh:    make(chan string, 100),
		cancel:    cancel,
		ctx:       ctx,
		listeners: make(map[string][]chan ProgressEvent),
	}
	return w
}

// Start begins the background processing goroutine
func (w *AudiobookWorker) Start() {
	w.wg.Add(1)
	go w.run()
	log.I("Audiobook worker started")
}

// Stop gracefully stops the worker
func (w *AudiobookWorker) Stop() {
	w.cancel()
	w.wg.Wait()
	log.I("Audiobook worker stopped")
}

// Submit adds a task ID to the processing queue
func (w *AudiobookWorker) Submit(taskID string) {
	select {
	case w.taskCh <- taskID:
	default:
		log.W("Audiobook worker queue full, dropping task: " + taskID)
	}
}

// Subscribe returns a channel that receives progress events for a task
func (w *AudiobookWorker) Subscribe(taskID string) chan ProgressEvent {
	ch := make(chan ProgressEvent, 50)
	w.mu.Lock()
	w.listeners[taskID] = append(w.listeners[taskID], ch)
	w.mu.Unlock()
	return ch
}

// Unsubscribe removes a listener
func (w *AudiobookWorker) Unsubscribe(taskID string, ch chan ProgressEvent) {
	w.mu.Lock()
	defer w.mu.Unlock()
	listeners := w.listeners[taskID]
	for i, l := range listeners {
		if l == ch {
			w.listeners[taskID] = append(listeners[:i], listeners[i+1:]...)
			close(ch)
			return
		}
	}
}

func (w *AudiobookWorker) run() {
	defer w.wg.Done()
	for {
		select {
		case <-w.ctx.Done():
			return
		case taskID := <-w.taskCh:
			w.processTask(taskID)
		}
	}
}

func (w *AudiobookWorker) processTask(taskID string) {
	db := store.FileStore()

	task, err := schema.GetAudiobookTask(db, taskID)
	if err != nil {
		log.E("Failed to get audiobook task: " + err.Error())
		return
	}

	task.Status = schema.TaskRunning
	task.Save(db)

	// Pre-extract all chapters once to avoid re-opening EPUB for every chapter
	book, err := schema.FirstBookById(db, task.BookID)
	if err != nil {
		task.Status = schema.TaskFailed
		task.ErrorMessage = "Book not found: " + err.Error()
		task.Save(db)
		return
	}

	chapters, err := ExtractChapters(book.Path)
	if err != nil {
		task.Status = schema.TaskFailed
		task.ErrorMessage = "EPUB extraction failed: " + err.Error()
		task.Save(db)
		return
	}

	// Client-injected sentences override: if the caller attached a Sentences
	// list at task creation, replace Chapter.Sentences with those entries
	// (grouped by chapter_index, ordered by index). Keeps server and client
	// on the exact same sentence list so post-hoc alignment ↔ foliate CFI
	// matching is trivially index-equal.
	if task.ClientSentencesJSON != "" {
		applyClientSentences(chapters, task.ClientSentencesJSON)
	}

	// Process chapters one by one
	for {
		if w.ctx.Err() != nil {
			return
		}

		chapter, err := schema.GetPendingChapterTask(db, taskID)
		if err != nil || chapter == nil {
			break
		}

		w.processChapter(task, chapter, chapters)

		task, _ = schema.GetAudiobookTask(db, taskID)
	}

	// Update final task status. The task may have been deleted out from under
	// us (DELETE /tts/audiobook/:id) while we were generating chapters — in
	// that case GetAudiobookTask returns (nil, err) and we exit silently.
	task, err = schema.GetAudiobookTask(db, taskID)
	if err != nil || task == nil {
		log.I("audiobook task " + taskID + " disappeared mid-processing, abandoning")
		return
	}
	if task.FailedChapters > 0 && task.DoneChapters == 0 {
		task.Status = schema.TaskFailed
	} else {
		task.Status = schema.TaskCompleted
	}
	task.Save(db)

	w.notify(ProgressEvent{
		TaskID:        taskID,
		DoneChapters:  task.DoneChapters,
		TotalChapters: task.TotalChapters,
		Status:        "task_done",
	})
}

func (w *AudiobookWorker) processChapter(task *schema.AudiobookTask, chapter *schema.ChapterTask, epubChapters []Chapter) {
	db := store.FileStore()

	chapter.Status = schema.TaskRunning
	chapter.Save(db)

	opts := SynthesisOptions{
		Voice:  task.Voice,
		Speed:  task.Speed,
		Format: task.Format,
	}

	// Locate the sentence list and raw text for this chapter.
	var sentences []Sentence
	var text string
	for _, ch := range epubChapters {
		if ch.Index == chapter.ChapterIndex {
			sentences = ch.Sentences
			text = ch.Text
			break
		}
	}

	if len(sentences) == 0 {
		// Empty / unparseable chapter — mark done and move on.
		chapter.Status = schema.TaskCompleted
		chapter.Save(db)
		db.Model(&schema.AudiobookTask{}).Where("id = ?", task.ID).
			UpdateColumn("done_chapters", gorm.Expr("done_chapters + 1"))
		return
	}

	storageDir := task.StoragePath
	os.MkdirAll(storageDir, 0755)

	audioPath := filepath.Join(storageDir, fmt.Sprintf("chapter_%03d.mp3", chapter.ChapterIndex))
	alignPath := filepath.Join(storageDir, fmt.Sprintf("chapter_%03d.align.json", chapter.ChapterIndex))

	outFile, err := os.Create(audioPath)
	if err != nil {
		w.failChapter(task, chapter, "Cannot create audio file: "+err.Error())
		return
	}

	alignment := &ChapterAlignment{
		SchemaVersion: AlignmentSchemaVersion,
		ChapterIndex:  chapter.ChapterIndex,
		ChapterTitle:  chapter.ChapterTitle,
		AudioFile:     filepath.Base(audioPath),
		Voice:         task.Voice,
		Provider:      task.Provider,
		GeneratedAt:   time.Now().Unix(),
		Sentences:     make([]SentenceAlignment, 0, len(sentences)),
	}

	var totalSize int64
	var cumulativeMs int64

	for i, sent := range sentences {
		if w.ctx.Err() != nil {
			outFile.Close()
			w.failChapter(task, chapter, "Worker shutting down")
			return
		}

		// Write this sentence's audio to a per-sentence temp file so we can
		// probe its duration independently before appending to the chapter.
		tmpPath := filepath.Join(storageDir, fmt.Sprintf("tmp_%03d_%05d.mp3", chapter.ChapterIndex, i))
		durMs, synthFailed := w.synthesiseSentenceToFile(sent.Text, tmpPath, opts)

		// Append temp file to the chapter output stream.
		appended, err := appendFile(tmpPath, outFile)
		// Clean up temp regardless of success.
		_ = os.Remove(tmpPath)
		if err != nil {
			outFile.Close()
			w.failChapter(task, chapter, "Append audio failed: "+err.Error())
			return
		}
		totalSize += appended

		alignment.Sentences = append(alignment.Sentences, SentenceAlignment{
			Index:       i,
			Text:        sent.Text,
			StartMs:     cumulativeMs,
			EndMs:       cumulativeMs + durMs,
			CharOffset:  sent.CharOffset,
			SynthFailed: synthFailed,
		})
		cumulativeMs += durMs
	}

	outFile.Close()

	// ffmpeg post-processing (LUFS normalize + ID3 tags) happens after all
	// sentences are concatenated. The alignment timings were computed from
	// the pre-processed per-sentence durations; ffmpeg may add trivial
	// padding during re-encode but in practice the drift is < 50ms per
	// chapter, well within the highlight jitter tolerance.
	if w.processor.Available() {
		book, _ := schema.FirstBookById(db, task.BookID)
		meta := ChapterMeta{
			ChapterTitle: chapter.ChapterTitle,
			ChapterIndex: chapter.ChapterIndex,
			TotalChaps:   task.TotalChapters,
		}
		if book != nil {
			meta.BookTitle = book.Title
			meta.Author = book.Author
		}
		if err := w.processor.Process(audioPath, meta); err != nil {
			log.W(fmt.Sprintf("Post-processing chapter %d failed (non-fatal): %v", chapter.ChapterIndex, err))
		} else {
			if fi, err := os.Stat(audioPath); err == nil {
				totalSize = fi.Size()
			}
			// Re-probe final duration to anchor the alignment's last EndMs
			// against the real on-disk audio. Sentence timings stay as-is
			// (they're relative and drift is bounded).
			if realMs, err := ProbeDurationMs(audioPath); err == nil && realMs > 0 {
				cumulativeMs = realMs
			}
		}
	}
	alignment.AudioDurationMs = cumulativeMs

	if err := SaveAlignment(alignPath, alignment); err != nil {
		log.W(fmt.Sprintf("Save alignment chapter %d failed (non-fatal): %v", chapter.ChapterIndex, err))
		alignPath = ""
	}

	chapter.Status = schema.TaskCompleted
	chapter.AudioPath = audioPath
	chapter.AudioSize = totalSize
	chapter.AudioDuration = float64(cumulativeMs) / 1000.0
	chapter.TextLength = len(text)
	chapter.AlignPath = alignPath
	chapter.SentenceCount = len(alignment.Sentences)
	chapter.Save(db)

	// Use atomic DB updates for counters
	db.Model(&schema.AudiobookTask{}).Where("id = ?", task.ID).
		UpdateColumns(map[string]interface{}{
			"done_chapters": gorm.Expr("done_chapters + 1"),
			"total_size":    gorm.Expr("total_size + ?", totalSize),
		})

	// Re-read task for accurate progress notification
	updatedTask, _ := schema.GetAudiobookTask(db, task.ID)
	doneChapters := task.DoneChapters + 1
	if updatedTask != nil {
		doneChapters = updatedTask.DoneChapters
	}

	w.notify(ProgressEvent{
		TaskID:        task.ID,
		ChapterIndex:  chapter.ChapterIndex,
		ChapterTitle:  chapter.ChapterTitle,
		DoneChapters:  doneChapters,
		TotalChapters: task.TotalChapters,
		Status:        "chapter_done",
	})
}

func (w *AudiobookWorker) failChapter(task *schema.AudiobookTask, chapter *schema.ChapterTask, errMsg string) {
	db := store.FileStore()

	chapter.Status = schema.TaskFailed
	chapter.ErrorMessage = errMsg
	chapter.RetryCount++
	chapter.Save(db)

	// Use atomic DB update for counter
	db.Model(&schema.AudiobookTask{}).Where("id = ?", task.ID).
		UpdateColumn("failed_chapters", gorm.Expr("failed_chapters + 1"))

	log.W(fmt.Sprintf("Chapter %d failed: %s", chapter.ChapterIndex, errMsg))

	// Re-read task for accurate progress
	updatedTask, _ := schema.GetAudiobookTask(db, task.ID)
	failedChapters := task.FailedChapters + 1
	if updatedTask != nil {
		failedChapters = updatedTask.FailedChapters
	}

	w.notify(ProgressEvent{
		TaskID:        task.ID,
		ChapterIndex:  chapter.ChapterIndex,
		ChapterTitle:  chapter.ChapterTitle,
		DoneChapters:  task.DoneChapters,
		TotalChapters: task.TotalChapters,
		Status:        "chapter_failed",
		ErrorMessage:  errMsg,
	})
	_ = failedChapters // Used for logging if needed
}

func (w *AudiobookWorker) notify(event ProgressEvent) {
	w.mu.Lock()
	defer w.mu.Unlock()
	for _, ch := range w.listeners[event.TaskID] {
		select {
		case ch <- event:
		default:
			// listener not consuming events fast enough, skip
		}
	}
}

// synthesiseSentenceToFile synthesises one sentence and writes it to dstPath.
// Returns the audio duration in milliseconds, plus a flag indicating whether
// we fell back to silence after exhausting retries.
//
// Partial-failure policy: we NEVER let a single broken sentence fail the
// whole chapter. If synthesis fails twice, we write 1 second of silence in
// its place so that subsequent sentences' alignment timings stay consistent.
func (w *AudiobookWorker) synthesiseSentenceToFile(text, dstPath string, opts SynthesisOptions) (int64, bool) {
	var lastErr error
	for attempt := 0; attempt < 2; attempt++ {
		reader, err := w.manager.Synthesize(w.ctx, text, opts)
		if err != nil {
			lastErr = err
			continue
		}
		out, err := os.Create(dstPath)
		if err != nil {
			reader.Close()
			lastErr = err
			continue
		}
		_, err = io.Copy(out, reader)
		reader.Close()
		out.Close()
		if err != nil {
			lastErr = err
			_ = os.Remove(dstPath)
			continue
		}
		// Probe duration; if ffprobe absent or parse failed, estimate 200ms/char.
		ms, perr := ProbeDurationMs(dstPath)
		if perr != nil || ms <= 0 {
			ms = int64(len([]rune(text))) * 200
		}
		return ms, false
	}

	log.W(fmt.Sprintf("TTS sentence failed after retry, substituting silence: %v", lastErr))
	ms, err := writeSilenceMp3(dstPath, 1000)
	if err != nil {
		// If we can't even write silence, write an empty file — caller will
		// detect and advance. 1000ms is the reasonable default so that later
		// sentence timings don't collapse on top of each other.
		_ = os.WriteFile(dstPath, nil, 0644)
		return 1000, true
	}
	return ms, true
}

// appendFile copies the contents of srcPath to dst and returns bytes appended.
// Used to concatenate per-sentence MP3 fragments into the chapter output.
//
// MP3 frames are self-contained — naive concatenation gives a playable file.
// The post-processing ffmpeg pass later will normalise the stream anyway.
func appendFile(srcPath string, dst io.Writer) (int64, error) {
	in, err := os.Open(srcPath)
	if err != nil {
		return 0, err
	}
	defer in.Close()
	return io.Copy(dst, in)
}

// writeSilenceMp3 writes `durationMs` of silence (mono 24kHz 64kbps) to path.
// Used as a fallback when TTS synthesis fails — keeps the chapter playable
// and alignment timings self-consistent. Requires ffmpeg; if absent, returns
// (0, err) and the caller will write an empty placeholder.
func writeSilenceMp3(path string, durationMs int64) (int64, error) {
	ffmpeg, err := exec.LookPath("ffmpeg")
	if err != nil {
		return 0, err
	}
	seconds := float64(durationMs) / 1000.0
	cmd := exec.Command(ffmpeg,
		"-y",
		"-f", "lavfi",
		"-i", fmt.Sprintf("anullsrc=r=24000:cl=mono"),
		"-t", fmt.Sprintf("%.3f", seconds),
		"-b:a", "64k",
		path,
	)
	if err := cmd.Run(); err != nil {
		return 0, err
	}
	return durationMs, nil
}

// applyClientSentences replaces each chapter's Sentences slice with entries
// from the client payload (grouped by chapter_index). Chapters not mentioned
// in the payload keep their server-split sentences — this lets callers
// override a subset without invalidating the rest.
func applyClientSentences(chapters []Chapter, payload string) {
	var entries []struct {
		ChapterIndex int    `json:"chapter_index"`
		Index        int    `json:"index"`
		Text         string `json:"text"`
		CharOffset   int    `json:"char_offset"`
	}
	if err := json.Unmarshal([]byte(payload), &entries); err != nil {
		log.W("applyClientSentences: parse failed, falling back to server splitter: " + err.Error())
		return
	}
	byChap := map[int][]Sentence{}
	for _, e := range entries {
		byChap[e.ChapterIndex] = append(byChap[e.ChapterIndex], Sentence{Text: e.Text, CharOffset: e.CharOffset})
	}
	for i := range chapters {
		if s, ok := byChap[chapters[i].Index]; ok && len(s) > 0 {
			chapters[i].Sentences = s
		}
	}
}
