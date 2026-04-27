package schema

// ProbeResult is the response body of POST /tts/probe.
// All durations are milliseconds. RTF (real-time factor) is
// synthesis_duration_ms / audio_duration_ms — values < 1.0 mean
// the server can render faster than realtime.
type ProbeResult struct {
	FirstByteMs     int64   `json:"first_byte_ms"`
	TotalMs         int64   `json:"total_ms"`
	AudioDurationMs int64   `json:"audio_duration_ms"`
	RTF             float64 `json:"rtf"`
	Voice           string  `json:"voice"`
	Provider        string  `json:"provider"`
	ServerBuild     string  `json:"server_build"`
}
