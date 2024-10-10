package conf

import (
	"encoding/json"
	"testing"
)

func TestInitConfig(t *testing.T) {

	err := InitConfig(`../../examples/app/conf.yaml`)

	if err != nil {
		t.Fatal(err)
	}

	j, _ := json.Marshal(GetConfig())

	println(string(j))

}

func TestSaveConfig(t *testing.T) {

	err := InitConfig(`../../examples/build/conf2.yaml`)

	if err != nil {
		t.Fatal(err)
	}

	got := GetConfig()

	j, _ := json.Marshal(got)

	println(string(j))

	got.M4tOptions.RemoteAddr = `192.168.1.1:53332`

	got.Save()

}
