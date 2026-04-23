package tts

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
	"github.com/lxpio/omnigram/server/utils"
)

type createAudiobookRequest struct {
	Voice    string  `json:"voice"`
	Speed    float64 `json:"speed"`
	Provider string  `json:"provider"`
	Format   string  `json:"format"`
	Chapters []int   `json:"chapters"`

	// Sentences, when non-empty, overrides the server's built-in sentence
	// splitter. Useful when a client (e.g. Flutter app via foliate-js) has
	// already extracted authoritative sentence boundaries + CFIs and wants
	// the server to synthesize that exact list rather than re-split.
	// Server groups entries by chapter_index and feeds them to the worker.
	Sentences []ClientSentence `json:"sentences,omitempty"`
}

// ClientSentence is one entry of the optional createAudiobookRequest.Sentences
// list — only used by the "client injects sentences" path.
type ClientSentence struct {
	ChapterIndex int    `json:"chapter_index"`
	Index        int    `json:"index"`
	Text         string `json:"text"`
	CharOffset   int    `json:"char_offset,omitempty"`
}

func getUserID(c *gin.Context) string {
	return strconv.FormatInt(c.GetInt64(middleware.XUserIDTag), 10)
}

// createAudiobookHandler creates an audiobook generation task for a book.
func createAudiobookHandler(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := getUserID(c)
	db := store.FileStore()

	var req createAudiobookRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	if req.Voice == "" {
		req.Voice = "af_sky"
	}
	if req.Speed <= 0 {
		req.Speed = 1.0
	}
	if req.Provider == "" {
		req.Provider = "kokoro"
	}
	if req.Format == "" {
		req.Format = "mp3"
	}

	book, err := schema.FirstBookById(db, bookID)
	if err != nil {
		c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("book not found"))
		return
	}
	if book.FileType != schema.EPUB {
		c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage("only EPUB books are supported"))
		return
	}

	// Return existing task if one already exists
	existing, _ := schema.GetAudiobookTaskByBook(db, bookID, userID)
	if existing != nil {
		chapters, _ := schema.GetChapterTasks(db, existing.ID)
		c.JSON(http.StatusOK, utils.SUCCESS.WithData(gin.H{
			"task":     existing,
			"chapters": chapters,
		}))
		return
	}

	epubChapters, err := ExtractChapters(book.Path)
	if err != nil {
		log.E("Failed to extract chapters: " + err.Error())
		c.JSON(http.StatusInternalServerError, utils.ErrInnerServer.WithMessage("failed to extract chapters"))
		return
	}

	// Filter chapters if specific indices requested
	selectedChapters := epubChapters
	if len(req.Chapters) > 0 {
		selectedChapters = make([]Chapter, 0, len(req.Chapters))
		for _, idx := range req.Chapters {
			if idx >= 0 && idx < len(epubChapters) {
				selectedChapters = append(selectedChapters, epubChapters[idx])
			}
		}
	}

	storagePath := filepath.Join(conf.GetConfig().MetaDataPath, "audiobooks", bookID)
	taskID := schema.GenerateID()

	// Serialise client-injected sentences (if any) for the worker to use
	// instead of its own SplitSentences output.
	var clientSentencesJSON string
	if len(req.Sentences) > 0 {
		raw, jerr := json.Marshal(req.Sentences)
		if jerr == nil {
			clientSentencesJSON = string(raw)
		}
	}

	task := &schema.AudiobookTask{
		ID:                  taskID,
		BookID:              bookID,
		UserID:              userID,
		Status:              schema.TaskPending,
		Voice:               req.Voice,
		Speed:               req.Speed,
		Provider:            req.Provider,
		Format:              req.Format,
		TotalChapters:       len(selectedChapters),
		StoragePath:         storagePath,
		ClientSentencesJSON: clientSentencesJSON,
	}
	task.Save(db)

	for _, ch := range selectedChapters {
		ct := &schema.ChapterTask{
			ID:           schema.GenerateID(),
			TaskID:       taskID,
			BookID:       bookID,
			ChapterIndex: ch.Index,
			ChapterTitle: ch.Title,
			ChapterHref:  ch.Href,
			Status:       schema.TaskPending,
			TextLength:   len(ch.Text),
		}
		ct.Save(db)
	}

	worker.Submit(taskID)

	chapterTasks, _ := schema.GetChapterTasks(db, taskID)
	c.JSON(http.StatusOK, utils.SUCCESS.WithData(gin.H{
		"task":     task,
		"chapters": chapterTasks,
	}))
}

// createChapterHandler creates or submits a single chapter for on-demand generation.
func createChapterHandler(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := getUserID(c)
	db := store.FileStore()

	idx, err := strconv.Atoi(c.Param("idx"))
	if err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage("invalid chapter index"))
		return
	}

	book, err := schema.FirstBookById(db, bookID)
	if err != nil {
		c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("book not found"))
		return
	}
	if book.FileType != schema.EPUB {
		c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage("only EPUB books are supported"))
		return
	}

	epubChapters, err := ExtractChapters(book.Path)
	if err != nil {
		c.JSON(http.StatusInternalServerError, utils.ErrInnerServer.WithMessage("failed to extract chapters"))
		return
	}
	if idx < 0 || idx >= len(epubChapters) {
		c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage("chapter index out of range"))
		return
	}

	existing, _ := schema.GetAudiobookTaskByBook(db, bookID, userID)
	if existing != nil {
		chapterTasks, _ := schema.GetChapterTasks(db, existing.ID)
		for _, ct := range chapterTasks {
			if ct.ChapterIndex == idx {
				if ct.Status == schema.TaskCompleted {
					c.JSON(http.StatusOK, utils.SUCCESS.WithData(gin.H{
						"task":    existing,
						"chapter": ct,
					}))
					return
				}
				worker.Submit(existing.ID)
				c.JSON(http.StatusOK, utils.SUCCESS.WithData(gin.H{
					"task":    existing,
					"chapter": ct,
				}))
				return
			}
		}

		// Chapter not yet in task — add it
		ch := epubChapters[idx]
		ct := &schema.ChapterTask{
			ID:           schema.GenerateID(),
			TaskID:       existing.ID,
			BookID:       bookID,
			ChapterIndex: ch.Index,
			ChapterTitle: ch.Title,
			ChapterHref:  ch.Href,
			Status:       schema.TaskPending,
			TextLength:   len(ch.Text),
		}
		ct.Save(db)
		existing.TotalChapters++
		existing.Save(db)

		worker.Submit(existing.ID)
		c.JSON(http.StatusOK, utils.SUCCESS.WithData(gin.H{
			"task":    existing,
			"chapter": ct,
		}))
		return
	}

	// No existing task — create a new one for this single chapter
	var req createAudiobookRequest
	_ = c.ShouldBindJSON(&req)
	if req.Voice == "" {
		req.Voice = "af_sky"
	}
	if req.Speed <= 0 {
		req.Speed = 1.0
	}
	if req.Provider == "" {
		req.Provider = "kokoro"
	}
	if req.Format == "" {
		req.Format = "mp3"
	}

	storagePath := filepath.Join(conf.GetConfig().MetaDataPath, "audiobooks", bookID)
	taskID := schema.GenerateID()

	task := &schema.AudiobookTask{
		ID:            taskID,
		BookID:        bookID,
		UserID:        userID,
		Status:        schema.TaskPending,
		Voice:         req.Voice,
		Speed:         req.Speed,
		Provider:      req.Provider,
		Format:        req.Format,
		TotalChapters: 1,
		StoragePath:   storagePath,
	}
	task.Save(db)

	ch := epubChapters[idx]
	ct := &schema.ChapterTask{
		ID:           schema.GenerateID(),
		TaskID:       taskID,
		BookID:       bookID,
		ChapterIndex: ch.Index,
		ChapterTitle: ch.Title,
		ChapterHref:  ch.Href,
		Status:       schema.TaskPending,
		TextLength:   len(ch.Text),
	}
	ct.Save(db)

	worker.Submit(taskID)
	c.JSON(http.StatusOK, utils.SUCCESS.WithData(gin.H{
		"task":    task,
		"chapter": ct,
	}))
}

// getTaskHandler returns an audiobook task with its chapter list.
func getTaskHandler(c *gin.Context) {
	id := c.Param("id")
	db := store.FileStore()

	task, err := schema.GetAudiobookTask(db, id)
	if err != nil {
		c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("task not found"))
		return
	}

	chapters, _ := schema.GetChapterTasks(db, id)
	c.JSON(http.StatusOK, utils.SUCCESS.WithData(gin.H{
		"task":     task,
		"chapters": chapters,
	}))
}

// streamTaskHandler pushes SSE progress events for a task.
func streamTaskHandler(c *gin.Context) {
	id := c.Param("id")
	db := store.FileStore()

	task, err := schema.GetAudiobookTask(db, id)
	if err != nil {
		c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("task not found"))
		return
	}

	if task.Status == schema.TaskCompleted || task.Status == schema.TaskFailed {
		c.JSON(http.StatusOK, utils.SUCCESS.WithData(gin.H{"task": task}))
		return
	}

	ch := worker.Subscribe(id)
	defer worker.Unsubscribe(id, ch)

	c.Header("Content-Type", "text/event-stream")
	c.Header("Cache-Control", "no-cache")
	c.Header("Connection", "keep-alive")
	c.Status(http.StatusOK)

	ctx := c.Request.Context()
	c.Stream(func(w io.Writer) bool {
		select {
		case <-ctx.Done():
			return false
		case event, ok := <-ch:
			if !ok {
				return false
			}
			data, _ := json.Marshal(event)
			fmt.Fprintf(w, "data: %s\n\n", data)
			c.Writer.Flush()
			return event.Status != "task_done" && event.Status != "task_failed"
		}
	})
}

// getAudiobookHandler returns audiobook info for a book.
func getAudiobookHandler(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := getUserID(c)
	db := store.FileStore()

	task, err := schema.GetAudiobookTaskByBook(db, bookID, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("audiobook not found"))
		return
	}

	chapters, _ := schema.GetChapterTasks(db, task.ID)
	c.JSON(http.StatusOK, utils.SUCCESS.WithData(gin.H{
		"task":     task,
		"chapters": chapters,
	}))
}

// downloadChapterHandler serves a chapter's audio file.
func downloadChapterHandler(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := getUserID(c)
	db := store.FileStore()

	chapterIdx, err := strconv.Atoi(c.Param("chapter"))
	if err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage("invalid chapter index"))
		return
	}

	task, err := schema.GetAudiobookTaskByBook(db, bookID, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("audiobook not found"))
		return
	}

	chapters, _ := schema.GetChapterTasks(db, task.ID)
	for _, ch := range chapters {
		if ch.ChapterIndex == chapterIdx {
			if ch.Status != schema.TaskCompleted || ch.AudioPath == "" {
				c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("chapter audio not ready"))
				return
			}
			if _, err := os.Stat(ch.AudioPath); os.IsNotExist(err) {
				c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("audio file not found"))
				return
			}
			filename := fmt.Sprintf("chapter_%03d.mp3", chapterIdx)
			c.Header("Content-Disposition", fmt.Sprintf(`attachment; filename="%s"`, filename))
			c.File(ch.AudioPath)
			return
		}
	}

	c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("chapter not found"))
}

// deleteAudiobookHandler deletes an audiobook and all its files.
func deleteAudiobookHandler(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := getUserID(c)
	db := store.FileStore()

	task, err := schema.GetAudiobookTaskByBook(db, bookID, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("audiobook not found"))
		return
	}

	if task.StoragePath != "" {
		if err := os.RemoveAll(task.StoragePath); err != nil {
			log.W("Failed to remove audiobook storage: " + err.Error())
		}
	}

	db.Where("task_id = ?", task.ID).Delete(&schema.ChapterTask{})
	db.Where("id = ?", task.ID).Delete(&schema.AudiobookTask{})

	c.JSON(http.StatusOK, utils.SUCCESS.WithData(nil))
}

// getChapterAlignmentHandler streams the chapter_NNN.align.json sidecar
// for client-side sentence→audio-time lookup.
//
// @Summary Get chapter alignment (sentence timings)
// @Description Returns the sentence-level alignment JSON for one chapter,
// containing `sentences: [{index, text, start_ms, end_ms, char_offset}]`.
// Drives karaoke-style sentence highlight in the client audiobook player.
// @Tags TTS
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Param chapter path int true "Chapter index (0-based)"
// @Success 200 {object} ChapterAlignment
// @Failure 404 {object} schema.ErrorResponse
// @Router /tts/audiobook/{book_id}/{chapter}/alignment [get]
func getChapterAlignmentHandler(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := getUserID(c)
	db := store.FileStore()

	chapterIdx, err := strconv.Atoi(c.Param("chapter"))
	if err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage("invalid chapter index"))
		return
	}

	task, err := schema.GetAudiobookTaskByBook(db, bookID, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("audiobook not found"))
		return
	}

	chapters, _ := schema.GetChapterTasks(db, task.ID)
	for _, ch := range chapters {
		if ch.ChapterIndex != chapterIdx {
			continue
		}
		if ch.AlignPath == "" {
			c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("alignment not generated (pre-Sprint7 audiobook)"))
			return
		}
		if _, err := os.Stat(ch.AlignPath); os.IsNotExist(err) {
			c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("alignment file missing"))
			return
		}
		c.File(ch.AlignPath)
		return
	}
	c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("chapter not found"))
}

// getAudiobookIndexHandler returns a book-level manifest suitable for
// bootstrapping the client player: per-chapter file names, durations,
// sentence counts, without pulling the full alignment.
//
// @Summary Get audiobook manifest
// @Description Per-chapter index of a generated audiobook — titles,
// audio/alignment filenames, durations, sentence counts. Use this before
// fetching individual alignment JSON files so the client can show a
// chapter list with accurate durations.
// @Tags TTS
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Success 200 {object} AudiobookIndex
// @Failure 404 {object} schema.ErrorResponse
// @Router /tts/audiobook/{book_id}/index [get]
func getAudiobookIndexHandler(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := getUserID(c)
	db := store.FileStore()

	task, err := schema.GetAudiobookTaskByBook(db, bookID, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, utils.ErrNoFound.WithMessage("audiobook not found"))
		return
	}

	chapters, _ := schema.GetChapterTasks(db, task.ID)
	entries := make([]AudiobookIndexChapter, 0, len(chapters))
	var totalMs int64
	for _, ch := range chapters {
		audioFile := ""
		if ch.AudioPath != "" {
			audioFile = filepath.Base(ch.AudioPath)
		}
		alignFile := ""
		if ch.AlignPath != "" {
			alignFile = filepath.Base(ch.AlignPath)
		}
		durMs := int64(ch.AudioDuration * 1000)
		totalMs += durMs
		entries = append(entries, AudiobookIndexChapter{
			Index:         ch.ChapterIndex,
			Title:         ch.ChapterTitle,
			AudioFile:     audioFile,
			AlignFile:     alignFile,
			DurationMs:    durMs,
			SentenceCount: ch.SentenceCount,
			Status:        int(ch.Status),
		})
	}

	idx := AudiobookIndex{
		SchemaVersion:   AlignmentSchemaVersion,
		BookID:          bookID,
		Voice:           task.Voice,
		Provider:        task.Provider,
		TotalChapters:   task.TotalChapters,
		DoneChapters:    task.DoneChapters,
		TotalDurationMs: totalMs,
		Chapters:        entries,
	}
	c.JSON(http.StatusOK, idx)
}

// AudiobookIndex is the shape returned by GET /tts/audiobook/:id/index.
// It is returned unwrapped (no {code, data} envelope) — clients parse it
// directly as the manifest.
type AudiobookIndex struct {
	SchemaVersion   int                     `json:"schema_version"`
	BookID          string                  `json:"book_id"`
	Voice           string                  `json:"voice"`
	Provider        string                  `json:"provider"`
	TotalChapters   int                     `json:"total_chapters"`
	DoneChapters    int                     `json:"done_chapters"`
	TotalDurationMs int64                   `json:"total_duration_ms"`
	Chapters        []AudiobookIndexChapter `json:"chapters"`
}

// AudiobookIndexChapter is one row in AudiobookIndex.Chapters.
type AudiobookIndexChapter struct {
	Index         int    `json:"index"`
	Title         string `json:"title"`
	AudioFile     string `json:"audio_file,omitempty"`
	AlignFile     string `json:"align_file,omitempty"`
	DurationMs    int64  `json:"duration_ms"`
	SentenceCount int    `json:"sentence_count"`
	Status        int    `json:"status"`
}

// batchAudiobookRequest is the admin-triggered multi-book generation payload.
type batchAudiobookRequest struct {
	BookIDs []string `json:"book_ids" binding:"required"`
	Voice   string   `json:"voice"`
	Speed   float64  `json:"speed"`
}

// BatchAudiobookItem describes one submission in the batch response.
type BatchAudiobookItem struct {
	BookID string `json:"book_id"`
	TaskID string `json:"task_id,omitempty"`
	Status string `json:"status"` // "queued", "exists", "error"
	Error  string `json:"error,omitempty"`
}

// batchAudiobookResponse wraps per-book submission outcomes.
type batchAudiobookResponse struct {
	Submitted int                  `json:"submitted"`
	Items     []BatchAudiobookItem `json:"items"`
}

// batchAudiobookHandler queues audiobook generation for multiple books.
// Admin-only — lets a librarian pre-generate audio for a shelf / tag without
// touching each book individually from the app.
//
// @Summary Batch-generate audiobooks (admin)
// @Description Queue audiobook generation for a list of book IDs using a
// shared voice. Each book that already has a task returns status="exists"
// (no duplicate work). Use this from the web admin to pre-generate audio
// for a curated shelf overnight.
// @Tags TTS
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param body body batchAudiobookRequest true "batch request"
// @Success 200 {object} batchAudiobookResponse
// @Failure 400 {object} schema.ErrorResponse
// @Router /tts/audiobook/batch [post]
func batchAudiobookHandler(c *gin.Context) {
	var req batchAudiobookRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}
	if req.Voice == "" {
		req.Voice = "af_sky"
	}
	if req.Speed <= 0 {
		req.Speed = 1.0
	}

	userID := getUserID(c)
	db := store.FileStore()
	items := make([]BatchAudiobookItem, 0, len(req.BookIDs))
	submitted := 0

	for _, bookID := range req.BookIDs {
		book, err := schema.FirstBookById(db, bookID)
		if err != nil {
			items = append(items, BatchAudiobookItem{BookID: bookID, Status: "error", Error: "book not found"})
			continue
		}
		if book.FileType != schema.EPUB {
			items = append(items, BatchAudiobookItem{BookID: bookID, Status: "error", Error: "only EPUB supported"})
			continue
		}
		if existing, _ := schema.GetAudiobookTaskByBook(db, bookID, userID); existing != nil {
			items = append(items, BatchAudiobookItem{BookID: bookID, TaskID: existing.ID, Status: "exists"})
			continue
		}

		epubChapters, err := ExtractChapters(book.Path)
		if err != nil {
			items = append(items, BatchAudiobookItem{BookID: bookID, Status: "error", Error: "extract failed"})
			continue
		}

		storagePath := filepath.Join(conf.GetConfig().MetaDataPath, "audiobooks", bookID)
		taskID := schema.GenerateID()
		task := &schema.AudiobookTask{
			ID:            taskID,
			BookID:        bookID,
			UserID:        userID,
			Status:        schema.TaskPending,
			Voice:         req.Voice,
			Speed:         req.Speed,
			Provider:      "kokoro",
			Format:        "mp3",
			TotalChapters: len(epubChapters),
			StoragePath:   storagePath,
		}
		task.Save(db)

		for _, ch := range epubChapters {
			ct := &schema.ChapterTask{
				ID:           schema.GenerateID(),
				TaskID:       taskID,
				BookID:       bookID,
				ChapterIndex: ch.Index,
				ChapterTitle: ch.Title,
				ChapterHref:  ch.Href,
				Status:       schema.TaskPending,
				TextLength:   len(ch.Text),
			}
			ct.Save(db)
		}

		worker.Submit(taskID)
		items = append(items, BatchAudiobookItem{BookID: bookID, TaskID: taskID, Status: "queued"})
		submitted++
	}

	c.JSON(http.StatusOK, batchAudiobookResponse{Submitted: submitted, Items: items})
}

// AudiobookQueueItem summarises one active or recent audiobook task.
type AudiobookQueueItem struct {
	TaskID         string  `json:"task_id"`
	BookID         string  `json:"book_id"`
	BookTitle      string  `json:"book_title"`
	Author         string  `json:"author"`
	Voice          string  `json:"voice"`
	Status         int     `json:"status"`
	TotalChapters  int     `json:"total_chapters"`
	DoneChapters   int     `json:"done_chapters"`
	FailedChapters int     `json:"failed_chapters"`
	ProgressPct    float64 `json:"progress_pct"`
	CTime          int64   `json:"ctime"`
	UTime          int64   `json:"utime"`
	ErrorMessage   string  `json:"error_message,omitempty"`
}

// AudiobookQueueResponse is returned by the admin queue GET.
type AudiobookQueueResponse struct {
	Items []AudiobookQueueItem `json:"items"`
}

// audiobookQueueHandler returns the list of recent/active audiobook tasks.
// Admin-only — feeds the web admin page's queue monitor.
//
// @Summary List audiobook generation queue (admin)
// @Description Returns all current and recent audiobook tasks with per-
// book progress. Feeds the admin web UI's queue monitor.
// @Tags TTS
// @Produce json
// @Security BearerAuth
// @Success 200 {object} AudiobookQueueResponse
// @Router /tts/audiobook/queue [get]
func audiobookQueueHandler(c *gin.Context) {
	db := store.FileStore()
	var tasks []schema.AudiobookTask
	if err := db.Order("utime desc").Limit(100).Find(&tasks).Error; err != nil {
		c.JSON(http.StatusOK, AudiobookQueueResponse{})
		return
	}

	items := make([]AudiobookQueueItem, 0, len(tasks))
	for _, t := range tasks {
		book, _ := schema.FirstBookById(db, t.BookID)
		title, author := "", ""
		if book != nil {
			title = book.Title
			author = book.Author
		}
		pct := 0.0
		if t.TotalChapters > 0 {
			pct = float64(t.DoneChapters) * 100.0 / float64(t.TotalChapters)
		}
		items = append(items, AudiobookQueueItem{
			TaskID:         t.ID,
			BookID:         t.BookID,
			BookTitle:      title,
			Author:         author,
			Voice:          t.Voice,
			Status:         int(t.Status),
			TotalChapters:  t.TotalChapters,
			DoneChapters:   t.DoneChapters,
			FailedChapters: t.FailedChapters,
			ProgressPct:    pct,
			CTime:          t.CTime,
			UTime:          t.UTime,
			ErrorMessage:   t.ErrorMessage,
		})
	}
	c.JSON(http.StatusOK, AudiobookQueueResponse{Items: items})
}
