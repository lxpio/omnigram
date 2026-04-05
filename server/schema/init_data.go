package schema

import (
	"os"
	"path/filepath"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/store"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

func InitData() error {

	if err := initReaderData(); err != nil {
		log.E(err)
		os.Exit(1)
	}

	if err := initUserData(); err != nil {
		log.E(err)
		os.Exit(1)
	}

	return nil
}

func initUserData() error {

	db := store.Store()

	log.D(`初始化用户数据`)

	var err error

	return db.Transaction(func(tx *gorm.DB) error {

		if err = tx.AutoMigrate(&User{}, &APIToken{}, &Session{}, &CompanionProfile{}); err != nil {
			return err
		}

		if err = MigrateCompanionToggles(tx); err != nil {
			return err
		}

		u := &User{
			Name:       os.Getenv(`OMNI_USER`),
			Credential: os.Getenv(`OMNI_PASSWORD`),
			RoleID:     1,
		}

		if u.Name == `` {
			u.Name = `admin`
		}

		if u.Credential == `` {
			u.Credential = `123456`
		}

		log.I(`初始化数据, 用户信息: `, u.Name, `[REDACTED]`)

		if err = tx.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "name"}},
			DoNothing: true,
		}).Create(u).Error; err != nil {
			return err
		}

		if u.ID == 1 {
			apiKey := NewAPIToken(u.ID)
			if err := tx.Create(&apiKey).Error; err != nil {
				log.E(`初始化用户APIKey失败`, err)
				return err
			}
			log.I(`初始化数据成功, 用户信息: `, u.Name, `, 初始 APIKey: `, apiKey.APIKey)
		}

		return nil

	})

}

func initReaderData() error {
	log.D(`初始化文档相关数据库`)
	cf := conf.GetConfig()

	metapath := cf.MetaPath()

	//metapath 路径不存在则创建
	if _, err := os.Stat(metapath); os.IsNotExist(err) {
		if err := os.Mkdir(metapath, 0755); err != nil {
			panic(err)
		}
	}

	//初始化上传文件目录
	os.MkdirAll(filepath.Join(cf.EpubOptions.DataPath, `upload`), 0755)
	os.MkdirAll(cf.MetaPath(), 0755)
	os.MkdirAll(cf.CoverPath(), 0755)

	db := store.FileStore()

	// Enable pgvector extension (outside transaction — failure should not block init)
	if err := db.Exec(`CREATE EXTENSION IF NOT EXISTS vector`).Error; err != nil {
		log.W("pgvector extension not available (semantic search disabled): ", err)
	}

	err := db.Transaction(func(tx *gorm.DB) error {

		//auotoMigrate
		if err := tx.AutoMigrate(&Book{}, &BookTagShip{}, &FavBook{}, &ReadProgress{}, &Shelf{}, &ShelfBook{}, &Annotation{}, &ReadingSession{}, &AudiobookTask{}, &ChapterTask{}, &AiResult{}, &CompanionChat{}, &MarginNote{}, &ConceptTag{}, &ConceptEdge{}); err != nil {

			return err
		}

		// Migrate book timestamps from seconds to milliseconds (one-time, idempotent).
		// Books with ctime < 1e12 are still in seconds (before year 33658 in millis).
		tx.Exec(`UPDATE books SET ctime = ctime * 1000 WHERE ctime > 0 AND ctime < 1000000000000`)
		tx.Exec(`UPDATE books SET utime = utime * 1000 WHERE utime > 0 AND utime < 1000000000000`)

		// Add tsvector column for full-text search (PG native)
		tx.Exec(`DO $$ BEGIN
			IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='books' AND column_name='search_vector') THEN
				ALTER TABLE books ADD COLUMN search_vector tsvector;
			END IF;
		END $$`)

		// Create GIN index for tsvector
		tx.Exec(`CREATE INDEX IF NOT EXISTS idx_books_search_vector ON books USING GIN(search_vector)`)

		// Composite indexes for delta sync queries (user_id + timestamp)
		tx.Exec(`CREATE INDEX IF NOT EXISTS idx_concept_tags_sync ON concept_tags(user_id, ctime)`)
		tx.Exec(`CREATE INDEX IF NOT EXISTS idx_concept_edges_sync ON concept_edges(user_id, ctime)`)
		tx.Exec(`CREATE INDEX IF NOT EXISTS idx_annotations_sync ON annotations(user_id, utime)`)

		// Create trigger to auto-update tsvector on insert/update
		tx.Exec(`CREATE OR REPLACE FUNCTION books_search_vector_update() RETURNS trigger AS $$
		BEGIN
			NEW.search_vector := to_tsvector('simple',
				coalesce(NEW.title, '') || ' ' ||
				coalesce(NEW.author, '') || ' ' ||
				coalesce(NEW.description, '') || ' ' ||
				coalesce(NEW.tags, '') || ' ' ||
				coalesce(NEW.publisher, '')
			);
			RETURN NEW;
		END
		$$ LANGUAGE plpgsql`)

		tx.Exec(`DROP TRIGGER IF EXISTS books_search_vector_trigger ON books`)
		tx.Exec(`CREATE TRIGGER books_search_vector_trigger
			BEFORE INSERT OR UPDATE ON books
			FOR EACH ROW EXECUTE FUNCTION books_search_vector_update()`)

		// Backfill existing rows
		tx.Exec(`UPDATE books SET search_vector = to_tsvector('simple',
			coalesce(title, '') || ' ' ||
			coalesce(author, '') || ' ' ||
			coalesce(description, '') || ' ' ||
			coalesce(tags, '') || ' ' ||
			coalesce(publisher, '')
		) WHERE search_vector IS NULL`)

		log.I(`初始化书籍表成功。`)

		return nil

	})

	if err != nil {
		return err
	}

	// pgvector-dependent DDL (outside transaction — safe to fail if extension unavailable)
	db.Exec(`DO $$ BEGIN
		IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='books' AND column_name='embedding') THEN
			ALTER TABLE books ADD COLUMN embedding vector(1536);
		END IF;
	END $$`)
	db.Exec(`CREATE INDEX IF NOT EXISTS idx_books_embedding ON books USING hnsw (embedding vector_cosine_ops)`)

	return nil
}
