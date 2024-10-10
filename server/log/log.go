package log

import (
	"os"
	"path/filepath"

	"github.com/natefinch/lumberjack"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

type Level = zapcore.Level

type Logger struct {
	*zap.SugaredLogger
}

// global zap logger
var globalLog *Logger

func Init(dir string, level zapcore.Level) {

	if globalLog == nil {

		core := zapcore.NewCore(getEncoder(false), getWriter(dir, level), level)

		logger := zap.New(core, zap.AddCaller(), zap.AddCallerSkip(1))

		globalLog = &Logger{logger.Sugar()}

	}

}

// FlushLog 刷新日志,这里没有校验 globalLog 是否是 nil
func Flush() {
	if globalLog != nil {
		globalLog.Sync()
	}

}

// D 刷新日志,这里没有校验 globalLog 是否是 nil
func D(args ...interface{}) {
	globalLog.Debug(args...)
}

// I 刷新日志,这里没有校验 globalLog 是否是 nil
func I(args ...interface{}) {
	globalLog.Info(args...)
}

// E 刷新日志,这里没有校验 globalLog 是否是 nil
func E(args ...interface{}) {
	globalLog.Error(args...)
}

// W 刷新日志,这里没有校验 globalLog 是否是 nil
func W(args ...interface{}) {
	globalLog.Warn(args...)
}

// F 刷新日志,这里没有校验 globalLog 是否是 nil
func F(args ...interface{}) {
	globalLog.Fatal(args...)
}

func getEncoder(json bool) zapcore.Encoder {
	encoderConfig := zap.NewProductionEncoderConfig()
	encoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	encoderConfig.EncodeLevel = zapcore.CapitalLevelEncoder
	if json {
		return zapcore.NewJSONEncoder(encoderConfig)
	}
	return zapcore.NewConsoleEncoder(encoderConfig)
}

func getWriter(logDir string, lv Level) zapcore.WriteSyncer {

	if logDir == `stdout` {
		return zapcore.Lock(os.Stdout)
	}

	fileName := filepath.Join(logDir, "omnigram-server."+lv.CapitalString()+".log")

	lumberJackLogger := &lumberjack.Logger{
		Filename:   fileName,
		MaxSize:    300,
		MaxBackups: 50,
		MaxAge:     300,
		Compress:   true,
	}
	return zapcore.AddSync(lumberJackLogger)
}
