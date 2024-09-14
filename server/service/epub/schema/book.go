package schema

import (
	"bytes"
	"context"
	"crypto/md5"
	"encoding/hex"
	"errors"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/store"
	"github.com/lxpio/omnigram/server/utils"
	"github.com/nexptr/epub"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type Book struct {
	ID    int64     `json:"id" gorm:"primaryKey;comment:ID"`
	Size  int64     `json:"size" gorm:"comment:文件大小"`
	Path  string    `json:"-" gorm:"comment:文件路径"` //本地文件路径不返回到界面上
	CTime time.Time `json:"ctime" form:"ctime" gorm:"column:ctime;autoCreateTime;comment:创建时间"`
	UTime time.Time `json:"utime" gorm:"column:utime;comment:更新时间"`

	Title string `json:"title" gorm:"index:idx_book_title;type:varchar(200);comment:标题"`
	// SubTitle represents the EPUB sub-titles.
	SubTitle   string `json:"sub_title,omitempty" gorm:"type:varchar(255);comment:子标题"`
	Language   string `json:"language" gorm:"type:varchar(50);comment:图书语言"`
	CoverURL   string `json:"cover_url" gorm:"type:varchar(255);comment:封面URL"`
	UUID       string `json:"uuid" gorm:"type:varchar(50);comment:图书UUID"`
	ISBN       string `json:"isbn" gorm:"type:varchar(50);comment:ISBN"`
	ASIN       string `json:"asin" gorm:"type:varchar(50);comment:AWS ID"`
	Identifier string `json:"identifier" gorm:"type:varchar(50);uniqueIndex;comment:唯一ID"`

	Category string `json:"category" gorm:"type:varchar(50);comment:Category"`

	Author     string `json:"author" gorm:"index:idx_book_author;type:varchar(200);comment:作者"`
	AuthorURL  string `json:"author_url" gorm:"type:varchar(255);comment:作者URL"`
	AuthorSort string `json:"author_sort" gorm:"type:varchar(255);comment:作者列表"`
	// Publisher identifies the publication's publisher.
	Publisher   string   `json:"publisher" gorm:"type:varchar(200);comment:用户标签列表"`
	Description string   `json:"description,omitempty" gorm:"type:text;comment:描述信息"`
	Tags        []string `json:"tags" gorm:"-"` //sqlite 没法存储数组
	// Series is the series to which this book belongs to.
	Series string `json:",omitempty" gorm:"type:varchar(200);comment:系列"`
	// SeriesIndex is the position in the series to which the book belongs to.
	SeriesIndex string `json:",omitempty" gorm:"type:varchar(200);comment:用户标签列表"`
	PublishDate string `json:"pubdate" gorm:"type:varchar(50);comment:用户标签列表"`

	Rating float32 `json:"rating" gorm:"comment:用户标签列表"`

	PublisherURL string `json:"publisher_url" gorm:"type:varchar(255);comment:用户标签列表"`

	CountVisit    int64 `json:"count_visit" gorm:"default:0;comment:用户标签列表"`
	CountDownload int64 `json:"count_download" gorm:"default:0;comment:用户标签列表"`

	//解析图片时临时存储封面图片数据
	coverData []byte `json:"-" gorm:"-"`
}

type BookResp struct {
	Total int    `json:"total"`
	Books []Book `json:"books"`
}

type BookStats struct {
	Total     int `json:"total"`
	Author    int `json:"author"`
	Publisher int `json:"publisher"`
	Tag       int `json:"tag"`
}

func GetBookStats(store *gorm.DB) (BookStats, error) {

	stats := BookStats{}
	// SELECT * FROM table ORDER BY RANDOM() LIMIT 1;

	err := store.Raw(`SELECT count(1) as total, COUNT ( DISTINCT author ) AS author, COUNT ( DISTINCT publisher ) AS publisher FROM books`).Scan(&stats).Error

	//todo from tags table

	return stats, err

}

type ProgressBook struct {
	Book
	Progress      float32 `json:"progress"`
	ProgressIndex int     `json:"progress_index,omitempty"`
	ParaPosition  int     `json:"para_position,omitempty"`
}

// ReadingBooks 正在阅读的书籍列表
func ReadingBooks(store *gorm.DB, userID int64, offset, limit int) ([]ProgressBook, error) {

	// books := []Book{}

	progressBook := []ProgressBook{}

	if limit == 0 {
		log.I(`限制为空，调整为默认值10`)
		limit = 10
	}

	sql := `
		SELECT B.*,R.progress,R.progress_index,R.para_position FROM books as B INNER JOIN 
		( SELECT book_id,progress,progress_index,para_position FROM read_progresses as R WHERE user_id = ? ORDER BY updated_at desc LIMIT ? OFFSET ? )
		 AS R
		ON R.book_id = B.id;
		`
	err := store.Raw(sql, userID, limit, offset).Scan(&progressBook).Error

	// SELECT * FROM table where count_visit = 0 ORDER BY ctime desc LIMIT 1;
	// err := store.Table(`books`).Where(`id IN ( SELECT book_id FROM read_progresses ORDER BY updated_at desc LIMIT ? )`, limit).Find(&books).Error
	return progressBook, err
	// return BookResp{len(books), books}, err

}

func CountBook(store *gorm.DB) (int64, error) {
	var count int64
	err := store.Table("books").Count(&count).Error

	return count, err

}

// RecentBooks 最新导入到书籍
func RecentBooks(store *gorm.DB, limit int, omits []int64) (BookResp, error) {

	books := []Book{}

	if limit == 0 {
		log.I(`限制为空，调整为默认值10`)
		limit = 10
	}
	var err error
	if len(omits) > 0 {
		err = store.Table(`books`).Where(`count_visit = ? AND id NOT IN (?)`, 0, omits).Limit(limit).Order(`ctime desc`).Find(&books).Error

	} else {
		err = store.Table(`books`).Where(`count_visit = ? `, 0).Limit(limit).Order(`ctime desc`).Find(&books).Error

	}

	return BookResp{len(books), books}, err

}

func RandomBooks(store *gorm.DB, limit int, omits []int64) (BookResp, error) {

	books := []Book{}

	if limit == 0 {
		log.I(`限制为空，调整为默认值10`)
		limit = 10
	}

	var err error

	if len(omits) > 0 {
		err = store.Table(`books`).Where(`id NOT IN (?)`, omits).Limit(limit).Order(`RANDOM()`).Find(&books).Error

	} else {
		err = store.Table(`books`).Limit(limit).Order(`RANDOM()`).Find(&books).Error

	}

	return BookResp{len(books), books}, err

}

func FirstBookById(store *gorm.DB, id int) (*Book, error) {
	//获取Book信息
	book := &Book{}

	err := store.First(book, `id = ?`, id).Error

	return book, err
}

type Query struct {
	utils.Query
	Category string `json:"category" form:"category"`
	Author   string `json:"author" form:"author"`
	// OrderFields []string    `json:"order_fields" form:"order_fields"`
	// OrderMethod types.ORDER `json:"order_method" form:"order_method"`
}

// SearchBooks 模糊搜索书籍
func SearchBooks(store *gorm.DB, query *Query) (BookResp, error) {

	resp := BookResp{
		0,
		[]Book{},
	}

	tx := store.Model(Book{})

	if query.Search != `` {
		tx.Where(`title LIKE ? OR author LIKE ?`, `%`+query.Search+`%`, `%`+query.Search+`%`)
	}

	if query.Category != `` {
		tx.Where(`category = ?`, query.Category)
	}

	if query.Author != `` {
		tx.Where(`author = ?`, query.Author)
	}

	{
		tx = tx.Session(&gorm.Session{})
		count := int64(0)

		if err := tx.Count(&count).Error; err != nil {
			return resp, err
		}
		resp.Total = int(count)
	}

	err := tx.Limit(int(query.PageSize)).Offset(int(query.PageNum * query.PageSize)).Find(&resp.Books).Error

	return resp, err

}

// Create 存储图书元数据到数据库
func (book *Book) Create(store *gorm.DB) error {

	//存储图书到数据库，如果唯一键 identifier 存在则忽略
	return store.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "identifier"}},
		DoNothing: true,
	}).Create(book).Error

}

func (book *Book) GetCoverData() []byte {
	return book.coverData
}

func (book *Book) IsDuplicate(id string) bool {
	return book.Identifier == id
}

// GetMetadataFromFile reads metadata from an epub file.
func (book *Book) GetMetadataFromFile() error {

	_, err := os.Stat(book.Path)
	if os.IsNotExist(err) {
		// path/to/whatever does not exist
		log.D(`文件不存在`, book.Path, `无法访问或者不存在`)
		return errors.New(`缓存目录无法访问或者不存在`)
	}

	e, err := epub.Open(book.Path)
	if err != nil {
		log.E(`打开文件失败：`, err.Error())
		return err
	}
	defer e.Close()

	opf, err := e.Package()
	if err != nil {
		log.E(`解析文件,`, book.Path, `失败：`, err.Error())
		return err
	}

	book.parseOPF(opf)

	//解析出来封面信息
	if book.CoverURL != `` {

		fp, err := e.OpenItem(book.CoverURL)

		if err != nil {
			log.E(`解析文件,`, book.Path, `失败：`, err.Error())
			return err
		}
		defer fp.Close()

		buf := new(bytes.Buffer)
		buf.ReadFrom(fp)

		book.coverData = buf.Bytes()

		//将 CoverURL 地址覆盖成解析后的地址
		// book.CoverURL = filepath.Join(book.Identifier, book.CoverURL) //TODO 这里要用bookid 获取其他标记避免冲突

	}

	return nil
}

func (m *Book) parseOPF(opf *epub.PackageDocument) {

	mdata := opf.Metadata

	m.Language = elt2FirstStr(mdata.Language)
	m.Tags = elt2str(mdata.Subject)
	m.Description = elt2FirstStr(mdata.Description)
	m.Publisher = elt2FirstStr(mdata.Publisher)

	//TODO get uuid

	hasher := md5.New()
	for _, id := range mdata.Identifier {
		hasher.Write([]byte(id.Value))

		if id.ID == `bookid` {
			m.UUID = strings.TrimPrefix(id.Value, `urn:uuid:`)
			continue
		}

		if id.Scheme == `ASIN` {
			m.ASIN = id.Value
			continue
		}

		if id.Scheme == `ISBN` {
			m.ISBN = id.Value
			continue
		}

		// m.Identifier = append(m.Identifier, Identifier{

		// })
	}
	m.Identifier = hex.EncodeToString(hasher.Sum(nil))

	if len(mdata.Creator) > 0 {
		m.Title = mdata.Title[0].Value
	} else {
		log.W(`查找图书名失败，使用文件名作为标题`, m.Path)
		fileName := filepath.Base(m.Path)
		m.Title = fileName[:len(fileName)-len(filepath.Ext(fileName))]
	}

	if len(mdata.Creator) > 0 {
		m.Author = mdata.Creator[0].Value
	}

	if len(mdata.Date) > 0 {
		m.PublishDate = mdata.Date[0].Value
	}

	m.parseMeta(opf)

}

func (m *Book) Save(ctx context.Context, db *gorm.DB, kv store.KV) error {

	//存储图书到数据库
	//TODO 处理重复问题
	if err := m.Create(db); err != nil {
		log.E(`存储图书失败：`, err)
		return errors.New(`文件：` + m.Path + ` 存储失败：` + err.Error())
	}

	//创建bucket目录
	if err := kv.CreateBucket(ctx, m.Identifier[0:1]); err != nil {
		log.E(`创建目录失败：`, err.Error())

		//如果失败不在继续出来异常
		return nil

	}

	obj := &store.Object{
		Key:          m.CoverKey(),
		Size:         m.Size,
		LastModified: m.CTime,
		Data:         m.GetCoverData(),
	}

	//存储封面图片数据
	if err := kv.PutObject(ctx, m.Identifier[0:1], obj); err != nil {
		log.E(`存储封面失败,`, m.Path, `失败：`, err.Error())
		// return err
	}
	return nil
}

func (m *Book) CoverKey() string {
	return filepath.Join(m.Identifier + replacePath(m.CoverURL))
}

func (m *Book) parseMeta(opf *epub.PackageDocument) {

	metas := opf.Metadata.Meta
	for _, meta := range metas {
		switch meta.Name {
		case "calibre:series":
			m.Series = meta.Content

		case "calibre:series_index":
			m.SeriesIndex = meta.Content
		case "cover":
			// id := meta.Content

			if opf.Manifest != nil {
				items := opf.Manifest.Items
				for i := len(items) - 1; i >= 0; i-- {
					if items[i].ID == `cover-image` || items[i].Properties == `cover-image` {
						m.CoverURL = items[i].Href
						break
					}

				}

			}
			// println(id)
		}

	}

	if m.CoverURL == `` && opf.Manifest != nil {
		items := opf.Manifest.Items
		for i := len(items) - 1; i >= 0; i-- {
			if items[i].ID == `cover-image` || items[i].Properties == `cover-image` {
				m.CoverURL = items[i].Href
				break
			}

		}
	}

}

func elt2str(elt []epub.Element) []string {
	s := make([]string, len(elt))

	for i, e := range elt {
		s[i] = e.Value
	}

	return s
}

func elt2FirstStr(elt []epub.Element) string {

	if len(elt) > 0 {
		return elt[0].Value
	}
	return ""

}

// 替换路径字符串中'/'为'-'
func replacePath(path string) string {
	return strings.ReplaceAll(path, "/", "-")
}
