package fschat

import (
	"testing"

	"github.com/lxpio/omnigram/server/api/conf"
	"github.com/lxpio/omnigram/server/api/log"
	"go.uber.org/zap/zapcore"
)

func TestFromYaml(t *testing.T) {

	log.Init(`stdout`, zapcore.DebugLevel)
	got, err := conf.InitConfig(`../../../conf/conf.yaml`)

	if err != nil {
		t.Fatal(err)
	}

	for _, v := range got.ModelOptions {

		if conf.GetModelType(v.Name) == conf.ModelFSChat {

			// fsconf,err := json.Unmarshal(v.Settings)

			fsconf, err := FromYaml(v)
			if err != nil {
				t.Fatal(err)
			}
			log.D(fsconf.Endpoints)

		}

	}

	// j, err := json.Marshal(got)
	// if err != nil {
	// 	t.Fatal(err)
	// }
	// println(string(j))
}
