package opds

import "encoding/xml"

const (
	AtomNS   = "http://www.w3.org/2005/Atom"
	OpdsNS   = "http://opds-spec.org/2010/catalog"
	AtomTime = "2006-01-02T15:04:05Z"
	DirMime  = "application/atom+xml;profile=opds-catalog;kind=navigation"
	AcqMime  = "application/atom+xml;profile=opds-catalog;kind=acquisition"
	DirRel   = "subsection"
	FileRel  = "http://opds-spec.org/acquisition"
	CoverRel = "http://opds-spec.org/image"
	ThumbRel = "http://opds-spec.org/image/thumbnail"
)

type Feed struct {
	XMLName xml.Name `xml:"feed"`
	XMLNS   string   `xml:"xmlns,attr"`
	ID      string   `xml:"id"`
	Title   string   `xml:"title"`
	Updated string   `xml:"updated"`
	Author  *Author  `xml:"author,omitempty"`
	Link    []Link   `xml:"link"`
	Entry   []Entry  `xml:"entry"`
}

type Entry struct {
	ID      string   `xml:"id"`
	Title   string   `xml:"title"`
	Updated string   `xml:"updated"`
	Author  *Author  `xml:"author,omitempty"`
	Summary *Summary `xml:"summary,omitempty"`
	Content *Content `xml:"content,omitempty"`
	Link    []Link   `xml:"link"`
}

type Author struct {
	Name string `xml:"name"`
}

type Link struct {
	Href string `xml:"href,attr"`
	Type string `xml:"type,attr,omitempty"`
	Rel  string `xml:"rel,attr,omitempty"`
}

type Summary struct {
	Type string `xml:"type,attr,omitempty"`
	Text string `xml:",chardata"`
}

type Content struct {
	Type string `xml:"type,attr,omitempty"`
	Text string `xml:",chardata"`
}
