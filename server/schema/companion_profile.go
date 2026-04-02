package schema

import "gorm.io/gorm"

// CompanionProfile stores the AI companion personality configuration per user.
type CompanionProfile struct {
	ID          int64  `json:"id" gorm:"primaryKey"`
	UserID      int64  `json:"user_id" gorm:"uniqueIndex;comment:用户ID"`
	Name        string `json:"name" gorm:"type:varchar(100);default:TARS;comment:伴侣名称"`
	Proactivity int    `json:"proactivity" gorm:"default:50;comment:主动性 0-100"`
	Style       int    `json:"style" gorm:"default:50;comment:风格 0(严谨)到100(幽默)"`
	Depth       int    `json:"depth" gorm:"default:50;comment:深度 0(简洁)到100(详细)"`
	Warmth      int    `json:"warmth" gorm:"default:50;comment:温度 0(理性)到100(感性)"`
	Voice       string `json:"voice" gorm:"type:varchar(200);comment:关联的TTS声音ID"`
	PresetName           string `json:"preset_name" gorm:"type:varchar(50);comment:预设模板名"`
	AutoChapterRecap     bool   `json:"autoChapterRecap" gorm:"default:false;comment:自动章节回顾"`
	AnnotateHardWords    bool   `json:"annotateHardWords" gorm:"default:false;comment:标注难词"`
	CrossBookAlerts      bool   `json:"crossBookAlerts" gorm:"default:true;comment:跨书连接提醒"`
	PostChapterQuestions bool   `json:"postChapterQuestions" gorm:"default:false;comment:章节读后提问"`
	AutoKnowledgeGraph   bool   `json:"autoKnowledgeGraph" gorm:"default:true;comment:自动知识图谱"`
	CTime                int64  `json:"ctime" gorm:"column:ctime;autoCreateTime:milli;comment:创建时间"`
	UTime       int64  `json:"utime" gorm:"column:utime;autoUpdateTime:milli;comment:更新时间"`
}

func (CompanionProfile) TableName() string {
	return "companion_profiles"
}

// GetCompanionProfile retrieves companion profile for a user.
func GetCompanionProfile(db *gorm.DB, userID int64) (*CompanionProfile, error) {
	profile := &CompanionProfile{}
	err := db.Where("user_id = ?", userID).First(profile).Error
	if err != nil {
		return nil, err
	}
	return profile, nil
}

// MigrateCompanionToggles sets correct defaults for existing rows after adding toggle columns.
func MigrateCompanionToggles(db *gorm.DB) error {
	return db.Exec(
		"UPDATE companion_profiles SET cross_book_alerts = true, auto_knowledge_graph = true WHERE cross_book_alerts = false AND auto_knowledge_graph = false",
	).Error
}

// SaveCompanionProfile creates or updates companion profile for a user.
func SaveCompanionProfile(db *gorm.DB, profile *CompanionProfile) error {
	existing := &CompanionProfile{}
	err := db.Where("user_id = ?", profile.UserID).First(existing).Error
	if err != nil {
		// Create new
		return db.Create(profile).Error
	}
	// Update existing
	profile.ID = existing.ID
	return db.Save(profile).Error
}
