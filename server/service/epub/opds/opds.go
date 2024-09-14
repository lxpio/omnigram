package opds

import (
	"encoding/xml"
	"time"
)

const (
	AtomTime = "2006-01-02T15:04:05Z"
	DirMime  = "application/atom+xml;profile=opds-catalog;kind=navigation"
	DirRel   = "subsection"
	FileRel  = "http://opds-spec.org/acquisition"
	CoverRel = "http://opds-spec.org/cover"
)

// Feed is a main frame of OPDS.
type Feed struct {
	XMLName   xml.Name `xml:"feed"`
	Xmlns     string   `xml:"xmlns,attr"`
	XmlnsDC   string   `xml:"xmlns:dc,omitempty,attr"`
	XmlnsOPDS string   `xml:"xmlns:opds,omitempty,attr"`

	ID         string     `xml:"id"`
	Title      string     `xml:"title"`
	Updated    string     `xml:"updated"`
	AuthorLink AuthorLink `xml:"author"`

	Link  []Link  `xml:"link"`
	Entry []Entry `xml:"entry"`
}

// Link is link properties.
type Link struct {
	Href string `xml:"href,attr"`
	Type string `xml:"type,attr"`
	Rel  string `xml:"rel,attr"`
}

// Entry is a struct of OPDS entry properties.
type Entry struct {
	ID      string  `xml:"id"`
	Updated string  `xml:"updated"`
	Title   string  `xml:"title"`
	Author  Author  `xml:"author"`
	Summary Summary `xml:"summary"`
	Link    []Link  `xml:"link"`
}

type Author struct {
	Name string `xml:"name"`
}

type AuthorLink struct {
	Name string `xml:"name"`
	URI  string `xml:"uri"`
}

type Summary struct {
	Type string `xml:"type,attr"`
	Text string `xml:",chardata"`
}

func BuildAcquisitionFeed(id, title, href string, entries []Entry) *Feed {

	return &Feed{
		ID:        id,
		Title:     title,
		Xmlns:     "http://www.w3.org/2005/Atom",
		XmlnsDC:   "http://purl.org/dc/terms/",
		XmlnsOPDS: "http://opds-spec.org/2010/catalog",
		Updated:   time.Now().UTC().Format(AtomTime),
		Link: []Link{
			{
				Href: href,
				Type: DirMime,
				Rel:  "start",
			},
			{
				Href: href,
				Type: DirMime,
				Rel:  "self",
			},
		},
		Entry: entries,
	}
}
