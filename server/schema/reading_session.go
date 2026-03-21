package schema

type ReadingSession struct {
	ID        int64  `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID    int64  `json:"user_id" gorm:"index:idx_session_user;not null"`
	BookID    string `json:"book_id" gorm:"index:idx_session_book;type:char(24);not null"`
	DeviceID  string `json:"device_id,omitempty" gorm:"type:varchar(50)"`
	StartTime int64  `json:"start_time" gorm:"not null"`
	EndTime   int64  `json:"end_time" gorm:"not null"`
	Duration  int64  `json:"duration" gorm:"not null"` // seconds
	PagesRead int    `json:"pages_read" gorm:"default:0"`
}
