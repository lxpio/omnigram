package tts

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
)

// AlignmentSchemaVersion is the on-disk schema version for chapter_NNN.align.json.
// Bump when changing the JSON shape in an incompatible way.
const AlignmentSchemaVersion = 1

// ChapterAlignment is the persisted mapping between audio time and text for
// a single chapter. Written alongside chapter_NNN.mp3 in the audiobook
// storage dir; consumed by the client to drive karaoke-style highlight.
//
// Sentences[i].EndMs equals Sentences[i+1].StartMs (no gaps), and the last
// EndMs equals AudioDurationMs. The client does a binary search on audio
// position to locate the current sentence.
type ChapterAlignment struct {
	SchemaVersion   int                 `json:"schema_version"`
	ChapterIndex    int                 `json:"chapter_index"`
	ChapterTitle    string              `json:"chapter_title"`
	AudioFile       string              `json:"audio_file"`
	AudioDurationMs int64               `json:"audio_duration_ms"`
	Voice           string              `json:"voice"`
	Provider        string              `json:"provider"`
	GeneratedAt     int64               `json:"generated_at"`
	Sentences       []SentenceAlignment `json:"sentences"`
}

// SentenceAlignment pairs one synthesised sentence with its audio span and
// original-text anchor.
type SentenceAlignment struct {
	Index      int    `json:"index"`
	Text       string `json:"text"`
	StartMs    int64  `json:"start_ms"`
	EndMs      int64  `json:"end_ms"`
	CharOffset int    `json:"char_offset"`
	// SynthFailed marks sentences that fell back to 1-second silence after
	// exhausting retries. Client should not hide these — just expect
	// silence where they are.
	SynthFailed bool `json:"synth_failed,omitempty"`
}

// SaveAlignment serialises alignment to path (0644). Uses a temp file + rename
// for atomic replacement so a crashed write never leaves a half-valid json.
func SaveAlignment(path string, a *ChapterAlignment) error {
	data, err := json.MarshalIndent(a, "", "  ")
	if err != nil {
		return fmt.Errorf("marshal alignment: %w", err)
	}
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, data, 0644); err != nil {
		return fmt.Errorf("write temp: %w", err)
	}
	if err := os.Rename(tmp, path); err != nil {
		return fmt.Errorf("rename: %w", err)
	}
	return nil
}

// LoadAlignment reads and parses a chapter_NNN.align.json file.
func LoadAlignment(path string) (*ChapterAlignment, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	data, err := io.ReadAll(f)
	if err != nil {
		return nil, err
	}
	var a ChapterAlignment
	if err := json.Unmarshal(data, &a); err != nil {
		return nil, fmt.Errorf("parse alignment: %w", err)
	}
	return &a, nil
}
