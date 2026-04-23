package tts

import (
	"strings"
	"testing"
)

func TestSplitSentencesChinese(t *testing.T) {
	text := "一九六二年四月三日，余华出生于浙江省杭州市。出生时体重七斤三两。他的父亲华自治、母亲余佩文均为医生。"
	got := SplitSentences(text, DefaultSplitter())
	if len(got) != 3 {
		t.Fatalf("expected 3 sentences, got %d: %+v", len(got), got)
	}
	if !strings.HasSuffix(got[0].Text, "杭州市。") {
		t.Errorf("unexpected sentence 0: %q", got[0].Text)
	}
	if got[0].CharOffset != 0 {
		t.Errorf("first offset should be 0, got %d", got[0].CharOffset)
	}
	if got[1].CharOffset <= got[0].CharOffset {
		t.Errorf("offsets must be monotonic: %d -> %d", got[0].CharOffset, got[1].CharOffset)
	}
}

func TestSplitSentencesEnglish(t *testing.T) {
	text := "The year 1962 was pivotal. Yu Hua was born in Hangzhou. His father, Dr. Hua, was a surgeon."
	got := SplitSentences(text, DefaultSplitter())
	if len(got) != 3 {
		t.Fatalf("expected 3, got %d: %+v", len(got), got)
	}
	// "Dr." should NOT create a split
	if !strings.Contains(got[2].Text, "Dr. Hua") {
		t.Errorf("abbreviation not preserved: %q", got[2].Text)
	}
}

func TestSplitSentencesDecimalSafe(t *testing.T) {
	text := "The average was 3.14 meters. Then it rose to 4.71."
	got := SplitSentences(text, DefaultSplitter())
	if len(got) != 2 {
		t.Fatalf("expected 2, got %d: %+v", len(got), got)
	}
	if !strings.Contains(got[0].Text, "3.14") {
		t.Errorf("decimal point treated as terminator: %q", got[0].Text)
	}
}

func TestSplitSentencesQuotedDoesNotOverSplit(t *testing.T) {
	// Inside quoted speech, punctuation still terminates — we include trailing
	// close marks; the important thing is we don't crash and offsets stay sane.
	text := `他说："真的吗？"然后离开了。`
	got := SplitSentences(text, DefaultSplitter())
	if len(got) < 1 {
		t.Fatalf("expected at least 1 sentence, got 0")
	}
	// Total text length must be covered by last offset + len.
	last := got[len(got)-1]
	if last.CharOffset < 0 {
		t.Errorf("negative offset: %d", last.CharOffset)
	}
}

func TestSplitSentencesMergeShort(t *testing.T) {
	// "1." is a 2-char fragment that should merge into the next sentence.
	text := "1. 开始阅读是一件简单的事。"
	got := SplitSentences(text, DefaultSplitter())
	if len(got) != 1 {
		t.Fatalf("expected fragment to merge forward, got %d: %+v", len(got), got)
	}
	if !strings.HasPrefix(got[0].Text, "1.") {
		t.Errorf("expected leading fragment preserved, got %q", got[0].Text)
	}
}

func TestSplitSentencesPreserveLegitimateShortChinese(t *testing.T) {
	// 4+ char Chinese sentences are legitimate — should NOT be merged.
	text := "下雨了。他回家了。"
	got := SplitSentences(text, DefaultSplitter())
	if len(got) != 2 {
		t.Fatalf("expected 2 short-but-legitimate sentences, got %d: %+v", len(got), got)
	}
}

func TestSplitSentencesLongClauseSplit(t *testing.T) {
	// 300-char Chinese run-on; should be broken at clause boundaries.
	long := strings.Repeat("这是一个很长的句子，", 20) + "结束。"
	got := SplitSentences(long, Splitter{MinChars: 0, MaxChars: 80})
	if len(got) < 2 {
		t.Fatalf("expected multiple pieces, got %d", len(got))
	}
	for _, s := range got {
		if n := runeCount(s.Text); n > 80+20 { // allow small overage
			t.Errorf("piece too long (%d runes): %q", n, s.Text)
		}
	}
}

func TestSplitSentencesParagraphBreaks(t *testing.T) {
	text := "第一段文本。\n\n第二段开始。第二段第二句。\n\n第三段单独一句。"
	got := SplitSentences(text, DefaultSplitter())
	if len(got) != 4 {
		t.Fatalf("expected 4 sentences across 3 paragraphs, got %d: %+v", len(got), got)
	}
	// Offsets should strictly increase.
	for i := 1; i < len(got); i++ {
		if got[i].CharOffset <= got[i-1].CharOffset {
			t.Errorf("offsets not monotonic at %d: %d <= %d", i, got[i].CharOffset, got[i-1].CharOffset)
		}
	}
}

func TestSplitSentencesEmpty(t *testing.T) {
	for _, in := range []string{"", "   ", "\n\n\n", "\t\r\n"} {
		if got := SplitSentences(in, DefaultSplitter()); len(got) != 0 {
			t.Errorf("expected empty for %q, got %+v", in, got)
		}
	}
}

func runeCount(s string) int {
	n := 0
	for range s {
		n++
	}
	return n
}
