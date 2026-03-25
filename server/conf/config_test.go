package conf

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
)

func TestInitConfig(t *testing.T) {
	err := InitConfig(`conf.yaml`)
	if err != nil {
		t.Fatal(err)
	}

	j, _ := json.Marshal(GetConfig())
	t.Log(string(j))
}

func TestSaveConfig(t *testing.T) {
	// Copy conf.yaml to a temp file so Save() doesn't modify the original.
	src, err := os.ReadFile("conf.yaml")
	if err != nil {
		t.Fatal(err)
	}
	tmp := filepath.Join(t.TempDir(), "conf_test.yaml")
	if err := os.WriteFile(tmp, src, 0644); err != nil {
		t.Fatal(err)
	}

	if err := InitConfig(tmp); err != nil {
		t.Fatal(err)
	}

	got := GetConfig()
	j, _ := json.Marshal(got)
	t.Log(string(j))

	got.M4tOptions.RemoteAddr = `192.168.1.1:53332`
	if err := got.Save(); err != nil {
		t.Fatal(err)
	}
}
