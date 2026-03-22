package tts

import (
	"context"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sync"

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

	// Update final task status
	task, _ = schema.GetAudiobookTask(db, taskID)
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

	// Find the matching chapter text from pre-extracted chapters
	var text string
	for _, ch := range epubChapters {
		if ch.Index == chapter.ChapterIndex {
			text = ch.Text
			break
		}
	}

	if text == "" {
		// Skip empty chapters
		chapter.Status = schema.TaskCompleted
		chapter.Save(db)
		// Use atomic DB update for counter
		db.Model(&schema.AudiobookTask{}).Where("id = ?", task.ID).
			UpdateColumn("done_chapters", gorm.Expr("done_chapters + 1"))
		return
	}

	chunkOpts := ChunkOptionsForProvider(task.Provider)
	chunks := ChunkText(text, chunkOpts)

	storageDir := task.StoragePath
	os.MkdirAll(storageDir, 0755)

	audioPath := filepath.Join(storageDir, fmt.Sprintf("chapter_%03d.mp3", chapter.ChapterIndex))

	outFile, err := os.Create(audioPath)
	if err != nil {
		w.failChapter(task, chapter, "Cannot create audio file: "+err.Error())
		return
	}
	defer outFile.Close()

	var totalSize int64

	for _, chunk := range chunks {
		if w.ctx.Err() != nil {
			w.failChapter(task, chapter, "Worker shutting down")
			return
		}

		reader, err := w.manager.Synthesize(w.ctx, chunk, opts)
		if err != nil {
			// Retry once
			reader, err = w.manager.Synthesize(w.ctx, chunk, opts)
		}
		if err != nil {
			w.failChapter(task, chapter, "Synthesis failed: "+err.Error())
			return
		}

		n, err := io.Copy(outFile, reader)
		reader.Close()
		if err != nil {
			w.failChapter(task, chapter, "Write audio failed: "+err.Error())
			return
		}
		totalSize += n
	}

	// Close file before post-processing
	outFile.Close()

	// Post-process: LUFS normalization, silence trimming, ID3 tags
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
			// Update totalSize from processed file
			if fi, err := os.Stat(audioPath); err == nil {
				totalSize = fi.Size()
			}
		}
	}

	chapter.Status = schema.TaskCompleted
	chapter.AudioPath = audioPath
	chapter.AudioSize = totalSize
	chapter.TextLength = len(text)
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
