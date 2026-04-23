package tts

import (
	"fmt"
	"io"
	"strings"

	"github.com/nexptr/epub"
	"golang.org/x/net/html"
)

// Chapter represents extracted chapter text from an EPUB.
type Chapter struct {
	Index     int        // 0-based position in spine
	Title     string     // extracted from <title> or <h1>-<h3>, or spine item href
	Href      string     // original spine item href
	Text      string     // cleaned plain text content
	Sentences []Sentence // sentence-level split of Text with char offsets
}

// ExtractChapters opens an EPUB and extracts plain text for each spine item.
// Only processes items with media-type "application/xhtml+xml".
func ExtractChapters(epubPath string) ([]Chapter, error) {
	e, err := epub.Open(epubPath)
	if err != nil {
		return nil, fmt.Errorf("open epub: %w", err)
	}
	defer e.Close()

	pkg, err := e.Package()
	if err != nil {
		return nil, fmt.Errorf("read package: %w", err)
	}

	// Build manifest ID → Item lookup.
	manifest := make(map[string]epub.Item, len(pkg.Manifest.Items))
	for _, item := range pkg.Manifest.Items {
		manifest[item.ID] = item
	}

	var chapters []Chapter
	for i, ref := range pkg.Spine.Itemrefs {
		item, ok := manifest[ref.IDref]
		if !ok {
			continue
		}
		if item.MediaType != "application/xhtml+xml" {
			continue
		}

		f, err := e.OpenItem(item.Href)
		if err != nil {
			continue
		}
		data, err := io.ReadAll(f)
		f.Close()
		if err != nil {
			continue
		}

		title, text := extractContent(string(data))
		text = strings.TrimSpace(text)
		if len(text) < 50 {
			continue
		}
		if title == "" {
			title = item.Href
		}

		chapters = append(chapters, Chapter{
			Index:     i,
			Title:     title,
			Href:      item.Href,
			Text:      text,
			Sentences: SplitSentences(text, DefaultSplitter()),
		})
	}

	return chapters, nil
}

// extractContent parses HTML and returns the title and cleaned plain text.
func extractContent(rawHTML string) (title, text string) {
	doc, err := html.Parse(strings.NewReader(rawHTML))
	if err != nil {
		return "", stripTags(rawHTML)
	}

	title = findTitle(doc)

	var buf strings.Builder
	extractText(doc, &buf)
	text = collapseWhitespace(buf.String())
	return title, text
}

// findTitle returns the first non-empty text from <title>, <h1>, <h2>, or <h3>.
func findTitle(n *html.Node) string {
	tags := []string{"title", "h1", "h2", "h3"}
	for _, tag := range tags {
		if t := findFirstTagText(n, tag); t != "" {
			return t
		}
	}
	return ""
}

// findFirstTagText returns the concatenated text content of the first element
// with the given tag name found via depth-first search.
func findFirstTagText(n *html.Node, tag string) string {
	if n.Type == html.ElementNode && n.Data == tag {
		return strings.TrimSpace(collectText(n))
	}
	for c := n.FirstChild; c != nil; c = c.NextSibling {
		if t := findFirstTagText(c, tag); t != "" {
			return t
		}
	}
	return ""
}

// collectText concatenates all text node descendants.
func collectText(n *html.Node) string {
	var buf strings.Builder
	var walk func(*html.Node)
	walk = func(node *html.Node) {
		if node.Type == html.TextNode {
			buf.WriteString(node.Data)
		}
		for c := node.FirstChild; c != nil; c = c.NextSibling {
			walk(c)
		}
	}
	walk(n)
	return buf.String()
}

// extractText walks the HTML tree and writes plain text to buf,
// inserting paragraph breaks around block elements.
func extractText(n *html.Node, buf *strings.Builder) {
	if n.Type == html.ElementNode {
		tag := n.Data
		// Skip <script> and <style> content entirely.
		if tag == "script" || tag == "style" {
			return
		}
		if isBlockTag(tag) {
			buf.WriteString("\n\n")
		}
	}
	if n.Type == html.TextNode {
		buf.WriteString(n.Data)
	}
	for c := n.FirstChild; c != nil; c = c.NextSibling {
		extractText(c, buf)
	}
	if n.Type == html.ElementNode && isBlockTag(n.Data) {
		buf.WriteString("\n\n")
	}
}

var blockTags = map[string]bool{
	"p": true, "div": true, "br": true,
	"h1": true, "h2": true, "h3": true, "h4": true, "h5": true, "h6": true,
	"blockquote": true, "pre": true, "li": true,
	"tr": true, "section": true, "article": true,
}

func isBlockTag(tag string) bool {
	return blockTags[tag]
}

// collapseWhitespace normalises whitespace: collapses runs of spaces/tabs
// within lines and limits consecutive blank lines to at most one.
func collapseWhitespace(s string) string {
	lines := strings.Split(s, "\n")
	var out []string
	blanks := 0
	for _, line := range lines {
		line = strings.Join(strings.Fields(line), " ")
		if line == "" {
			blanks++
			if blanks <= 2 {
				out = append(out, "")
			}
			continue
		}
		blanks = 0
		out = append(out, line)
	}
	return strings.TrimSpace(strings.Join(out, "\n"))
}

// stripTags is a simple fallback that removes anything between < and >.
func stripTags(s string) string {
	var buf strings.Builder
	inTag := false
	for _, r := range s {
		if r == '<' {
			inTag = true
			continue
		}
		if r == '>' {
			inTag = false
			continue
		}
		if !inTag {
			buf.WriteRune(r)
		}
	}
	return buf.String()
}
