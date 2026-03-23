package schema

// CompanionChat stores companion conversation history.
// Server is source of truth; client sqflite mirrors for offline access.
type CompanionChat struct {
	ID       int64  `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID   int64  `json:"user_id" gorm:"index:idx_companion_chat_user_book;not null"`
	BookID   string `json:"book_id" gorm:"index:idx_companion_chat_user_book;type:char(24);not null"`
	Role     string `json:"role" gorm:"type:varchar(20);not null;comment:user|companion|system"`
	Content  string `json:"content" gorm:"type:text;not null"`
	Chapter  string `json:"chapter,omitempty" gorm:"type:varchar(200)"`
	CFI      string `json:"cfi,omitempty" gorm:"type:varchar(500)"`
	CTime    int64  `json:"ctime" gorm:"autoCreateTime:milli"`
}

// MarginNote stores AI-generated cross-book connections displayed in reading margins.
type MarginNote struct {
	ID               int64   `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID           int64   `json:"user_id" gorm:"index:idx_margin_note_user_book;not null"`
	BookID           string  `json:"book_id" gorm:"index:idx_margin_note_user_book;type:char(24);not null"`
	Chapter          string  `json:"chapter" gorm:"type:varchar(200);not null"`
	CFI              string  `json:"cfi,omitempty" gorm:"type:varchar(500)"`
	Content          string  `json:"content" gorm:"type:text;not null"`
	RelatedBookID    string  `json:"related_book_id,omitempty" gorm:"type:char(24)"`
	RelatedBookTitle string  `json:"related_book_title,omitempty" gorm:"type:varchar(200)"`
	RelatedHighlight string  `json:"related_highlight,omitempty" gorm:"type:text"`
	Confidence       float64 `json:"confidence" gorm:"default:0.5"`
	Dismissed        bool    `json:"dismissed" gorm:"default:false"`
	Helpful          bool    `json:"helpful" gorm:"default:false"`
	CTime            int64   `json:"ctime" gorm:"autoCreateTime:milli"`
	UTime            int64   `json:"utime" gorm:"autoUpdateTime:milli"`
}
