package schema

import (
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

// ConceptTag represents an auto-extracted concept from notes/highlights.
type ConceptTag struct {
	ID     int64  `json:"id" gorm:"primaryKey"`
	UserID int64  `json:"user_id" gorm:"index:idx_concept_user;uniqueIndex:idx_concept_unique;comment:用户ID"`
	BookID string `json:"book_id" gorm:"type:char(24);index:idx_concept_book;uniqueIndex:idx_concept_unique;comment:书籍ID"`
	Name   string `json:"name" gorm:"type:varchar(200);index:idx_concept_name;uniqueIndex:idx_concept_unique;comment:概念名称"`
	Source string `json:"source" gorm:"type:text;comment:来源文本(高亮/笔记原文)"`
	NoteID int64  `json:"note_id" gorm:"uniqueIndex:idx_concept_unique;comment:关联的笔记ID"`
	CTime  int64  `json:"ctime" gorm:"column:ctime;autoCreateTime:milli;comment:创建时间"`
}

func (ConceptTag) TableName() string {
	return "concept_tags"
}

// ConceptEdge represents a relationship between two concepts across books.
type ConceptEdge struct {
	ID       int64   `json:"id" gorm:"primaryKey"`
	UserID   int64   `json:"user_id" gorm:"index:idx_edge_user;uniqueIndex:idx_edge_unique;comment:用户ID"`
	SourceID int64   `json:"source_id" gorm:"uniqueIndex:idx_edge_unique;comment:源概念ID"`
	TargetID int64   `json:"target_id" gorm:"uniqueIndex:idx_edge_unique;comment:目标概念ID"`
	Weight   float64 `json:"weight" gorm:"default:1.0;comment:关联强度"`
	Reason   string  `json:"reason" gorm:"type:text;comment:AI生成的关联原因"`
	CTime    int64   `json:"ctime" gorm:"column:ctime;autoCreateTime:milli;comment:创建时间"`
}

func (ConceptEdge) TableName() string {
	return "concept_edges"
}

// CRUD helpers
func ListConceptTags(db *gorm.DB, userID int64) ([]ConceptTag, error) {
	var tags []ConceptTag
	err := db.Where("user_id = ?", userID).Order("ctime desc").Find(&tags).Error
	return tags, err
}

func ListConceptTagsByBook(db *gorm.DB, userID int64, bookID string) ([]ConceptTag, error) {
	var tags []ConceptTag
	err := db.Where("user_id = ? AND book_id = ?", userID, bookID).Order("ctime desc").Find(&tags).Error
	return tags, err
}

func ListConceptEdges(db *gorm.DB, userID int64) ([]ConceptEdge, error) {
	var edges []ConceptEdge
	err := db.Where("user_id = ?", userID).Find(&edges).Error
	return edges, err
}

func UpsertConceptTags(db *gorm.DB, tags []ConceptTag) error {
	if len(tags) == 0 {
		return nil
	}
	return db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "user_id"}, {Name: "book_id"}, {Name: "name"}, {Name: "note_id"}},
		DoUpdates: clause.AssignmentColumns([]string{"source"}),
	}).Create(&tags).Error
}

func UpsertConceptEdges(db *gorm.DB, edges []ConceptEdge) error {
	if len(edges) == 0 {
		return nil
	}
	return db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "user_id"}, {Name: "source_id"}, {Name: "target_id"}},
		DoUpdates: clause.AssignmentColumns([]string{"weight", "reason"}),
	}).Create(&edges).Error
}

func ListConceptTagsSince(db *gorm.DB, userID int64, since int64) ([]ConceptTag, error) {
	var tags []ConceptTag
	err := db.Where("user_id = ? AND ctime > ?", userID, since).Order("ctime desc").Find(&tags).Error
	return tags, err
}

func ListConceptTagsByBookSince(db *gorm.DB, userID int64, bookID string, since int64) ([]ConceptTag, error) {
	var tags []ConceptTag
	err := db.Where("user_id = ? AND book_id = ? AND ctime > ?", userID, bookID, since).Order("ctime desc").Find(&tags).Error
	return tags, err
}

func ListConceptEdgesSince(db *gorm.DB, userID int64, since int64) ([]ConceptEdge, error) {
	var edges []ConceptEdge
	err := db.Where("user_id = ? AND ctime > ?", userID, since).Find(&edges).Error
	return edges, err
}

// TagMapping maps client-provided local_id to server-assigned id.
type TagMapping struct {
	LocalID  int64 `json:"local_id"`
	ServerID int64 `json:"server_id"`
}

// ConceptTagWithLocalID extends ConceptTag with a client-side local_id for sync mapping.
type ConceptTagWithLocalID struct {
	ConceptTag
	LocalID int64 `json:"local_id" gorm:"-"`
}

func UpsertConceptTagsWithMapping(db *gorm.DB, tags []ConceptTagWithLocalID) ([]TagMapping, error) {
	if len(tags) == 0 {
		return nil, nil
	}

	// Extract local IDs in order, then batch upsert the underlying ConceptTags.
	localIDs := make([]int64, len(tags))
	rows := make([]ConceptTag, len(tags))
	for i, t := range tags {
		localIDs[i] = t.LocalID
		rows[i] = t.ConceptTag
	}

	if err := db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "user_id"}, {Name: "book_id"}, {Name: "name"}, {Name: "note_id"}},
		DoUpdates: clause.AssignmentColumns([]string{"source"}),
	}).Create(&rows).Error; err != nil {
		return nil, err
	}

	// rows[i].ID is now populated (INSERT returns the id; ON CONFLICT update also returns it via RETURNING).
	mappings := make([]TagMapping, len(rows))
	for i, row := range rows {
		mappings[i] = TagMapping{LocalID: localIDs[i], ServerID: row.ID}
	}
	return mappings, nil
}
