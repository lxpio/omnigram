package tts

import (
	"encoding/json"
	"os"
	"testing"
)

// TestSplitterParity asserts the Go splitter matches the shared fixture file
// at testdata/splitter_parity.json. The Dart splitter test reads the same
// file. If either side changes the splitting algorithm, both tests must be
// updated in lockstep — that's the entire point of this fixture.
func TestSplitterParity(t *testing.T) {
	type expected struct {
		Text       string `json:"text"`
		CharOffset int    `json:"charOffset"`
	}
	type fixCase struct {
		Name     string     `json:"name"`
		Input    string     `json:"input"`
		Splitter *Splitter  `json:"splitter,omitempty"`
		Expected []expected `json:"expected"`
	}
	type fixture struct {
		Cases []fixCase `json:"cases"`
	}

	raw, err := os.ReadFile("testdata/splitter_parity.json")
	if err != nil {
		t.Fatalf("read fixture: %v", err)
	}
	var fix fixture
	if err := json.Unmarshal(raw, &fix); err != nil {
		t.Fatalf("parse fixture: %v", err)
	}

	for _, c := range fix.Cases {
		t.Run(c.Name, func(t *testing.T) {
			s := DefaultSplitter()
			if c.Splitter != nil {
				s = *c.Splitter
			}
			got := SplitSentences(c.Input, s)
			if len(got) != len(c.Expected) {
				t.Fatalf("len mismatch: got %d, want %d (%v)", len(got), len(c.Expected), got)
			}
			for i, want := range c.Expected {
				if got[i].Text != want.Text {
					t.Errorf("case %q sent %d text: got %q, want %q", c.Name, i, got[i].Text, want.Text)
				}
				if got[i].CharOffset != want.CharOffset {
					t.Errorf("case %q sent %d offset: got %d, want %d", c.Name, i, got[i].CharOffset, want.CharOffset)
				}
			}
		})
	}
}
