package schema

import (
	"github.com/lxpio/omnigram/server/log"
	"gorm.io/gorm"
)

type FavBook struct {
	ID        int64 `json:"id" gorm:"primary_key,comment:进度ID"`
	BookID    int64 `json:"book_id" gorm:"uniqueIndex:uni_idx_fav_bookid_userid,comment:书籍ID"`
	UserID    int64 `json:"user_id" gorm:"uniqueIndex:uni_idx_fav_bookid_userid,comment:用户ID"`
	CreatedAt int64 `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt int64 `json:"updated_at" gorm:"autoUpdateTime"`
}

// LikedBooks 用户喜欢的书籍列表
func LikedBooks(store *gorm.DB, userID int64, offset, limit int) ([]ProgressBook, error) {

	// books := []Book{}

	progressBook := []ProgressBook{}

	if limit == 0 {
		log.I(`限制为空，调整为默认值10`)
		limit = 10
	}

	sql := `
		SELECT B.*,R.progress,R.progress_index,R.para_position FROM books as B JOIN fav_books AS F ON B.id = F.book_id 
		LEFT JOIN read_progresses AS R ON R.book_id = B.id 
		ORDER BY F.updated_at desc LIMIT ? OFFSET ?;
		`

	err := store.Raw(sql, userID, limit, offset).Scan(&progressBook).Error

	// SELECT * FROM table where count_visit = 0 ORDER BY ctime desc LIMIT 1;
	// err := store.Table(`books`).Where(`id IN ( SELECT book_id FROM read_progresses ORDER BY updated_at desc LIMIT ? )`, limit).Find(&books).Error
	return progressBook, err
	// return BookResp{len(books), books}, err

}
