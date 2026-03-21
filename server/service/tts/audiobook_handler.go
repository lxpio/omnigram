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

	task := &schema.AudiobookTask{
		ID:            taskID,
		BookID:        bookID,
		UserID:        userID,
		Status:        schema.TaskPending,
		Voice:         req.Voice,
		Speed:         req.Speed,
		Provider:      req.Provider,
		Format:        req.Format,
		TotalChapters: len(selectedChapters),
		StoragePath:   storagePath,
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
