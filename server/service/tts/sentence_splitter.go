package tts

import (
	"strings"
	"unicode/utf8"
)

// Sentence is a single unit of synthesis and alignment.
//
// CharOffset is the rune offset into the *original chapter text* where this
// sentence starts. Clients use it for fallback text matching when their own
// sentence splitter disagrees slightly with ours.
type Sentence struct {
	Text       string
	CharOffset int
}

// Splitter configures sentence splitting behavior. Zero value gives sensible
// defaults for mixed Chinese/English books.
type Splitter struct {
	// Language hint — currently only affects `.` handling. "en" treats
	// period-as-terminator more aggressively; other langs rely on other
	// punctuation since `.` is common in numbers/decimals in CJK text.
	Lang string

	// Sentences shorter than this many runes are merged into the previous
	// sentence to avoid fragments like "a." or "1." appearing as standalone.
	MinChars int

	// Sentences longer than this many runes are split at clause boundaries
	// (,;:、，；：—) to keep synthesis chunks tractable.
	MaxChars int
}

// DefaultSplitter returns the recommended configuration for audiobook alignment:
// merge <4-char fragments (numeric bullets, stray punctuation), split >200-char
// run-on sentences. Chinese sentences as short as 4 characters are common and
// legitimate — we keep them as independent sentences, only attacking obvious
// fragments like "1." "a." or "—".
func DefaultSplitter() Splitter {
	return Splitter{Lang: "", MinChars: 4, MaxChars: 200}
}

// SplitSentences extracts sentence-level units from text, preserving the
// original character offset of each sentence in the source.
//
// The algorithm reuses the battle-tested punctuation rules from text_chunker
// (abbreviations, decimal points, ellipsis, trailing close marks) and adds:
//
//  1. Paragraph break (\n\n) is a hard boundary.
//  2. Merge-short: sentences shorter than MinChars glue onto the previous one.
//  3. Split-long: sentences longer than MaxChars are split at clause
//     boundaries; purely hard-splitting only as last resort.
//
// The returned slice always has CharOffset monotonically increasing and
// Text non-empty.
func SplitSentences(text string, s Splitter) []Sentence {
	if s.MinChars == 0 && s.MaxChars == 0 {
		s = DefaultSplitter()
	}
	if s.MinChars < 0 {
		s.MinChars = 0
	}
	if s.MaxChars <= 0 {
		s.MaxChars = 200
	}

	text = strings.TrimRight(text, " \t\n\r")
	if len(text) == 0 {
		return nil
	}

	raw := splitWithOffsets(text)
	if len(raw) == 0 {
		return nil
	}

	// Merge-short: glue fragments onto adjacent sentences. Prefer merging into
	// the previous sentence; if there is none (fragment at start), buffer and
	// attach to the next. This keeps "1. First real sentence." as a single
	// sentence rather than leaving "1." as a standalone.
	merged := make([]Sentence, 0, len(raw))
	var pending *Sentence // buffered leading fragment awaiting a successor
	for i := range raw {
		sent := raw[i]
		runeCount := utf8.RuneCountInString(sent.Text)
		if runeCount < s.MinChars {
			if len(merged) > 0 {
				prev := &merged[len(merged)-1]
				prev.Text = prev.Text + " " + sent.Text
				continue
			}
			// Hold as pending to merge into the next real sentence.
			if pending == nil {
				pending = &Sentence{Text: sent.Text, CharOffset: sent.CharOffset}
			} else {
				pending.Text = pending.Text + " " + sent.Text
			}
			continue
		}
		if pending != nil {
			sent.Text = pending.Text + " " + sent.Text
			sent.CharOffset = pending.CharOffset
			pending = nil
		}
		merged = append(merged, sent)
	}
	if pending != nil {
		// No successor for trailing fragment — keep it rather than dropping.
		merged = append(merged, *pending)
	}

	// Split-long: break oversized sentences at clause boundaries.
	final := make([]Sentence, 0, len(merged))
	for _, sent := range merged {
		if utf8.RuneCountInString(sent.Text) <= s.MaxChars {
			final = append(final, sent)
			continue
		}
		for _, piece := range splitLongSentence(sent.Text, sent.CharOffset, s.MaxChars) {
			final = append(final, piece)
		}
	}

	return final
}

// splitWithOffsets walks the text and produces sentences tagged with their
// starting rune offset in the original string. Uses the same punctuation
// rules as text_chunker's splitSentencesInParagraph, applied after splitting
// on paragraph breaks.
func splitWithOffsets(text string) []Sentence {
	var result []Sentence

	runes := []rune(text)
	paragraphStart := 0

	flushParagraph := func(paraStart, paraEnd int) {
		para := runes[paraStart:paraEnd]
		if len(para) == 0 {
			return
		}
		// Per-paragraph sentence split.
		sentStart := 0
		for i := 0; i < len(para); i++ {
			r := para[i]
			if !isSentenceEnd(r) {
				continue
			}
			if r == '.' {
				if isAbbreviation(para, i) || isDecimalPoint(para, i) {
					continue
				}
			}
			end := i + 1
			if r == '.' {
				for end < len(para) && para[end] == '.' {
					end++
				}
			}
			for end < len(para) && isClosingMark(para[end]) {
				end++
			}

			emit(para, sentStart, end, paraStart, &result)
			sentStart = end
			i = end - 1
		}
		if sentStart < len(para) {
			emit(para, sentStart, len(para), paraStart, &result)
		}
	}

	// Scan for \n\n paragraph breaks.
	for i := 0; i < len(runes); i++ {
		if runes[i] == '\n' && i+1 < len(runes) && runes[i+1] == '\n' {
			flushParagraph(paragraphStart, i)
			// Skip all consecutive newlines / whitespace into next paragraph start.
			j := i + 2
			for j < len(runes) && (runes[j] == '\n' || runes[j] == ' ' || runes[j] == '\t' || runes[j] == '\r') {
				j++
			}
			paragraphStart = j
			i = j - 1
		}
	}
	flushParagraph(paragraphStart, len(runes))

	return result
}

// emit trims leading/trailing whitespace from runes[start:end] but reports the
// untrimmed start offset (shifted for leading whitespace) into the overall
// paragraph. This keeps CharOffset aligned with the first non-space rune.
func emit(para []rune, start, end, paraOffset int, out *[]Sentence) {
	lead := start
	for lead < end && isSpace(para[lead]) {
		lead++
	}
	trail := end
	for trail > lead && isSpace(para[trail-1]) {
		trail--
	}
	if trail <= lead {
		return
	}
	*out = append(*out, Sentence{
		Text:       string(para[lead:trail]),
		CharOffset: paraOffset + lead,
	})
}

func isSpace(r rune) bool {
	return r == ' ' || r == '\t' || r == '\n' || r == '\r' || r == '\u00A0'
}

// splitLongSentence breaks an oversized sentence at clause boundaries first,
// then hard-splits remaining pieces. Each piece carries a CharOffset pointing
// back into the original chapter text.
func splitLongSentence(text string, baseOffset int, maxChars int) []Sentence {
	runes := []rune(text)
	var pieces []Sentence

	// Greedy accumulator: collect runes until we pass a clause boundary AND
	// the accumulator is >= maxChars/2. This avoids chopping every clause
	// even when the sentence could legitimately be a bit long.
	targetMin := maxChars / 2
	if targetMin < 20 {
		targetMin = 20
	}

	start := 0
	for i := 0; i < len(runes); i++ {
		if !isClauseBoundary(runes[i]) {
			continue
		}
		end := i + 1
		currentLen := end - start
		if currentLen >= targetMin {
			emitPiece(runes, start, end, baseOffset, &pieces)
			start = end
			i = end - 1
		}
	}
	if start < len(runes) {
		// Remaining tail; if still oversized, hard split.
		remain := runes[start:]
		if len(remain) > maxChars {
			for len(remain) > 0 {
				end := maxChars
				if end > len(remain) {
					end = len(remain)
				}
				emitPiece(remain, 0, end, baseOffset+start, &pieces)
				start += end
				remain = remain[end:]
			}
		} else {
			emitPiece(runes, start, len(runes), baseOffset, &pieces)
		}
	}

	if len(pieces) == 0 {
		pieces = append(pieces, Sentence{Text: text, CharOffset: baseOffset})
	}
	return pieces
}

func emitPiece(runes []rune, start, end, baseOffset int, out *[]Sentence) {
	lead := start
	for lead < end && isSpace(runes[lead]) {
		lead++
	}
	trail := end
	for trail > lead && isSpace(runes[trail-1]) {
		trail--
	}
	if trail <= lead {
		return
	}
	*out = append(*out, Sentence{
		Text:       string(runes[lead:trail]),
		CharOffset: baseOffset + lead,
	})
}
