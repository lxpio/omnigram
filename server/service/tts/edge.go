package tts

import (
	"bytes"
	"context"
	"encoding/binary"
	"fmt"
	"io"
	"net/http"
	"strings"
	"sync"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"github.com/lxpio/omnigram/server/log"
)

const (
	edgeWSURL        = "wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1"
	edgeTrustedToken = "6A5AA1D4EAFF4E9FB37E23D68491D6F4"
	edgeOrigin       = "chrome-extension://jdiccldimpdaibmpdmdber"
	edgeUserAgent    = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0"
	edgeOutputFormat = "audio-24khz-48kbitrate-mono-mp3"
)

// EdgeTTSProvider calls Microsoft Edge TTS free API directly.
// ⚠️ Non-official API, no SLA, may be rate-limited or discontinued.
type EdgeTTSProvider struct {
	mu     sync.Mutex
	voices []Voice
}

func NewEdgeTTSProvider() *EdgeTTSProvider {
	return &EdgeTTSProvider{
		voices: defaultEdgeVoices(),
	}
}

func (p *EdgeTTSProvider) Name() string { return "edge" }

func (p *EdgeTTSProvider) Synthesize(ctx context.Context, text string, opts SynthesisOptions) (io.ReadCloser, error) {
	voice := opts.Voice
	if voice == "" {
		voice = "zh-CN-XiaoxiaoNeural"
	}
	lang := opts.Language
	if lang == "" {
		lang = langFromVoice(voice)
	}

	ssml := buildSSML(text, voice, lang)

	pr, pw := io.Pipe()
	go func() {
		pw.CloseWithError(p.synthesizeWS(ctx, ssml, pw))
	}()
	return pr, nil
}

func (p *EdgeTTSProvider) synthesizeWS(ctx context.Context, ssml string, w io.Writer) error {
	connID := newUUID()
	reqID := newUUID()

	wsURL := fmt.Sprintf("%s?TrustedClientToken=%s&ConnectionId=%s", edgeWSURL, edgeTrustedToken, connID)

	dialer := websocket.Dialer{}
	header := http.Header{}
	header.Set("Origin", edgeOrigin)
	header.Set("User-Agent", edgeUserAgent)

	conn, _, err := dialer.DialContext(ctx, wsURL, header)
	if err != nil {
		return fmt.Errorf("edge tts: websocket dial: %w", err)
	}
	defer conn.Close()

	// Send config message
	configMsg := "Content-Type:application/json; charset=utf-8\r\nPath:speech.config\r\n\r\n" +
		`{"context":{"synthesis":{"audio":{"metadataoptions":{"sentenceBoundaryEnabled":"false","wordBoundaryEnabled":"true"},"outputFormat":"` + edgeOutputFormat + `"}}}}`
	if err := conn.WriteMessage(websocket.TextMessage, []byte(configMsg)); err != nil {
		return fmt.Errorf("edge tts: send config: %w", err)
	}

	// Send SSML message
	ssmlMsg := fmt.Sprintf("X-RequestId:%s\r\nContent-Type:application/ssml+xml\r\nPath:ssml\r\n\r\n%s", reqID, ssml)
	if err := conn.WriteMessage(websocket.TextMessage, []byte(ssmlMsg)); err != nil {
		return fmt.Errorf("edge tts: send ssml: %w", err)
	}

	// Receive audio frames
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
		}

		msgType, data, err := conn.ReadMessage()
		if err != nil {
			return fmt.Errorf("edge tts: read message: %w", err)
		}

		switch msgType {
		case websocket.TextMessage:
			if strings.Contains(string(data), "Path:turn.end") {
				return nil
			}
		case websocket.BinaryMessage:
			audio := extractAudioFromBinary(data)
			if len(audio) > 0 {
				if _, err := w.Write(audio); err != nil {
					return fmt.Errorf("edge tts: write audio: %w", err)
				}
			}
		}
	}
}

// extractAudioFromBinary parses binary frames from Edge TTS.
// Format: 2-byte header length (big-endian) + header bytes + audio data.
func extractAudioFromBinary(data []byte) []byte {
	if len(data) < 2 {
		return nil
	}
	headerLen := int(binary.BigEndian.Uint16(data[:2]))
	offset := 2 + headerLen
	if offset > len(data) {
		return nil
	}
	// Verify this is an audio frame by checking the header
	header := string(data[2:offset])
	if !strings.Contains(header, "Path:audio") {
		return nil
	}
	return data[offset:]
}

func buildSSML(text, voice, lang string) string {
	// Escape XML special characters in text
	text = xmlEscape(text)
	var buf bytes.Buffer
	buf.WriteString(`<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='`)
	buf.WriteString(lang)
	buf.WriteString(`'><voice name='`)
	buf.WriteString(voice)
	buf.WriteString(`'><prosody pitch='+0Hz' rate='+0%' volume='+0%'>`)
	buf.WriteString(text)
	buf.WriteString(`</prosody></voice></speak>`)
	return buf.String()
}

func xmlEscape(s string) string {
	s = strings.ReplaceAll(s, "&", "&amp;")
	s = strings.ReplaceAll(s, "<", "&lt;")
	s = strings.ReplaceAll(s, ">", "&gt;")
	s = strings.ReplaceAll(s, "'", "&apos;")
	s = strings.ReplaceAll(s, "\"", "&quot;")
	return s
}

func langFromVoice(voice string) string {
	// Voice IDs follow the pattern "xx-YY-NameNeural"
	parts := strings.SplitN(voice, "-", 3)
	if len(parts) >= 2 {
		return parts[0] + "-" + parts[1]
	}
	return "zh-CN"
}

func newUUID() string {
	return strings.ReplaceAll(uuid.New().String(), "-", "")
}

func (p *EdgeTTSProvider) Voices() []Voice {
	p.mu.Lock()
	defer p.mu.Unlock()
	return p.voices
}

func (p *EdgeTTSProvider) SupportsStreaming() bool { return true }

func (p *EdgeTTSProvider) HealthCheck(ctx context.Context) error {
	connID := newUUID()
	wsURL := fmt.Sprintf("%s?TrustedClientToken=%s&ConnectionId=%s", edgeWSURL, edgeTrustedToken, connID)
	dialer := websocket.Dialer{}
	header := http.Header{}
	header.Set("Origin", edgeOrigin)
	header.Set("User-Agent", edgeUserAgent)

	conn, _, err := dialer.DialContext(ctx, wsURL, header)
	if err != nil {
		return fmt.Errorf("edge tts health check: %w", err)
	}
	conn.Close()
	log.I("edge tts: health check passed")
	return nil
}

func defaultEdgeVoices() []Voice {
	return []Voice{
		// zh-CN
		{ID: "zh-CN-XiaoxiaoNeural", Name: "Xiaoxiao", Language: "zh-CN", Gender: "female"},
		{ID: "zh-CN-YunxiNeural", Name: "Yunxi", Language: "zh-CN", Gender: "male"},
		{ID: "zh-CN-YunjianNeural", Name: "Yunjian", Language: "zh-CN", Gender: "male"},
		// en-US
		{ID: "en-US-JennyNeural", Name: "Jenny", Language: "en-US", Gender: "female"},
		{ID: "en-US-GuyNeural", Name: "Guy", Language: "en-US", Gender: "male"},
		{ID: "en-US-AriaNeural", Name: "Aria", Language: "en-US", Gender: "female"},
		// en-GB
		{ID: "en-GB-SoniaNeural", Name: "Sonia", Language: "en-GB", Gender: "female"},
		{ID: "en-GB-RyanNeural", Name: "Ryan", Language: "en-GB", Gender: "male"},
		{ID: "en-GB-LibbyNeural", Name: "Libby", Language: "en-GB", Gender: "female"},
		// ja-JP
		{ID: "ja-JP-NanamiNeural", Name: "Nanami", Language: "ja-JP", Gender: "female"},
		{ID: "ja-JP-KeitaNeural", Name: "Keita", Language: "ja-JP", Gender: "male"},
		{ID: "ja-JP-AoiNeural", Name: "Aoi", Language: "ja-JP", Gender: "female"},
		// ko-KR
		{ID: "ko-KR-SunHiNeural", Name: "SunHi", Language: "ko-KR", Gender: "female"},
		{ID: "ko-KR-InJoonNeural", Name: "InJoon", Language: "ko-KR", Gender: "male"},
		{ID: "ko-KR-BongJinNeural", Name: "BongJin", Language: "ko-KR", Gender: "male"},
		// de-DE
		{ID: "de-DE-KatjaNeural", Name: "Katja", Language: "de-DE", Gender: "female"},
		{ID: "de-DE-ConradNeural", Name: "Conrad", Language: "de-DE", Gender: "male"},
		{ID: "de-DE-AmalaNeural", Name: "Amala", Language: "de-DE", Gender: "female"},
		// fr-FR
		{ID: "fr-FR-DeniseNeural", Name: "Denise", Language: "fr-FR", Gender: "female"},
		{ID: "fr-FR-HenriNeural", Name: "Henri", Language: "fr-FR", Gender: "male"},
		{ID: "fr-FR-EloiseNeural", Name: "Eloise", Language: "fr-FR", Gender: "female"},
		// es-ES
		{ID: "es-ES-ElviraNeural", Name: "Elvira", Language: "es-ES", Gender: "female"},
		{ID: "es-ES-AlvaroNeural", Name: "Alvaro", Language: "es-ES", Gender: "male"},
		{ID: "es-ES-AbrilNeural", Name: "Abril", Language: "es-ES", Gender: "female"},
	}
}
