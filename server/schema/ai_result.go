package schema

// AiResult stores AI-generated results for books (summaries, tags, context bar, etc.)
// Serves as server-side source of truth; client sqflite ai_cache mirrors this.
type AiResult struct {
	ID         int64  `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID     int64  `json:"user_id" gorm:"index:idx_ai_result_user_book;not null"`
	BookID     string `json:"book_id" gorm:"index:idx_ai_result_user_book;type:char(24)"`
	ResultType string `json:"result_type" gorm:"uniqueIndex:idx_ai_result_unique,priority:1;type:varchar(50);not null;comment:contextBar,summary,autoTag,glossary,narrative,etc."`
	CacheKey   string `json:"cache_key" gorm:"uniqueIndex:idx_ai_result_unique,priority:2;type:varchar(500);not null;comment:composite key matching client cache"`
	Content    string `json:"content" gorm:"type:text;not null"`
	CTime      int64  `json:"ctime" gorm:"autoCreateTime:milli"`
	UTime      int64  `json:"utime" gorm:"autoUpdateTime:milli"`
}
