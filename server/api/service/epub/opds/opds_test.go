package opds

import (
	"encoding/xml"
	"os"
	"testing"
)

func TestBuildAcquisitionFeed(t *testing.T) {

	feed := BuildAcquisitionFeed(`Omnigram Library`, `Books`, `href`, nil)

	output, err := xml.MarshalIndent(feed, "  ", "    ")

	if err != nil {
		println(err.Error())
	}
	// enc := xml.NewEncoder(os.Stdout)
	// err := enc.Encode(&feed)
	os.Stdout.Write(output)

}
