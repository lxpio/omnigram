package tts

// ProbeText returns a fixed synthesis prompt sized for ~5s of speech at 1.0×.
// We pick by voice locale prefix so RTF measurement is realistic for the voice
// the user actually has selected. Texts are deliberately neutral, ~120 chars.
func ProbeText(voiceLocale string) string {
	switch {
	case len(voiceLocale) >= 2 && voiceLocale[:2] == "zh":
		return "夜色降临得很慢。窗外的灯火一盏接一盏亮起，像一行被风轻轻翻开的诗。屋子里只有钟摆的声音，安静得让人想起很多年前的事。"
	case len(voiceLocale) >= 2 && voiceLocale[:2] == "ja":
		return "夜はゆっくりと訪れた。窓の外の灯りが一つ、また一つと点り、まるで風がそっとめくる詩の一行のようだった。部屋には時計の音だけが響いていた。"
	default:
		return "Evening fell slowly. Outside the window, lamps lit one by one, like a line of poetry the wind had quietly turned. Only the clock ticked in the still room."
	}
}
