package schema

type AnnotationType string

const (
	AnnotationNote      AnnotationType = "note"
	AnnotationHighlight AnnotationType = "highlight"
	AnnotationBookmark  AnnotationType = "bookmark"
)

type Annotation struct {
	ID           int64          `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID       int64          `json:"user_id" gorm:"index:idx_annotation_user_book;not null"`
	BookID       string         `json:"book_id" gorm:"index:idx_annotation_user_book;type:char(24);not null"`
	DeviceID     string         `json:"device_id,omitempty" gorm:"type:varchar(50)"`
	Chapter      string         `json:"chapter,omitempty" gorm:"type:varchar(200)"`
	Content      string         `json:"content" gorm:"type:text"`
	SelectedText string         `json:"selected_text,omitempty" gorm:"type:text"`
	CFI          string         `json:"cfi,omitempty" gorm:"type:varchar(500)"`
	PageNumber   int            `json:"page_number,omitempty" gorm:"default:0"`
	Position     string         `json:"position,omitempty" gorm:"type:varchar(500)"`
	Color        string         `json:"color,omitempty" gorm:"type:varchar(20)"`
	Type         AnnotationType `json:"type" gorm:"type:varchar(20);not null"`
	CTime        int64          `json:"ctime" gorm:"autoCreateTime:milli"`
	UTime        int64          `json:"utime" gorm:"autoUpdateTime:milli"`
}
