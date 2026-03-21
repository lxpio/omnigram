package tts

import (
	"strings"
	"unicode/utf8"
)

// ChunkOptions configures text chunking behavior.
type ChunkOptions struct {
	MaxChunkSize int // max characters per chunk (default: 500 for Kokoro)
}

// DefaultChunkOptions returns defaults for Kokoro.
func DefaultChunkOptions() ChunkOptions {
	return ChunkOptions{MaxChunkSize: 500}
}

// ChunkOptionsForProvider returns appropriate chunk size for a provider.
func ChunkOptionsForProvider(provider string) ChunkOptions {
	switch provider {
	case "kokoro", "sidecar":
		return ChunkOptions{MaxChunkSize: 500}
	case "edge":
		return ChunkOptions{MaxChunkSize: 2500}
	case "openai":
		return ChunkOptions{MaxChunkSize: 4000}
	default:
		return DefaultChunkOptions()
	}
}

// abbreviations that end with a period but are not sentence terminators.
var abbreviations = []string{"Mr.", "Dr.", "Mrs.", "Jr.", "Sr.", "vs."}

// ChunkText splits text into chunks that respect sentence boundaries.
//
// Algorithm:
//  1. Split text into sentences using sentence-ending punctuation (. ! ? 。！？… and paragraph breaks)
//  2. Greedily accumulate sentences into chunks up to MaxChunkSize
//  3. If a single sentence exceeds MaxChunkSize, split at clause boundaries (, ; : 、，；：—)
//  4. If still too long, hard-split at MaxChunkSize (last resort)
//  5. Trim whitespace from each chunk, skip empty chunks
func ChunkText(text string, opts ChunkOptions) []string {
	if opts.MaxChunkSize <= 0 {
		opts.MaxChunkSize = DefaultChunkOptions().MaxChunkSize
	}

	text = strings.TrimSpace(text)
	if len(text) == 0 {
		return nil
	}

	sentences := splitSentences(text)
	if len(sentences) == 0 {
		return nil
	}

	var chunks []string
	var current strings.Builder

	for _, sent := range sentences {
		sent = strings.TrimSpace(sent)
		if len(sent) == 0 {
			continue
		}

		sentLen := utf8.RuneCountInString(sent)

		if current.Len() == 0 {
			if sentLen <= opts.MaxChunkSize {
				current.WriteString(sent)
			} else {
				// Single sentence exceeds limit — break it down further.
				parts := splitOversized(sent, opts.MaxChunkSize)
				for _, p := range parts {
					chunks = append(chunks, p)
				}
			}
			continue
		}

		combined := utf8.RuneCountInString(current.String()) + 1 + sentLen // +1 for space
		if combined <= opts.MaxChunkSize {
			current.WriteRune(' ')
			current.WriteString(sent)
		} else {
			// Flush current chunk and start new one.
			chunks = append(chunks, current.String())
			current.Reset()
			if sentLen <= opts.MaxChunkSize {
				current.WriteString(sent)
			} else {
				parts := splitOversized(sent, opts.MaxChunkSize)
				for _, p := range parts {
					chunks = append(chunks, p)
				}
			}
		}
	}

	if current.Len() > 0 {
		chunks = append(chunks, current.String())
	}

	if len(chunks) == 0 {
		return nil
	}
	return chunks
}

// splitSentences splits text into sentences at sentence-ending punctuation,
// keeping the punctuation attached to the preceding text.
func splitSentences(text string) []string {
	// First split on paragraph breaks.
	paragraphs := splitParagraphs(text)

	var sentences []string
	for _, para := range paragraphs {
		para = strings.TrimSpace(para)
		if len(para) == 0 {
			continue
		}
		sentences = append(sentences, splitSentencesInParagraph(para)...)
	}
	return sentences
}

func splitParagraphs(text string) []string {
	return strings.Split(text, "\n\n")
}

func splitSentencesInParagraph(text string) []string {
	var sentences []string
	runes := []rune(text)
	start := 0

	for i := 0; i < len(runes); i++ {
		r := runes[i]
		if !isSentenceEnd(r) {
			continue
		}

		// Handle period specially: skip abbreviations and decimal numbers.
		if r == '.' {
			if isAbbreviation(runes, i) || isDecimalPoint(runes, i) {
				continue
			}
		}

		// Handle ellipsis: consume consecutive dots or '…'.
		end := i + 1
		if r == '.' {
			for end < len(runes) && runes[end] == '.' {
				end++
			}
		}

		// Include any trailing closing quotes/brackets.
		for end < len(runes) && isClosingMark(runes[end]) {
			end++
		}

		sent := strings.TrimSpace(string(runes[start:end]))
		if len(sent) > 0 {
			sentences = append(sentences, sent)
		}
		start = end
		i = end - 1
	}

	// Remaining text.
	if start < len(runes) {
		sent := strings.TrimSpace(string(runes[start:]))
		if len(sent) > 0 {
			sentences = append(sentences, sent)
		}
	}

	return sentences
}

func isSentenceEnd(r rune) bool {
	switch r {
	case '.', '!', '?', '。', '！', '？', '…':
		return true
	}
	return false
}

func isClosingMark(r rune) bool {
	switch r {
	case '"', '\'', ')', ']', '\u201D', '\u2019', '\u300D', '\u300F', '\u300B', '\uFF09':
		return true
	}
	return false
}

// isAbbreviation checks whether the period at runes[pos] is part of a known abbreviation.
func isAbbreviation(runes []rune, pos int) bool {
	textUpTo := string(runes[:pos+1])
	for _, abbr := range abbreviations {
		if strings.HasSuffix(textUpTo, abbr) {
			// Make sure it's a word boundary before the abbreviation.
			idx := len(textUpTo) - len(abbr)
			if idx == 0 || runes[idx-1] == ' ' || runes[idx-1] == '\n' {
				return true
			}
		}
	}
	return false
}

// isDecimalPoint checks whether the period at runes[pos] sits between two digits (e.g. 3.14).
func isDecimalPoint(runes []rune, pos int) bool {
	if pos > 0 && pos < len(runes)-1 {
		return isDigit(runes[pos-1]) && isDigit(runes[pos+1])
	}
	return false
}

func isDigit(r rune) bool {
	return r >= '0' && r <= '9'
}

// splitOversized breaks an oversized sentence first at clause boundaries,
// then hard-splits any remaining oversized pieces.
func splitOversized(text string, maxSize int) []string {
	// Try clause-level splitting first.
	clauses := splitAtClauseBoundaries(text)
	if len(clauses) > 1 {
		// Re-accumulate clauses into chunks.
		var result []string
		var current strings.Builder
		for _, cl := range clauses {
			cl = strings.TrimSpace(cl)
			if len(cl) == 0 {
				continue
			}
			clLen := utf8.RuneCountInString(cl)

			if current.Len() == 0 {
				if clLen <= maxSize {
					current.WriteString(cl)
				} else {
					result = append(result, hardSplit(cl, maxSize)...)
				}
				continue
			}

			combined := utf8.RuneCountInString(current.String()) + 1 + clLen
			if combined <= maxSize {
				current.WriteRune(' ')
				current.WriteString(cl)
			} else {
				result = append(result, current.String())
				current.Reset()
				if clLen <= maxSize {
					current.WriteString(cl)
				} else {
					result = append(result, hardSplit(cl, maxSize)...)
				}
			}
		}
		if current.Len() > 0 {
			result = append(result, current.String())
		}
		return result
	}

	// No clause boundaries found — hard split.
	return hardSplit(text, maxSize)
}

// splitAtClauseBoundaries splits text at secondary punctuation marks,
// keeping the punctuation with the preceding text.
func splitAtClauseBoundaries(text string) []string {
	var parts []string
	runes := []rune(text)
	start := 0

	for i := 0; i < len(runes); i++ {
		if isClauseBoundary(runes[i]) {
			// Include the punctuation character in the current part.
			end := i + 1
			part := strings.TrimSpace(string(runes[start:end]))
			if len(part) > 0 {
				parts = append(parts, part)
			}
			start = end
		}
	}

	if start < len(runes) {
		part := strings.TrimSpace(string(runes[start:]))
		if len(part) > 0 {
			parts = append(parts, part)
		}
	}

	return parts
}

func isClauseBoundary(r rune) bool {
	switch r {
	case ',', ';', ':', '、', '，', '；', '：', '—':
		return true
	}
	return false
}

// hardSplit splits text at exactly maxSize rune boundaries as a last resort.
func hardSplit(text string, maxSize int) []string {
	runes := []rune(text)
	var parts []string
	for len(runes) > 0 {
		end := maxSize
		if end > len(runes) {
			end = len(runes)
		}
		part := strings.TrimSpace(string(runes[:end]))
		if len(part) > 0 {
			parts = append(parts, part)
		}
		runes = runes[end:]
	}
	return parts
}
