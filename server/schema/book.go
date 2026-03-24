package schema

import (
	"bytes"
	"context"
	"crypto/md5"
	"crypto/rand"
	"encoding/base64"
	"encoding/binary"
	"encoding/hex"
	"encoding/xml"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/store"
	"github.com/lxpio/omnigram/server/utils"
	"github.com/nexptr/epub"
	pdfapi "github.com/pdfcpu/pdfcpu/pkg/api"
	"github.com/pdfcpu/pdfcpu/pkg/pdfcpu/model"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type FileType int

const (
	UnkownFile FileType = iota
	// EPUB represents the EPUB file type.
	EPUB

	// AZW3 represents the AZW3 file type.
	AZW3

	// MOBI represents the MOBI file type.
	MOBI

	// PDF represents the PDF file type.
	PDF

	// TXT represents the TXT file type.
	TXT

	// MD represents the markdown file type.
	MD

	// FB2 represents the FictionBook 2 file type.
	FB2
)

func ParseFileType(filename string) FileType {
	switch strings.ToLower(filepath.Ext(filename)) {
	case ".epub":
		return EPUB
	case ".azw3":
		return AZW3
	case ".mobi":
		return MOBI
	case ".pdf":
		return PDF
	case ".txt":
		return TXT
	case ".md", ".markdown":
		return MD
	case ".fb2":
		return FB2
	default:
		return UnkownFile
	}
}

type Book struct {
	ID    string `json:"id" gorm:"type:char(24);primaryKey;comment:ID"`
	Size  int64  `json:"size" gorm:"comment:文件大小"`
	Path  string `json:"-" gorm:"comment:文件路径"` //本地文件路径不返回到界面上
	CTime int64  `json:"ctime" form:"ctime" gorm:"column:ctime;autoCreateTime;comment:创建时间"`
	UTime int64  `json:"utime" gorm:"column:utime;autoUpdateTime;comment:更新时间"`

	Title string `json:"title" gorm:"index:idx_book_title;type:varchar(200);comment:标题"`

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
	FileType    FileType `json:"file_type"  gorm:"column:file_type;comment:图书类型"`

	// Series is the series to which this book belongs to.
	Series string `json:",omitempty" gorm:"type:varchar(200);comment:系列"`
	// SeriesIndex is the position in the series to which the book belongs to.
	SeriesIndex string `json:",omitempty" gorm:"type:varchar(200);comment:用户标签列表"`
	PublishDate string `json:"pubdate" gorm:"type:varchar(50);comment:用户标签列表"`

	Rating float32 `json:"rating" gorm:"comment:评分"`

	Tags Tags `json:"tags" gorm:"column:tags;type:text;comment:用户标签列表"`

	PublisherURL string `json:"publisher_url" gorm:"type:varchar(255);comment:用户标签列表"`

	CountVisit    int64 `json:"count_visit" gorm:"default:0;comment:访问次数"`
	CountDownload int64 `json:"count_download" gorm:"default:0;comment:下载次数"`

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

func FirstBookById(store *gorm.DB, id string) (*Book, error) {
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

// SyncFullBooks 模糊搜索书籍
func SyncFullBooks(store *gorm.DB, limit, until int64, fileType FileType) (<-chan []Book, error) {

	db := store.Model(Book{}).Where(`utime <= ?`, until)

	if fileType > 0 {
		db.Where(`file_type = ?`, fileType)
	}

	bookChan := make(chan []Book)

	var books []Book
	log.D(`开始获取书籍数据`)

	go func() {

		defer close(bookChan)

		result := db.FindInBatches(&books, int(limit), func(tx *gorm.DB, batch int) error {
			log.D(`batch:`, batch)
			bookChan <- books
			return nil
		})

		log.D(`结束获取书籍数据`)
		if result.Error != nil {
			log.E("Error When get data:", result.Error)
		} else {
			log.D(`Completed get books all batches`)
		}
	}()

	return bookChan, nil
}

// SyncDeltaBooks 模糊搜索书籍
func SyncDeltaBooks(store *gorm.DB, utime int64, fileType FileType) (interface{}, error) {

	resp := struct {
		Deleted      []string `json:"deleted"`
		NeedFullSync bool     `json:"need_full_sync"`
		Upserted     []Book   `json:"upserted"`
	}{}

	tx := store.Model(Book{}).Where(`utime > ?`, utime)

	if fileType > 0 {
		tx.Where(`file_type = ?`, fileType)
	}

	{
		tx = tx.Session(&gorm.Session{})
		count := int64(0)

		if err := tx.Count(&count).Error; err != nil {
			return resp, err
		}

		if count > 100000 {
			resp.NeedFullSync = true
			return resp, nil
		}
	}

	err := tx.Find(&resp.Upserted).Error

	//deleted data current not support

	return resp, err

}

// Create 存储图书元数据到数据库
func (book *Book) Create(store *gorm.DB) error {

	err := store.Transaction(func(tx *gorm.DB) error {

		if err := tx.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "identifier"}},
			DoNothing: true,
		}).Create(book).Error; err != nil {
			return err
		}

		if len(book.Tags) > 0 {
			tags := make([]BookTagShip, len(book.Tags))

			for i := 0; i < len(book.Tags); i++ {
				tags[i] = BookTagShip{
					BookID: book.ID,
					Tag:    book.Tags[i],
				}
			}

			return tx.Create(&tags).Error

		}
		return nil
	})

	//存储图书到数据库，如果唯一键 identifier 存在则忽略
	return err

}

func (book *Book) GetCoverData() []byte {
	return book.coverData
}

func (book *Book) SetCoverData(data []byte) {
	book.coverData = data
}

func (book *Book) IsDuplicate(id string) bool {
	return book.Identifier == id
}

// GetMetadataFromFile reads metadata from book file based on file type.
func (book *Book) GetMetadataFromFile() error {

	_, err := os.Stat(book.Path)
	if os.IsNotExist(err) {
		log.D(`文件不存在`, book.Path, `无法访问或者不存在`)
		return errors.New(`缓存目录无法访问或者不存在`)
	}

	switch book.FileType {
	case EPUB:
		return book.getEpubMetadata()
	case PDF:
		return book.getPDFMetadata()
	case FB2:
		return book.getFB2Metadata()
	case MOBI, AZW3:
		return book.getMobiMetadata()
	default:
		book.getFilenameMetadata()
		return nil
	}
}

// getEpubMetadata 从 EPUB 文件提取元数据
func (book *Book) getEpubMetadata() error {
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
	}

	return nil
}

// getPDFMetadata 从 PDF 文件提取元数据
func (book *Book) getPDFMetadata() error {
	f, err := os.Open(book.Path)
	if err != nil {
		return err
	}
	defer f.Close()

	info, err := pdfapi.PDFInfo(f, book.Path, nil, false, nil)
	if err != nil {
		log.E(`解析 PDF 元数据失败：`, err.Error())
		// 即使 PDF 解析失败，仍用文件名兜底
		book.getFilenameMetadata()
		return nil
	}

	if info.Title != "" {
		book.Title = info.Title
	}
	if info.Author != "" {
		book.Author = info.Author
	}
	if info.Subject != "" {
		book.Description = info.Subject
	}
	if info.Creator != "" && book.Publisher == "" {
		book.Publisher = info.Creator
	}
	if len(info.Keywords) > 0 {
		book.Tags = Tags(info.Keywords)
	}
	if info.CreationDate != "" {
		book.PublishDate = info.CreationDate
	}

	// Extract cover from first page images
	f.Seek(0, io.SeekStart)
	var coverFound bool
	_ = pdfapi.ExtractImages(f, []string{"1"}, func(img model.Image, singleImgPerPage bool, maxPageDigits int) error {
		if coverFound {
			return nil
		}
		data, err := io.ReadAll(img.Reader)
		if err == nil && len(data) > 0 {
			book.coverData = data
			coverFound = true
		}
		return nil
	}, nil)

	// 如果 PDF 没有 Title，用文件名兜底
	if book.Title == "" {
		book.getFilenameMetadata()
	}

	return nil
}

// getFB2Metadata extracts metadata from FB2 (FictionBook 2) XML files.
func (book *Book) getFB2Metadata() error {
	data, err := os.ReadFile(book.Path)
	if err != nil {
		book.getFilenameMetadata()
		return nil
	}

	type fb2Author struct {
		FirstName  string `xml:"first-name"`
		MiddleName string `xml:"middle-name"`
		LastName   string `xml:"last-name"`
	}

	type fb2TitleInfo struct {
		Genre      []string    `xml:"genre"`
		Authors    []fb2Author `xml:"author"`
		BookTitle  string      `xml:"book-title"`
		Annotation struct {
			P []string `xml:"p"`
		} `xml:"annotation"`
		Date struct {
			Value string `xml:",chardata"`
		} `xml:"date"`
		Lang     string `xml:"lang"`
		Sequence struct {
			Name   string `xml:"name,attr"`
			Number string `xml:"number,attr"`
		} `xml:"sequence"`
	}

	type fb2PublishInfo struct {
		Publisher string `xml:"publisher"`
		ISBN      string `xml:"isbn"`
		Year      string `xml:"year"`
	}

	type fb2Description struct {
		TitleInfo   fb2TitleInfo   `xml:"title-info"`
		PublishInfo fb2PublishInfo `xml:"publish-info"`
	}

	type fb2Book struct {
		Description fb2Description `xml:"description"`
		Binary      []struct {
			ID          string `xml:"id,attr"`
			ContentType string `xml:"content-type,attr"`
			Data        string `xml:",chardata"`
		} `xml:"binary"`
	}

	var fb fb2Book
	if err := xml.Unmarshal(data, &fb); err != nil {
		log.E("FB2 parse error:", err.Error())
		book.getFilenameMetadata()
		return nil
	}

	ti := fb.Description.TitleInfo
	pi := fb.Description.PublishInfo

	if ti.BookTitle != "" {
		book.Title = ti.BookTitle
	}

	// Build author string
	var authorParts []string
	for _, a := range ti.Authors {
		parts := []string{}
		if a.FirstName != "" {
			parts = append(parts, a.FirstName)
		}
		if a.MiddleName != "" {
			parts = append(parts, a.MiddleName)
		}
		if a.LastName != "" {
			parts = append(parts, a.LastName)
		}
		if len(parts) > 0 {
			authorParts = append(authorParts, strings.Join(parts, " "))
		}
	}
	if len(authorParts) > 0 {
		book.Author = strings.Join(authorParts, ", ")
	}

	if len(ti.Genre) > 0 {
		book.Tags = Tags(ti.Genre)
	}
	if ti.Lang != "" {
		book.Language = ti.Lang
	}
	if ti.Annotation.P != nil {
		book.Description = strings.Join(ti.Annotation.P, "\n")
	}
	if ti.Date.Value != "" {
		book.PublishDate = ti.Date.Value
	}
	if ti.Sequence.Name != "" {
		book.Series = ti.Sequence.Name
		if ti.Sequence.Number != "" {
			book.SeriesIndex = ti.Sequence.Number
		}
	}

	if pi.Publisher != "" {
		book.Publisher = pi.Publisher
	}
	if pi.ISBN != "" {
		book.ISBN = pi.ISBN
	}

	// Extract cover image from binary data
	for _, bin := range fb.Binary {
		if strings.Contains(strings.ToLower(bin.ID), "cover") {
			decoded, err := base64.StdEncoding.DecodeString(strings.TrimSpace(bin.Data))
			if err == nil && len(decoded) > 0 {
				book.coverData = decoded
			}
			break
		}
	}

	if book.Title == "" {
		book.getFilenameMetadata()
	}

	return nil
}

// getMobiMetadata extracts metadata from MOBI/AZW3 files by parsing the PalmDOC + MOBI header.
func (book *Book) getMobiMetadata() error {
	f, err := os.Open(book.Path)
	if err != nil {
		book.getFilenameMetadata()
		return nil
	}
	defer f.Close()

	// Read PalmDOC header (78 bytes)
	header := make([]byte, 78)
	if _, err := io.ReadFull(f, header); err != nil {
		book.getFilenameMetadata()
		return nil
	}

	// Get title from PalmDOC header (bytes 0-31, null-terminated)
	palmTitle := strings.TrimRight(string(header[0:32]), "\x00 ")

	// Number of records
	numRecords := binary.BigEndian.Uint16(header[76:78])
	if numRecords == 0 {
		if palmTitle != "" {
			book.Title = palmTitle
		} else {
			book.getFilenameMetadata()
		}
		return nil
	}

	// Read first record offset from record info
	f.Seek(78, io.SeekStart)
	recInfo := make([]byte, 8)
	if _, err := io.ReadFull(f, recInfo); err != nil {
		if palmTitle != "" {
			book.Title = palmTitle
		} else {
			book.getFilenameMetadata()
		}
		return nil
	}
	firstRecordOffset := binary.BigEndian.Uint32(recInfo[0:4])

	// Seek to first record (PalmDOC header in record)
	f.Seek(int64(firstRecordOffset), io.SeekStart)

	// Read PalmDOC record header (16 bytes) then MOBI header
	palmDocHeader := make([]byte, 16)
	if _, err := io.ReadFull(f, palmDocHeader); err != nil {
		if palmTitle != "" {
			book.Title = palmTitle
		} else {
			book.getFilenameMetadata()
		}
		return nil
	}

	// Check MOBI magic at offset 16
	mobiMagic := make([]byte, 4)
	if _, err := io.ReadFull(f, mobiMagic); err != nil || string(mobiMagic) != "MOBI" {
		if palmTitle != "" {
			book.Title = palmTitle
		} else {
			book.getFilenameMetadata()
		}
		return nil
	}

	// Read MOBI header (at least 232 bytes after magic)
	mobiHeader := make([]byte, 232)
	if _, err := io.ReadFull(f, mobiHeader); err != nil {
		if palmTitle != "" {
			book.Title = palmTitle
		} else {
			book.getFilenameMetadata()
		}
		return nil
	}

	// Language code at offset 36 from MOBI start (offset 32 from after magic)
	langCode := binary.BigEndian.Uint32(mobiHeader[32:36])
	if lang := mobiLangCode(langCode); lang != "" {
		book.Language = lang
	}

	// Full title offset & length in MOBI header
	fullTitleOffset := binary.BigEndian.Uint32(mobiHeader[80:84])
	fullTitleLength := binary.BigEndian.Uint32(mobiHeader[84:88])

	if fullTitleLength > 0 && fullTitleLength < 1024 {
		f.Seek(int64(firstRecordOffset)+int64(fullTitleOffset), io.SeekStart)
		titleBuf := make([]byte, fullTitleLength)
		if _, err := io.ReadFull(f, titleBuf); err == nil {
			book.Title = strings.TrimRight(string(titleBuf), "\x00")
		}
	}

	if book.Title == "" && palmTitle != "" {
		book.Title = palmTitle
	}
	if book.Title == "" {
		book.getFilenameMetadata()
	}

	// Try to read EXTH header for extended metadata
	exthOffset := binary.BigEndian.Uint32(mobiHeader[12:16])
	if exthOffset > 0 {
		book.parseEXTH(f, int64(firstRecordOffset)+16+4+int64(exthOffset))
	}

	return nil
}

// parseEXTH reads extended MOBI metadata (author, publisher, description, etc.)
func (book *Book) parseEXTH(f *os.File, offset int64) {
	f.Seek(offset, io.SeekStart)

	magic := make([]byte, 4)
	if _, err := io.ReadFull(f, magic); err != nil || string(magic) != "EXTH" {
		return
	}

	header := make([]byte, 8)
	if _, err := io.ReadFull(f, header); err != nil {
		return
	}
	recordCount := binary.BigEndian.Uint32(header[4:8])

	for i := uint32(0); i < recordCount && i < 200; i++ {
		recHeader := make([]byte, 8)
		if _, err := io.ReadFull(f, recHeader); err != nil {
			return
		}
		recType := binary.BigEndian.Uint32(recHeader[0:4])
		recLen := binary.BigEndian.Uint32(recHeader[4:8])
		if recLen < 8 || recLen > 65536 {
			return
		}

		data := make([]byte, recLen-8)
		if _, err := io.ReadFull(f, data); err != nil {
			return
		}

		value := strings.TrimSpace(string(data))
		switch recType {
		case 100: // Author
			if book.Author == "" {
				book.Author = value
			}
		case 101: // Publisher
			book.Publisher = value
		case 103: // Description
			book.Description = value
		case 104: // ISBN
			book.ISBN = value
		case 105: // Subject/Tag
			book.Tags = append(book.Tags, value)
		case 106: // PublishDate
			book.PublishDate = value
		case 113: // ASIN
			book.ASIN = value
		case 524: // Language
			if book.Language == "" {
				book.Language = value
			}
		}
	}
}

// mobiLangCode maps MOBI language codes to ISO 639-1 codes.
func mobiLangCode(code uint32) string {
	primary := code & 0xFF
	switch primary {
	case 0x09:
		return "en"
	case 0x04:
		return "zh"
	case 0x11:
		return "ja"
	case 0x0A:
		return "es"
	case 0x0C:
		return "fr"
	case 0x07:
		return "de"
	case 0x10:
		return "it"
	case 0x16:
		return "pt"
	case 0x19:
		return "ru"
	case 0x12:
		return "ko"
	case 0x01:
		return "ar"
	default:
		return ""
	}
}

// getFilenameMetadata 从文件名提取基本元数据
// 支持格式：
//   - "Title - Author.ext"
//   - "Title.ext" (无作者)
func (book *Book) getFilenameMetadata() {
	base := filepath.Base(book.Path)
	name := strings.TrimSuffix(base, filepath.Ext(base))

	// 尝试 "Title - Author" 格式
	if parts := strings.SplitN(name, " - ", 2); len(parts) == 2 {
		book.Title = strings.TrimSpace(parts[0])
		book.Author = strings.TrimSpace(parts[1])
	} else {
		book.Title = strings.TrimSpace(name)
	}
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

	if len(mdata.Title) > 0 {
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

func (m *Book) Save(ctx context.Context) error {

	db := store.FileStore()
	//存储图书到数据库
	//TODO 处理重复问题
	if err := m.Create(db); err != nil {
		log.E(`存储图书失败：`, err)
		return errors.New(`文件：` + m.Path + ` 存储失败：` + err.Error())
	}

	kv := store.GetKV()

	//创建bucket目录
	if err := kv.CreateBucket(ctx, GetCoverBucket(m.Identifier)); err != nil {
		log.E(`创建目录失败：`, err.Error())

		//如果失败不在继续出来异常
		return nil

	}

	//存储封面图片数据
	coverKey := m.CoverKey()
	if err := kv.Put(ctx, GetCoverBucket(m.Identifier), coverKey, m.GetCoverData()); err != nil {
		log.E(`存储封面失败,`, m.Path, `失败：`, err.Error())
	}

	// Update cover_url to full KV key so frontend can construct correct URL
	if m.CoverURL != "" && m.CoverURL != coverKey {
		m.CoverURL = coverKey
		db.Model(m).Update("cover_url", coverKey)
	}
	return nil
}

func GetCoverBucket(input string) string {
	return input[0:2]
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

func GenBookID(now time.Time) string {

	// 14 chars timestamp + 10 chars random = 24 chars total
	currentTime := now.Format("20060102150405")

	var randBytes [8]byte
	rand.Read(randBytes[:])
	randNum := binary.LittleEndian.Uint64(randBytes[:]) % 10000000000

	id := fmt.Sprintf("%s%010d", currentTime, randNum)

	return id
}
