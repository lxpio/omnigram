package schema

import (
	"time"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type TaskStatus int

const (
	TaskPending   TaskStatus = 0
	TaskRunning   TaskStatus = 1
	TaskCompleted TaskStatus = 2
	TaskFailed    TaskStatus = 3
	TaskPaused    TaskStatus = 4
	TaskCancelled TaskStatus = 5
)

// AudiobookTask represents a full audiobook generation job
type AudiobookTask struct {
	ID     string `json:"id" gorm:"type:char(24);primaryKey"`
	BookID string `json:"book_id" gorm:"type:char(24);index;not null"`
	UserID string `json:"user_id" gorm:"type:char(24);index;not null"`

	Status TaskStatus `json:"status" gorm:"type:smallint;default:0;index"`

	Voice    string  `json:"voice" gorm:"type:varchar(100)"`
	Speed    float64 `json:"speed" gorm:"default:1.0"`
	Provider string  `json:"provider" gorm:"type:varchar(50)"`
	Format   string  `json:"format" gorm:"type:varchar(10);default:'mp3'"`

	TotalChapters  int `json:"total_chapters" gorm:"default:0"`
	DoneChapters   int `json:"done_chapters" gorm:"default:0"`
	FailedChapters int `json:"failed_chapters" gorm:"default:0"`

	StoragePath string `json:"storage_path" gorm:"type:varchar(500)"`
	TotalSize   int64  `json:"total_size" gorm:"default:0"`

	// ClientSentencesJSON is the raw JSON of ClientSentence[] passed at task
	// creation when the caller wants to override the server's sentence
	// splitter (e.g. app has foliate-js CFI data). Empty means "use server
	// splitter". Worker parses it per chapter.
	ClientSentencesJSON string `json:"-" gorm:"type:text"`

	ErrorMessage string `json:"error_message,omitempty" gorm:"type:text"`

	CTime int64 `json:"ctime" gorm:"column:ctime;autoCreateTime"`
	UTime int64 `json:"utime" gorm:"column:utime;autoUpdateTime"`
}

// ChapterTask represents a single chapter generation sub-task
type ChapterTask struct {
	ID     string `json:"id" gorm:"type:char(24);primaryKey"`
	TaskID string `json:"task_id" gorm:"type:char(24);index;not null"`
	BookID string `json:"book_id" gorm:"type:char(24);index"`

	ChapterIndex int    `json:"chapter_index" gorm:"not null"`
	ChapterTitle string `json:"chapter_title" gorm:"type:varchar(500)"`
	ChapterHref  string `json:"chapter_href" gorm:"type:varchar(500)"`

	Status TaskStatus `json:"status" gorm:"type:smallint;default:0;index"`

	TextLength    int     `json:"text_length" gorm:"default:0"`
	AudioPath     string  `json:"audio_path" gorm:"type:varchar(500)"`
	AudioSize     int64   `json:"audio_size" gorm:"default:0"`
	AudioDuration float64 `json:"audio_duration" gorm:"default:0"`
	AlignPath     string  `json:"align_path" gorm:"type:varchar(500)"`
	SentenceCount int     `json:"sentence_count" gorm:"default:0"`

	RetryCount   int    `json:"retry_count" gorm:"default:0"`
	ErrorMessage string `json:"error_message,omitempty" gorm:"type:text"`

	CTime int64 `json:"ctime" gorm:"column:ctime;autoCreateTime"`
	UTime int64 `json:"utime" gorm:"column:utime;autoUpdateTime"`
}

// GenerateID generates a 24-char ID using the same pattern as GenBookID.
func GenerateID() string {
	return GenBookID(timeNow())
}

// timeNow is a variable to allow testing; defaults to time.Now.
var timeNow = func() time.Time { return time.Now() }

func (t *AudiobookTask) Save(db *gorm.DB) error {
	return db.Clauses(clause.OnConflict{
		UpdateAll: true,
	}).Create(t).Error
}

func (t *ChapterTask) Save(db *gorm.DB) error {
	return db.Clauses(clause.OnConflict{
		UpdateAll: true,
	}).Create(t).Error
}

func GetAudiobookTask(db *gorm.DB, id string) (*AudiobookTask, error) {
	var task AudiobookTask
	if err := db.Where("id = ?", id).First(&task).Error; err != nil {
		return nil, err
	}
	return &task, nil
}

func GetAudiobookTaskByBook(db *gorm.DB, bookID, userID string) (*AudiobookTask, error) {
	var task AudiobookTask
	if err := db.Where("book_id = ? AND user_id = ?", bookID, userID).First(&task).Error; err != nil {
		return nil, err
	}
	return &task, nil
}

func GetChapterTasks(db *gorm.DB, taskID string) ([]ChapterTask, error) {
	var chapters []ChapterTask
	if err := db.Where("task_id = ?", taskID).Order("chapter_index asc").Find(&chapters).Error; err != nil {
		return nil, err
	}
	return chapters, nil
}

func GetPendingChapterTask(db *gorm.DB, taskID string) (*ChapterTask, error) {
	var chapter ChapterTask
	if err := db.Where("task_id = ? AND status = ?", taskID, TaskPending).
		Order("chapter_index asc").First(&chapter).Error; err != nil {
		return nil, err
	}
	return &chapter, nil
}
