package schema

import (
	"database/sql/driver"
	"fmt"
	"strings"
)

type Tags []string

// Scan scan value into Jsonb, implements sql.Scanner interface
func (j *Tags) Scan(value interface{}) error {
	switch src := value.(type) {
	case []byte:
		return j.scan(string(src))
	case string:
		return j.scan(src)
	case nil:
		*j = nil
		return nil
	}

	return fmt.Errorf("pq: cannot convert %T to StringArray", value)
}

// Value return json value, implement driver.Valuer interface
func (j Tags) Value() (driver.Value, error) {
	if len(j) == 0 {
		return nil, nil
	}

	return strings.Join(j, ","), nil
}

func (j *Tags) scan(src string) error {
	elems := strings.Split(src, ",")

	if *j != nil && len(elems) == 0 {
		*j = (*j)[:0]
	} else {
		*j = elems
	}
	return nil
}

type BookTagShip struct {
	ID     int64  `json:"id" gorm:"column:id;autoIncrement;primaryKey;comment:ID"`
	BookID string `json:"book_id" gorm:"column:book_id;type:char(24);uniqueIndex:book_id_tag;comment:book id"`
	Tag    string `json:"tag" gorm:"column:tag;type:varchar(100);uniqueIndex:book_id_tag;comment:tag name"`
}
