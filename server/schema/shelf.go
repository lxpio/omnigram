package schema

type Shelf struct {
	ID          int64  `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID      int64  `json:"user_id" gorm:"index;not null"`
	Name        string `json:"name" gorm:"type:varchar(200);not null"`
	Description string `json:"description,omitempty" gorm:"type:text"`
	CoverURL    string `json:"cover_url,omitempty" gorm:"type:varchar(255)"`
	SortOrder   int    `json:"sort_order" gorm:"default:0"`
	BookCount   int    `json:"book_count" gorm:"-"`
	CTime       int64  `json:"ctime" gorm:"column:ctime;autoCreateTime:milli"`
	UTime       int64  `json:"utime" gorm:"column:utime;autoUpdateTime:milli"`
}

type ShelfBook struct {
	ID        int64  `json:"id" gorm:"primaryKey;autoIncrement"`
	ShelfID   int64  `json:"shelf_id" gorm:"uniqueIndex:idx_shelf_book;not null"`
	BookID    string `json:"book_id" gorm:"uniqueIndex:idx_shelf_book;type:char(24);not null"`
	SortOrder int    `json:"sort_order" gorm:"default:0"`
	CTime     int64  `json:"ctime" gorm:"column:ctime;autoCreateTime:milli"`
}
