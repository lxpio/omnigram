package tts

// ProbeText returns a single sentence sized to match the per-sentence chunks
// LiveServerSource actually requests at runtime. Earlier versions used a
// 120-char paragraph and produced wildly pessimistic RTF on non-streaming
// providers (e.g. Qwen3-TTS) that synthesise the whole input before sending
// any bytes — those servers can keep up fine on per-sentence chunks but get
// classified RED on a paragraph-sized probe. The shorter prompt mirrors the
// real workload.
func ProbeText(voiceLocale string) string {
	switch {
	case len(voiceLocale) >= 2 && voiceLocale[:2] == "zh":
		return "窗外的灯火一盏接一盏亮起。"
	case len(voiceLocale) >= 2 && voiceLocale[:2] == "ja":
		return "窓の外の灯りが一つずつ点り始めた。"
	default:
		return "Evening lamps lit one by one outside the window."
	}
}
