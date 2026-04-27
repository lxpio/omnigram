# TTS Adaptive Routing — Implementation Plan (1 of 2)

> **Spec:** `docs/superpowers/specs/2026-04-27-tts-adaptive-degradation-design.md`
> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the routing backbone so that a user with a slow Omnigram server gets local sherpa-onnx playback immediately while the server pre-generates the high-quality version in the background, with chapter-boundary upgrade — all without UI noise. Now-Playing experience (mini bar / full-screen / pill) is **Plan 2**.

**Architecture:** Server adds a synchronous `/tts/probe` endpoint that measures first-byte latency and RTF for the user's selected voice. App caches the result per `(server, voice)` for 7 days, runs a pure `tts_router` function that maps `(capability, chapter_status, override) → PlaybackMode`, and dispatches playback through one of three `TtsAudioSource` implementations (`LiveServerSource`, `PregenServerSource`, `LocalFallbackSource`) sharing a common interface. Adaptive routing only applies when the user's selected voice is an Omnigram-server voice; sherpa-onnx / edge / cloud voices keep their existing direct paths.

**Tech Stack:** Go 1.23 (Gin, GORM), Flutter 3.41, Riverpod v2 with `@riverpod` codegen, sherpa-onnx, audioplayers, dio.

**Scope (this plan):**
- Server: `/tts/probe` endpoint + tests + swagger
- App: capability provider, router, three audio sources, playback mode provider, settings additions, chapter status dots in `AudiobookPage`, feature flag, PROGRESS.md update

**Out of scope (Plan 2):** Mini player bar, full-screen Now-Playing, sentence stream widget, pill widget + detail sheet, chapter dots in reader drawer, the orchestrator that calls `prepare()` on the right `TtsAudioSource` and handles chapter-boundary upgrades, look-ahead prefetch of N+1 / N+2 chapters. The three `TtsAudioSource` implementations and the `ttsPlaybackMode` provider are intentionally built in Plan 1 ahead of their consumer so the player work in Plan 2 can compose them directly without touching audio internals.

---

## File Map

| Action | File | Responsibility |
|---|---|---|
| Create | `server/service/tts/probe_handler.go` | `POST /tts/probe`: synchronously synth a fixed text, time first byte + total, return tier metrics |
| Create | `server/service/tts/probe_text.go` | Locale-keyed probe corpus (zh-CN, en-US fixtures) |
| Create | `server/service/tts/probe_handler_test.go` | Unit + integration coverage |
| Modify | `server/service/tts/setup.go` | Register `/tts/probe` route |
| Modify | `server/schema/tts.go` (or extend existing) | `ProbeResult` response schema |
| Modify | `server/docs/*` | Regenerate swagger via `make swagger` |
| Modify | `app/lib/service/api/tts_api.dart` | `probe()` client method |
| Create | `app/lib/models/tts/tts_capability.dart` | Freezed model: tier, metrics, expiry |
| Create | `app/lib/providers/tts_capability_provider.dart` | Probe trigger + 7-day cache + invalidation |
| Create | `app/lib/service/tts/tts_router.dart` | Pure `decide(capability, chapterStatus, override) → PlaybackMode` |
| Create | `app/lib/service/tts/tts_audio_source.dart` | Abstract interface |
| Create | `app/lib/service/tts/live_server_source.dart` | Streams `/tts/synthesize` |
| Create | `app/lib/service/tts/pregen_server_source.dart` | Plays downloaded chapter audio file |
| Create | `app/lib/service/tts/local_fallback_source.dart` | Wraps `SherpaOnnxProvider` |
| Create | `app/lib/providers/tts_playback_mode_provider.dart` | Combines capability + chapter status + override into `PlaybackMode` stream |
| Modify | `app/lib/page/settings_page/narrate.dart` | Add "声音体检" card + "默认模式" segmented |
| Modify | `app/lib/page/audiobook/audiobook_page.dart` | Per-chapter status dot widget |
| Create | `app/lib/widgets/audiobook/chapter_status_dot.dart` | Shared dot widget (○/◐/●/◌) |
| Modify | `app/lib/config/preferences.dart` | New keys: `ttsCapabilityCacheJson`, `ttsDefaultMode`, `experimentalTtsAdaptiveRouting` |
| Modify | `app/lib/l10n/app_en.arb` + `app_zh-CN.arb` | New L10n keys |
| Create | `app/test/service/tts/tts_router_test.dart` | Matrix coverage |
| Create | `app/test/providers/tts_capability_provider_test.dart` | Cache lifecycle |
| Modify | `docs/superpowers/PROGRESS.md` | Sprint 7 entry |

---

## Phase A — Server probe endpoint

### Task 1: Probe text fixtures

**Files:** Create `server/service/tts/probe_text.go`

- [ ] **Step 1: Create the fixture file**

```go
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
```

- [ ] **Step 2: Quick syntax check**

```bash
cd server && go build ./service/tts/...
```

Expected: no output, exit 0.

- [ ] **Step 3: Commit**

```bash
git add server/service/tts/probe_text.go
git commit -m "feat(tts): probe text fixtures for capability measurement"
```

---

### Task 2: Probe response schema

**Files:** Modify `server/schema/tts.go` (create file if missing)

- [ ] **Step 1: Locate or create schema file**

```bash
ls server/schema/ | grep -i tts
```

If `tts.go` exists, append; if not, create `server/schema/tts.go` with package header `package schema`.

- [ ] **Step 2: Add `ProbeResult` struct**

```go
// ProbeResult is the response body of POST /tts/probe.
// All durations are milliseconds. RTF (real-time factor) is
// synthesis_duration_ms / audio_duration_ms — values < 1.0 mean
// the server can render faster than realtime.
type ProbeResult struct {
	FirstByteMs    int64   `json:"first_byte_ms"`
	TotalMs        int64   `json:"total_ms"`
	AudioDurationMs int64  `json:"audio_duration_ms"`
	RTF            float64 `json:"rtf"`
	Voice          string  `json:"voice"`
	Provider       string  `json:"provider"`
	ServerBuild    string  `json:"server_build"`
}
```

- [ ] **Step 3: Build check**

```bash
cd server && go build ./schema/...
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add server/schema/tts.go
git commit -m "feat(tts): ProbeResult schema for capability endpoint"
```

---

### Task 3: Probe handler — failing test first

**Files:** Create `server/service/tts/probe_handler_test.go`

- [ ] **Step 1: Read existing test patterns**

```bash
cat server/service/tts/sidecar_test.go | head -50
```

This shows the gin/httptest pattern used here.

- [ ] **Step 2: Write failing test**

```go
package tts

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
)

// fakeProvider lets us simulate fast/slow servers deterministically.
type fakeProvider struct {
	name        string
	delay       time.Duration   // delay before first byte
	body        []byte          // payload (must be valid for duration calc; we mock duration via header)
	audioMs     int64           // audio duration we pretend the body represents
	failOnCall  bool
}

func (f *fakeProvider) Name() string                 { return f.name }
func (f *fakeProvider) Voices() []Voice              { return nil }
func (f *fakeProvider) SupportsStreaming() bool      { return true }
func (f *fakeProvider) HealthCheck(_ context.Context) error { return nil }
func (f *fakeProvider) Synthesize(_ context.Context, _ string, _ SynthesisOptions) (io.ReadCloser, error) {
	if f.failOnCall {
		return nil, errors.New("synth failed")
	}
	time.Sleep(f.delay)
	return io.NopCloser(bytes.NewReader(f.body)), nil
}

func TestProbeReturnsFastTier(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	prov := &fakeProvider{
		name:    "fake-fast",
		delay:   100 * time.Millisecond,
		body:    bytes.Repeat([]byte{0}, 4096),
		audioMs: 5000,
	}
	registerProbeHandlerForTest(r, prov, "test-build-1")

	body, _ := json.Marshal(map[string]any{"voice": "test", "language": "en-US"})
	req := httptest.NewRequest(http.MethodPost, "/tts/probe", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("status %d body %s", w.Code, w.Body.String())
	}

	var got struct {
		Code int          `json:"code"`
		Data ProbeResult  `json:"data"`
	}
	if err := json.NewDecoder(w.Body).Decode(&got); err != nil {
		t.Fatal(err)
	}
	if got.Data.FirstByteMs < 50 || got.Data.FirstByteMs > 1500 {
		t.Errorf("first_byte_ms = %d, expected 50–1500", got.Data.FirstByteMs)
	}
	if got.Data.ServerBuild != "test-build-1" {
		t.Errorf("server_build = %q, want test-build-1", got.Data.ServerBuild)
	}
}

func TestProbeFailsGracefully(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	prov := &fakeProvider{name: "broken", failOnCall: true}
	registerProbeHandlerForTest(r, prov, "test-build-1")

	body, _ := json.Marshal(map[string]any{"voice": "x"})
	req := httptest.NewRequest(http.MethodPost, "/tts/probe", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusServiceUnavailable {
		t.Errorf("status = %d, want 503; body=%s", w.Code, strings.TrimSpace(w.Body.String()))
	}
}
```

- [ ] **Step 3: Run — must fail to compile (handler not yet defined)**

```bash
cd server && go test ./service/tts/ -run TestProbe -v 2>&1 | head -20
```

Expected: build error referencing undefined `registerProbeHandlerForTest` and `errors`/`context` imports — **good, that's the failing test we want before implementing**.

- [ ] **Step 4: Commit (test only)**

```bash
git add server/service/tts/probe_handler_test.go
git commit -m "test(tts): probe handler failing tests"
```

---

### Task 4: Probe handler implementation

**Files:** Create `server/service/tts/probe_handler.go`; modify `server/service/tts/setup.go`

- [ ] **Step 1: Implement `probe_handler.go`**

```go
package tts

import (
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram-server/schema"
	"github.com/lxpio/omnigram-server/version"
)

type probeRequest struct {
	Voice    string `json:"voice"     binding:"required"`
	Speed    float64 `json:"speed"`
	Language string `json:"language"`
}

// estimateAudioMs returns a rough audio duration estimate from the synthesized
// byte stream. Real implementations should parse the audio header; for the
// probe we accept a fixed-text estimate (5s ± 1s for our 120-char fixtures at 1.0×).
const probeAssumedAudioMs = 5000

// probeHandler synchronously synthesizes the locale-appropriate probe text
// using the provider's currently selected voice and reports first-byte
// latency, total time, and an RTF estimate.
//
// @Summary     TTS probe (capability check)
// @Description Synchronously synthesizes a fixed neutral text and returns
// @Description first-byte latency + RTF so the client can pick GREEN/YELLOW/RED tier.
// @Tags        TTS
// @Accept      json
// @Produce     json
// @Security    BearerAuth
// @Param       body body probeRequest true "Probe request"
// @Success     200 {object} schema.ProbeResult
// @Failure     503 {object} schema.ErrorResponse
// @Router      /tts/probe [post]
func probeHandler(c *gin.Context) {
	provider := getActiveProvider() // existing helper that resolves the configured provider
	doProbe(c, provider, version.Build())
}

// doProbe is the testable core; production callers pass the live provider.
func doProbe(c *gin.Context, provider TTSProvider, build string) {
	var req probeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": err.Error()})
		return
	}
	if req.Speed == 0 {
		req.Speed = 1.0
	}

	text := ProbeText(req.Language)
	opts := DefaultSynthesisOptions()
	opts.Voice = req.Voice
	opts.Speed = req.Speed
	opts.Language = req.Language

	start := time.Now()
	rc, err := provider.Synthesize(c.Request.Context(), text, opts)
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"code": 503, "message": err.Error()})
		return
	}
	defer rc.Close()

	buf := make([]byte, 4096)
	firstByteMs := int64(0)
	for firstByteMs == 0 {
		n, rerr := rc.Read(buf)
		if n > 0 {
			firstByteMs = time.Since(start).Milliseconds()
		}
		if rerr == io.EOF {
			break
		}
		if rerr != nil {
			c.JSON(http.StatusServiceUnavailable, gin.H{"code": 503, "message": rerr.Error()})
			return
		}
	}
	// Drain remainder to measure total
	if _, err := io.Copy(io.Discard, rc); err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"code": 503, "message": err.Error()})
		return
	}
	totalMs := time.Since(start).Milliseconds()

	rtf := float64(totalMs) / float64(probeAssumedAudioMs)
	if rtf <= 0 {
		rtf = 0.01
	}

	res := schema.ProbeResult{
		FirstByteMs:     firstByteMs,
		TotalMs:         totalMs,
		AudioDurationMs: probeAssumedAudioMs,
		RTF:             rtf,
		Voice:           req.Voice,
		Provider:        provider.Name(),
		ServerBuild:     strings.TrimSpace(build),
	}
	c.JSON(http.StatusOK, gin.H{"code": 200, "data": res})
}

// registerProbeHandlerForTest is a test seam for unit tests.
func registerProbeHandlerForTest(r *gin.Engine, p TTSProvider, build string) {
	r.POST("/tts/probe", func(c *gin.Context) { doProbe(c, p, build) })
}
```

- [ ] **Step 2: If `getActiveProvider()` or `version.Build()` don't exist, locate equivalents**

```bash
grep -rn "getActiveProvider\|version\.Build\|defaultProvider" server/service/tts server/version 2>/dev/null | head -10
```

If `version.Build()` doesn't exist, replace its call with the existing build constant (commonly `app.Version` or read from `cmd/omni-server/main.go`). If `getActiveProvider` doesn't exist, replace with how `synthesizeHandler` (in `synthesize_handler.go`) gets its provider — copy that pattern.

- [ ] **Step 3: Register the route in `setup.go`**

Edit `server/service/tts/setup.go` after line 70 (`/tts/health`):

```go
	router.POST("/tts/probe", oauthMD, probeHandler)
```

- [ ] **Step 4: Run the tests — expect PASS**

```bash
cd server && go test ./service/tts/ -run TestProbe -v
```

Expected: both `TestProbeReturnsFastTier` and `TestProbeFailsGracefully` PASS.

- [ ] **Step 5: Regenerate swagger**

```bash
cd server && make swagger
```

Expected: `docs/docs.go`, `docs/swagger.json`, `docs/swagger.yaml` updated.

- [ ] **Step 6: Commit**

```bash
git add server/service/tts/probe_handler.go server/service/tts/setup.go server/docs/
git commit -m "feat(tts): /tts/probe endpoint for capability measurement"
```

---

## Phase B — App: probe API + capability provider

### Task 5: Add `probe` to TtsApi

**Files:** Modify `app/lib/service/api/tts_api.dart`; modify `app/lib/models/server/server_tts.dart`

- [ ] **Step 1: Add `ProbeResult` model**

In `app/lib/models/server/server_tts.dart`, add a freezed class. Match existing freezed conventions in that file:

```dart
@freezed
class ProbeResult with _$ProbeResult {
  const factory ProbeResult({
    @JsonKey(name: 'first_byte_ms') required int firstByteMs,
    @JsonKey(name: 'total_ms') required int totalMs,
    @JsonKey(name: 'audio_duration_ms') required int audioDurationMs,
    required double rtf,
    required String voice,
    required String provider,
    @JsonKey(name: 'server_build') required String serverBuild,
  }) = _ProbeResult;

  factory ProbeResult.fromJson(Map<String, dynamic> json) => _$ProbeResultFromJson(json);
}
```

- [ ] **Step 2: Add `probe()` to `TtsApi`**

In `app/lib/service/api/tts_api.dart`, after `checkHealth()` (around line 45):

```dart
  /// Run a synthesis probe; server returns first-byte latency + RTF for the
  /// voice. Throws on non-2xx so callers can mark capability NA on failure.
  Future<ProbeResult> probe({
    required String voice,
    String? language,
    double speed = 1.0,
  }) async {
    return _api.post(
      '/tts/probe',
      data: {
        'voice': voice,
        'speed': speed,
        if (language != null) 'language': language,
      },
      fromJson: (raw) {
        final inner = (raw is Map && raw['data'] is Map<String, dynamic>)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        return ProbeResult.fromJson(inner);
      },
    );
  }
```

- [ ] **Step 3: Run codegen + analyze**

```bash
cd app && dart run build_runner build --delete-conflicting-outputs && flutter analyze lib/service/api/tts_api.dart lib/models/server/server_tts.dart
```

Expected: no analyzer errors.

- [ ] **Step 4: Commit**

```bash
git add app/lib/service/api/tts_api.dart app/lib/models/server/server_tts.dart \
        app/lib/models/server/server_tts.freezed.dart app/lib/models/server/server_tts.g.dart
git commit -m "feat(app): TtsApi.probe + ProbeResult model"
```

---

### Task 6: Capability model + cache

**Files:** Create `app/lib/models/tts/tts_capability.dart`; modify `app/lib/config/preferences.dart`

- [ ] **Step 1: Create capability model**

`app/lib/models/tts/tts_capability.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tts_capability.freezed.dart';
part 'tts_capability.g.dart';

enum TtsCapabilityTier { green, yellow, red, na }

@freezed
class TtsCapability with _$TtsCapability {
  const TtsCapability._();
  const factory TtsCapability({
    required String serverUrl,
    required String voiceFullId,
    required TtsCapabilityTier tier,
    required int firstByteMs,
    required double rtf,
    required String serverBuild,
    required DateTime probedAt,
  }) = _TtsCapability;

  factory TtsCapability.fromJson(Map<String, dynamic> json) => _$TtsCapabilityFromJson(json);

  bool get isExpired => DateTime.now().difference(probedAt) > const Duration(days: 7);

  /// Pure tier classification matching server thresholds in spec §5.1.
  static TtsCapabilityTier classify({required int firstByteMs, required double rtf}) {
    if (firstByteMs < 1500 && rtf < 0.6) return TtsCapabilityTier.green;
    if (firstByteMs >= 3000 || rtf >= 0.9) return TtsCapabilityTier.red;
    return TtsCapabilityTier.yellow;
  }
}
```

- [ ] **Step 2: Add prefs keys**

In `app/lib/config/preferences.dart`, find the existing keys section and add:

```dart
  static const _kTtsCapabilityCacheJson = 'tts_capability_cache_json';
  static const _kTtsDefaultMode = 'tts_default_mode';
  static const _kExperimentalTtsAdaptiveRouting = 'experimental_tts_adaptive_routing';

  /// JSON-encoded map keyed by "${serverUrl}::${voiceFullId}" → TtsCapability.toJson().
  String? get ttsCapabilityCacheJson => _prefs.getString(_kTtsCapabilityCacheJson);
  set ttsCapabilityCacheJson(String? v) {
    if (v == null) _prefs.remove(_kTtsCapabilityCacheJson);
    else _prefs.setString(_kTtsCapabilityCacheJson, v);
  }

  /// One of: "auto", "always_live", "always_pregen", "always_local". Default "auto".
  String get ttsDefaultMode => _prefs.getString(_kTtsDefaultMode) ?? 'auto';
  set ttsDefaultMode(String v) => _prefs.setString(_kTtsDefaultMode, v);

  /// Master kill-switch. Default true for fresh installs (set on first run if unset);
  /// stays false for upgrade installs until 7-day grace period expires.
  bool? get experimentalTtsAdaptiveRouting {
    if (!_prefs.containsKey(_kExperimentalTtsAdaptiveRouting)) return null;
    return _prefs.getBool(_kExperimentalTtsAdaptiveRouting);
  }
  set experimentalTtsAdaptiveRouting(bool? v) {
    if (v == null) _prefs.remove(_kExperimentalTtsAdaptiveRouting);
    else _prefs.setBool(_kExperimentalTtsAdaptiveRouting, v);
  }
```

- [ ] **Step 3: Codegen + analyze**

```bash
cd app && dart run build_runner build --delete-conflicting-outputs && flutter analyze lib/models/tts/ lib/config/preferences.dart
```

Expected: clean.

- [ ] **Step 4: Commit**

```bash
git add app/lib/models/tts/ app/lib/config/preferences.dart
git commit -m "feat(app): TtsCapability model + cache/override preference keys"
```

---

### Task 7: Capability provider — failing test

**Files:** Create `app/test/providers/tts_capability_provider_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/models/tts/tts_capability.dart';

void main() {
  group('TtsCapability.classify', () {
    test('green when both metrics good', () {
      expect(
        TtsCapability.classify(firstByteMs: 800, rtf: 0.4),
        TtsCapabilityTier.green,
      );
    });
    test('yellow when first_byte borderline', () {
      expect(
        TtsCapability.classify(firstByteMs: 2000, rtf: 0.7),
        TtsCapabilityTier.yellow,
      );
    });
    test('red when first_byte exceeds 3s', () {
      expect(
        TtsCapability.classify(firstByteMs: 3500, rtf: 0.5),
        TtsCapabilityTier.red,
      );
    });
    test('red when rtf >= 0.9', () {
      expect(
        TtsCapability.classify(firstByteMs: 1000, rtf: 0.95),
        TtsCapabilityTier.red,
      );
    });
  });

  group('TtsCapability.isExpired', () {
    test('not expired within 7 days', () {
      final cap = TtsCapability(
        serverUrl: 'http://x', voiceFullId: 'v',
        tier: TtsCapabilityTier.green,
        firstByteMs: 100, rtf: 0.1, serverBuild: 'b',
        probedAt: DateTime.now().subtract(const Duration(days: 6)),
      );
      expect(cap.isExpired, false);
    });
    test('expired past 7 days', () {
      final cap = TtsCapability(
        serverUrl: 'http://x', voiceFullId: 'v',
        tier: TtsCapabilityTier.green,
        firstByteMs: 100, rtf: 0.1, serverBuild: 'b',
        probedAt: DateTime.now().subtract(const Duration(days: 8)),
      );
      expect(cap.isExpired, true);
    });
  });
}
```

- [ ] **Step 2: Run — should pass already**

```bash
cd app && flutter test test/providers/tts_capability_provider_test.dart
```

Expected: 6 passing — these test the model itself which is already implemented. (Cache provider tests come in Task 8.)

- [ ] **Step 3: Commit**

```bash
git add app/test/providers/tts_capability_provider_test.dart
git commit -m "test(app): TtsCapability classification + expiry"
```

---

### Task 8: Capability provider implementation

**Files:** Create `app/lib/providers/tts_capability_provider.dart`

- [ ] **Step 1: Implement provider**

```dart
import 'dart:convert';

import 'package:omnigram/config/preferences.dart';
import 'package:omnigram/models/tts/tts_capability.dart';
import 'package:omnigram/service/api/omnigram_api.dart';
import 'package:omnigram/service/api/tts_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_capability_provider.g.dart';

/// Capability lookup keyed by `(serverUrl, voiceFullId)`.
///
/// - On read: returns cached value if fresh, else null
/// - On `probe(voice, language)`: fires the server probe, classifies, persists, returns
/// - On `invalidate(voice)`: removes that key (used when user changes voice)
@Riverpod(keepAlive: true)
class TtsCapabilityCache extends _$TtsCapabilityCache {
  @override
  Map<String, TtsCapability> build() => _readFromPrefs();

  Map<String, TtsCapability> _readFromPrefs() {
    final raw = Prefs().ttsCapabilityCacheJson;
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final e in decoded.entries)
          e.key: TtsCapability.fromJson(e.value as Map<String, dynamic>),
      };
    } catch (_) {
      return {};
    }
  }

  void _persist() {
    Prefs().ttsCapabilityCacheJson = jsonEncode({
      for (final e in state.entries) e.key: (e.value as dynamic).toJson(),
    });
  }

  String _key(String serverUrl, String voiceFullId) => '$serverUrl::$voiceFullId';

  TtsCapability? get(String serverUrl, String voiceFullId) {
    final cap = state[_key(serverUrl, voiceFullId)];
    if (cap == null || cap.isExpired) return null;
    return cap;
  }

  Future<TtsCapability> probe({
    required String serverUrl,
    required String voiceFullId,
    required String voice,
    String? language,
  }) async {
    try {
      final result = await TtsApi(OmnigramApi.instance).probe(
        voice: voice,
        language: language,
      );
      final tier = TtsCapability.classify(
        firstByteMs: result.firstByteMs,
        rtf: result.rtf,
      );
      final cap = TtsCapability(
        serverUrl: serverUrl,
        voiceFullId: voiceFullId,
        tier: tier,
        firstByteMs: result.firstByteMs,
        rtf: result.rtf,
        serverBuild: result.serverBuild,
        probedAt: DateTime.now(),
      );
      state = {...state, _key(serverUrl, voiceFullId): cap};
      _persist();
      return cap;
    } catch (_) {
      final cap = TtsCapability(
        serverUrl: serverUrl,
        voiceFullId: voiceFullId,
        tier: TtsCapabilityTier.na,
        firstByteMs: -1,
        rtf: -1,
        serverBuild: '',
        probedAt: DateTime.now(),
      );
      state = {...state, _key(serverUrl, voiceFullId): cap};
      _persist();
      return cap;
    }
  }

  void invalidate(String serverUrl, String voiceFullId) {
    final key = _key(serverUrl, voiceFullId);
    if (!state.containsKey(key)) return;
    final next = Map<String, TtsCapability>.from(state)..remove(key);
    state = next;
    _persist();
  }
}
```

- [ ] **Step 2: Codegen + analyze**

```bash
cd app && dart run build_runner build --delete-conflicting-outputs && flutter analyze lib/providers/tts_capability_provider.dart
```

Expected: no errors.

- [ ] **Step 3: Hook into login success**

Find the auth provider that handles login (likely `app/lib/providers/auth_provider.dart` or similar):

```bash
grep -rn "loginSuccess\|login\b.*success\|signedIn" app/lib/providers/ app/lib/service/ | head -10
```

In the post-login callback (or `ref.listen` on auth state), trigger:

```dart
final selectedVoice = Prefs().selectedVoiceFullId;
if (selectedVoice != null && selectedVoice.startsWith('server:')) {
  final cap = ref.read(ttsCapabilityCacheProvider.notifier);
  final cached = cap.get(serverUrl, selectedVoice);
  if (cached == null) {
    // fire-and-forget; failures are recorded as NA
    unawaited(cap.probe(
      serverUrl: serverUrl,
      voiceFullId: selectedVoice,
      voice: selectedVoice.substring('server:'.length),
    ));
  }
}
```

(If the exact voice prefix scheme differs, match what `tts_providers.dart` does — search for `selectedVoiceFullId` to find parsing logic.)

- [ ] **Step 4: Commit**

```bash
git add app/lib/providers/tts_capability_provider.dart \
        app/lib/providers/tts_capability_provider.g.dart \
        app/lib/providers/auth_provider.dart  # or whichever file you hooked
git commit -m "feat(app): TtsCapabilityCache provider + post-login probe trigger"
```

---

## Phase C — Pure router

### Task 9: TtsRouter — failing test

**Files:** Create `app/test/service/tts/tts_router_test.dart`

- [ ] **Step 1: Write the matrix coverage**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/models/tts/tts_capability.dart';
import 'package:omnigram/service/tts/tts_router.dart';

void main() {
  group('TtsRouter.decide — auto mode (matrix §6)', () {
    test('GREEN + any → LiveServer', () {
      expect(
        TtsRouter.decide(tier: TtsCapabilityTier.green, status: ChapterAudioStatus.notGenerated, override: TtsDefaultMode.auto),
        PlaybackMode.liveServer,
      );
    });
    test('YELLOW + Ready → PregenServer', () {
      expect(
        TtsRouter.decide(tier: TtsCapabilityTier.yellow, status: ChapterAudioStatus.ready, override: TtsDefaultMode.auto),
        PlaybackMode.pregenServer,
      );
    });
    test('YELLOW + Generating → LocalFallback', () {
      expect(
        TtsRouter.decide(tier: TtsCapabilityTier.yellow, status: ChapterAudioStatus.generating, override: TtsDefaultMode.auto),
        PlaybackMode.localFallback,
      );
    });
    test('YELLOW + NotGenerated → LocalFallback (with prefetch)', () {
      final out = TtsRouter.decide(tier: TtsCapabilityTier.yellow, status: ChapterAudioStatus.notGenerated, override: TtsDefaultMode.auto);
      expect(out, PlaybackMode.localFallback);
    });
    test('RED + Ready → PregenServer', () {
      expect(
        TtsRouter.decide(tier: TtsCapabilityTier.red, status: ChapterAudioStatus.ready, override: TtsDefaultMode.auto),
        PlaybackMode.pregenServer,
      );
    });
    test('RED + Generating → LocalFallback', () {
      expect(
        TtsRouter.decide(tier: TtsCapabilityTier.red, status: ChapterAudioStatus.generating, override: TtsDefaultMode.auto),
        PlaybackMode.localFallback,
      );
    });
    test('RED + NotGenerated → LocalFallback', () {
      expect(
        TtsRouter.decide(tier: TtsCapabilityTier.red, status: ChapterAudioStatus.notGenerated, override: TtsDefaultMode.auto),
        PlaybackMode.localFallback,
      );
    });
    test('NA + Ready → PregenServer', () {
      expect(
        TtsRouter.decide(tier: TtsCapabilityTier.na, status: ChapterAudioStatus.ready, override: TtsDefaultMode.auto),
        PlaybackMode.pregenServer,
      );
    });
    test('NA + NotGenerated → LocalFallback', () {
      expect(
        TtsRouter.decide(tier: TtsCapabilityTier.na, status: ChapterAudioStatus.notGenerated, override: TtsDefaultMode.auto),
        PlaybackMode.localFallback,
      );
    });
  });

  group('TtsRouter.decide — overrides', () {
    test('alwaysLive forces live regardless of tier', () {
      expect(
        TtsRouter.decide(tier: TtsCapabilityTier.red, status: ChapterAudioStatus.notGenerated, override: TtsDefaultMode.alwaysLive),
        PlaybackMode.liveServer,
      );
    });
    test('alwaysPregen + Ready → PregenServer', () {
      expect(
        TtsRouter.decide(tier: TtsCapabilityTier.green, status: ChapterAudioStatus.ready, override: TtsDefaultMode.alwaysPregen),
        PlaybackMode.pregenServer,
      );
    });
    test('alwaysPregen + NotGenerated → LocalFallback (waiting)', () {
      expect(
        TtsRouter.decide(tier: TtsCapabilityTier.green, status: ChapterAudioStatus.notGenerated, override: TtsDefaultMode.alwaysPregen),
        PlaybackMode.localFallback,
      );
    });
    test('alwaysLocal forces local always', () {
      expect(
        TtsRouter.decide(tier: TtsCapabilityTier.green, status: ChapterAudioStatus.ready, override: TtsDefaultMode.alwaysLocal),
        PlaybackMode.localFallback,
      );
    });
  });

  group('TtsRouter.shouldPrefetch', () {
    test('prefetch under YELLOW for not-generated chapter', () {
      expect(
        TtsRouter.shouldPrefetch(tier: TtsCapabilityTier.yellow, status: ChapterAudioStatus.notGenerated),
        true,
      );
    });
    test('prefetch under RED for not-generated chapter', () {
      expect(
        TtsRouter.shouldPrefetch(tier: TtsCapabilityTier.red, status: ChapterAudioStatus.notGenerated),
        true,
      );
    });
    test('no prefetch under GREEN', () {
      expect(
        TtsRouter.shouldPrefetch(tier: TtsCapabilityTier.green, status: ChapterAudioStatus.notGenerated),
        false,
      );
    });
    test('no prefetch under NA', () {
      expect(
        TtsRouter.shouldPrefetch(tier: TtsCapabilityTier.na, status: ChapterAudioStatus.notGenerated),
        false,
      );
    });
  });
}
```

- [ ] **Step 2: Run — must fail (router not yet defined)**

```bash
cd app && flutter test test/service/tts/tts_router_test.dart
```

Expected: compile error referencing missing `tts_router.dart`. **Good.**

- [ ] **Step 3: Commit**

```bash
git add app/test/service/tts/tts_router_test.dart
git commit -m "test(app): TtsRouter matrix + override + prefetch coverage"
```

---

### Task 10: TtsRouter implementation

**Files:** Create `app/lib/service/tts/tts_router.dart`

- [ ] **Step 1: Implement**

```dart
import 'package:omnigram/models/tts/tts_capability.dart';

/// Per-chapter audio status (spec §5.2).
enum ChapterAudioStatus { notGenerated, generating, ready, localCached }

/// Runtime playback mode for a session (spec §5.3).
enum PlaybackMode { liveServer, pregenServer, localFallback }

/// User override (spec §8.6 default mode).
enum TtsDefaultMode { auto, alwaysLive, alwaysPregen, alwaysLocal }

extension TtsDefaultModeCodec on TtsDefaultMode {
  String get prefValue => switch (this) {
        TtsDefaultMode.auto => 'auto',
        TtsDefaultMode.alwaysLive => 'always_live',
        TtsDefaultMode.alwaysPregen => 'always_pregen',
        TtsDefaultMode.alwaysLocal => 'always_local',
      };
  static TtsDefaultMode fromPref(String? v) => switch (v) {
        'always_live' => TtsDefaultMode.alwaysLive,
        'always_pregen' => TtsDefaultMode.alwaysPregen,
        'always_local' => TtsDefaultMode.alwaysLocal,
        _ => TtsDefaultMode.auto,
      };
}

class TtsRouter {
  const TtsRouter._();

  /// Pure decision per spec §6.
  static PlaybackMode decide({
    required TtsCapabilityTier tier,
    required ChapterAudioStatus status,
    required TtsDefaultMode override,
  }) {
    // Overrides win first.
    switch (override) {
      case TtsDefaultMode.alwaysLive:
        return PlaybackMode.liveServer;
      case TtsDefaultMode.alwaysLocal:
        return PlaybackMode.localFallback;
      case TtsDefaultMode.alwaysPregen:
        return status == ChapterAudioStatus.ready
            ? PlaybackMode.pregenServer
            : PlaybackMode.localFallback;
      case TtsDefaultMode.auto:
        break;
    }

    if (status == ChapterAudioStatus.ready) return PlaybackMode.pregenServer;

    switch (tier) {
      case TtsCapabilityTier.green:
        return PlaybackMode.liveServer;
      case TtsCapabilityTier.yellow:
      case TtsCapabilityTier.red:
        return PlaybackMode.localFallback;
      case TtsCapabilityTier.na:
        return PlaybackMode.localFallback;
    }
  }

  /// Whether to enqueue server pre-gen for this chapter + N+1, N+2 (spec §6 prefetch policy).
  static bool shouldPrefetch({
    required TtsCapabilityTier tier,
    required ChapterAudioStatus status,
  }) {
    if (status != ChapterAudioStatus.notGenerated) return false;
    return tier == TtsCapabilityTier.yellow || tier == TtsCapabilityTier.red;
  }
}
```

- [ ] **Step 2: Run tests — expect PASS**

```bash
cd app && flutter test test/service/tts/tts_router_test.dart
```

Expected: 17 passing.

- [ ] **Step 3: Commit**

```bash
git add app/lib/service/tts/tts_router.dart
git commit -m "feat(app): TtsRouter pure routing + prefetch decisions"
```

---

## Phase D — Audio source abstraction (3 implementations)

### Task 11: TtsAudioSource interface + LiveServerSource

**Files:** Create `app/lib/service/tts/tts_audio_source.dart`, `app/lib/service/tts/live_server_source.dart`

- [ ] **Step 1: Define the interface**

`app/lib/service/tts/tts_audio_source.dart`:

```dart
import 'dart:async';

/// Common surface for the three playback modes; the player provider talks
/// to one of these without caring which mode is active.
abstract class TtsAudioSource {
  /// Begin streaming/loading audio for the given chapter index.
  /// Returns when first audio sample is buffered (i.e., playback can start).
  Future<void> prepare({required int chapterIndex});

  /// Start or resume playback.
  Future<void> play();

  /// Pause without releasing resources.
  Future<void> pause();

  /// Seek within the current chapter (milliseconds).
  Future<void> seek(Duration position);

  /// Stop and release any buffered audio.
  Future<void> dispose();

  /// Position stream — drives sentence-highlight.
  Stream<Duration> get positionStream;

  /// Fires once when current chapter finishes naturally.
  Stream<void> get completionStream;
}
```

- [ ] **Step 2: Implement `LiveServerSource`**

`app/lib/service/tts/live_server_source.dart`:

```dart
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:omnigram/service/api/omnigram_api.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:path_provider/path_provider.dart';

/// Real-time server synthesis. Streams `/tts/synthesize` to a temp file then
/// hands it to audioplayers. We deliberately **don't** stream-decode here —
/// audioplayers' file source path is the most reliable on iOS (see commit
/// dbe33135 fix(app): TTS playback iOS file source).
class LiveServerSource implements TtsAudioSource {
  LiveServerSource({
    required this.bookId,
    required this.voice,
    required this.language,
    required Future<String> Function(int chapterIndex) fetchChapterText,
  }) : _fetchChapterText = fetchChapterText;

  final String bookId;
  final String voice;
  final String? language;
  final Future<String> Function(int) _fetchChapterText;

  final _player = AudioPlayer();
  File? _bufferFile;

  @override
  Future<void> prepare({required int chapterIndex}) async {
    final text = await _fetchChapterText(chapterIndex);
    final tmpDir = await getTemporaryDirectory();
    _bufferFile = File('${tmpDir.path}/live-$bookId-$chapterIndex.mp3');
    final response = await OmnigramApi.instance.dio.post<ResponseBody>(
      '/tts/synthesize',
      data: {'text': text, 'voice': voice, 'speed': 1.0, 'format': 'mp3', if (language != null) 'language': language},
      options: Options(responseType: ResponseType.stream),
    );
    final body = response.data;
    if (body == null) {
      throw const SocketException('empty TTS response');
    }
    final sink = _bufferFile!.openWrite();
    await for (final chunk in body.stream) {
      sink.add(chunk);
    }
    await sink.close();
    await _player.setSource(DeviceFileSource(_bufferFile!.path));
  }

  @override
  Future<void> play() => _player.resume();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() async {
    await _player.dispose();
    if (_bufferFile != null && await _bufferFile!.exists()) {
      try { await _bufferFile!.delete(); } catch (_) {}
    }
  }

  @override
  Stream<Duration> get positionStream => _player.onPositionChanged;
  @override
  Stream<void> get completionStream => _player.onPlayerComplete;
}
```

- [ ] **Step 3: Analyze**

```bash
cd app && flutter analyze lib/service/tts/tts_audio_source.dart lib/service/tts/live_server_source.dart
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add app/lib/service/tts/tts_audio_source.dart app/lib/service/tts/live_server_source.dart
git commit -m "feat(app): TtsAudioSource interface + LiveServerSource impl"
```

---

### Task 12: PregenServerSource

**Files:** Create `app/lib/service/tts/pregen_server_source.dart`

- [ ] **Step 1: Implement**

```dart
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:omnigram/service/api/omnigram_api.dart';
import 'package:omnigram/service/api/tts_api.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:path_provider/path_provider.dart';

/// Plays pre-generated chapter audio files from the server. The first time
/// a chapter is requested we download to app docs dir; subsequent plays of
/// the same chapter are local. Same caching key as `AudiobookPage`.
class PregenServerSource implements TtsAudioSource {
  PregenServerSource({required this.bookId});
  final String bookId;

  final _player = AudioPlayer();

  @override
  Future<void> prepare({required int chapterIndex}) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/audiobooks/$bookId');
    if (!await dir.exists()) await dir.create(recursive: true);
    final localPath = '${dir.path}/chapter_$chapterIndex.mp3';

    final file = File(localPath);
    if (!await file.exists()) {
      await TtsApi(OmnigramApi.instance).downloadChapter(bookId, chapterIndex, localPath);
    }
    await _player.setSource(DeviceFileSource(localPath));
  }

  @override
  Future<void> play() => _player.resume();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() => _player.dispose();

  @override
  Stream<Duration> get positionStream => _player.onPositionChanged;
  @override
  Stream<void> get completionStream => _player.onPlayerComplete;
}
```

- [ ] **Step 2: Analyze + commit**

```bash
cd app && flutter analyze lib/service/tts/pregen_server_source.dart
git add app/lib/service/tts/pregen_server_source.dart
git commit -m "feat(app): PregenServerSource — cached download playback"
```

---

### Task 13: LocalFallbackSource (sherpa-onnx)

**Files:** Create `app/lib/service/tts/local_fallback_source.dart`

- [ ] **Step 1: Read existing sherpa wrapper to match its API**

```bash
sed -n '1,80p' app/lib/service/tts/sherpa_onnx_tts.dart
```

Note the synthesis entry point (likely `SherpaOnnxProvider().synthesize(text, voice)` returning bytes / file path via isolate).

- [ ] **Step 2: Implement**

```dart
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:omnigram/service/tts/sherpa_onnx_tts.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:path_provider/path_provider.dart';

/// On-device sherpa-onnx synthesis. Runs in an isolate (existing wrapper),
/// caches the resulting wav per (book, chapter) so repeated plays are instant.
class LocalFallbackSource implements TtsAudioSource {
  LocalFallbackSource({
    required this.bookId,
    required this.voice,
    required Future<String> Function(int chapterIndex) fetchChapterText,
  }) : _fetchChapterText = fetchChapterText;

  final String bookId;
  final String voice;
  final Future<String> Function(int) _fetchChapterText;

  final _player = AudioPlayer();

  @override
  Future<void> prepare({required int chapterIndex}) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/audiobooks/$bookId/local');
    if (!await dir.exists()) await dir.create(recursive: true);
    final localPath = '${dir.path}/chapter_$chapterIndex.wav';

    final file = File(localPath);
    if (!await file.exists()) {
      final text = await _fetchChapterText(chapterIndex);
      // Existing isolate-based synth — match the actual signature in sherpa_onnx_tts.dart.
      await SherpaOnnxProvider.instance.synthesizeToFile(
        text: text,
        voice: voice,
        outputPath: localPath,
      );
    }
    await _player.setSource(DeviceFileSource(localPath));
  }

  @override
  Future<void> play() => _player.resume();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() => _player.dispose();

  @override
  Stream<Duration> get positionStream => _player.onPositionChanged;
  @override
  Stream<void> get completionStream => _player.onPlayerComplete;
}
```

- [ ] **Step 3: If `synthesizeToFile` doesn't match, add a thin shim**

If `SherpaOnnxProvider` only exposes `synthesize(text) → bytes`, add a `synthesizeToFile` method to it (or wrap in this file):

```dart
// In sherpa_onnx_tts.dart, add:
Future<void> synthesizeToFile({required String text, required String voice, required String outputPath}) async {
  final bytes = await synthesize(text: text, voice: voice); // adjust to actual API
  await File(outputPath).writeAsBytes(bytes);
}
```

- [ ] **Step 4: Analyze + commit**

```bash
cd app && flutter analyze lib/service/tts/local_fallback_source.dart lib/service/tts/sherpa_onnx_tts.dart
git add app/lib/service/tts/local_fallback_source.dart app/lib/service/tts/sherpa_onnx_tts.dart
git commit -m "feat(app): LocalFallbackSource — sherpa-onnx with on-disk cache"
```

---

## Phase E — PlaybackMode provider + prefetch wiring

### Task 14: TtsPlaybackMode provider

**Files:** Create `app/lib/providers/tts_playback_mode_provider.dart`

- [ ] **Step 1: Implement**

```dart
import 'package:omnigram/config/preferences.dart';
import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/models/tts/tts_capability.dart';
import 'package:omnigram/providers/audiobook_provider.dart';
import 'package:omnigram/providers/tts_capability_provider.dart';
import 'package:omnigram/service/api/omnigram_api.dart';
import 'package:omnigram/service/api/tts_api.dart';
import 'package:omnigram/service/tts/tts_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_playback_mode_provider.g.dart';

/// Resolves PlaybackMode for `(book, chapter)` based on current capability,
/// chapter status, and user override. Re-evaluates whenever capability or
/// audiobook state changes.
@riverpod
PlaybackMode ttsPlaybackMode(
  TtsPlaybackModeRef ref, {
  required String bookId,
  required int chapterIndex,
  required String serverUrl,
  required String voiceFullId,
}) {
  final capCache = ref.watch(ttsCapabilityCacheProvider);
  final cap = capCache['$serverUrl::$voiceFullId'];
  final tier = (cap == null || cap.isExpired) ? TtsCapabilityTier.na : cap.tier;

  final audiobook = ref.watch(audiobookProvider(bookId));
  final status = audiobook.maybeWhen(
    data: (info) => _statusFor(info, chapterIndex),
    orElse: () => ChapterAudioStatus.notGenerated,
  );

  final override = TtsDefaultModeCodec.fromPref(Prefs().ttsDefaultMode);
  return TtsRouter.decide(tier: tier, status: status, override: override);
}

ChapterAudioStatus _statusFor(ServerAudiobookInfo? info, int chapterIndex) {
  if (info == null) return ChapterAudioStatus.notGenerated;
  ServerAudiobookChapter? ch;
  for (final c in info.chapters) {
    if (c.chapterIndex == chapterIndex) { ch = c; break; }
  }
  if (ch == null) return ChapterAudioStatus.notGenerated;
  // server status int mapping (verify against schema/audiobook.go enum):
  // 0 pending, 1 running, 2 completed, 3 failed
  return switch (ch.status) {
    2 => ChapterAudioStatus.ready,
    1 => ChapterAudioStatus.generating,
    _ => ChapterAudioStatus.notGenerated,
  };
}

/// Prefetch helper — call from player when entering a chapter that should
/// be queued for server pre-gen.
@riverpod
Future<void> ttsPrefetchChapter(
  TtsPrefetchChapterRef ref, {
  required String bookId,
  required int chapterIndex,
}) async {
  await TtsApi(OmnigramApi.instance).createChapterAudio(bookId, chapterIndex);
}
```

- [ ] **Step 2: Verify the chapter status int mapping**

```bash
grep -n "Status.*=.*[0-9]\|StatusPending\|StatusRunning\|StatusCompleted\|StatusFailed" server/schema/audiobook.go
```

Adjust the `_statusFor` switch to match the actual enum values found.

- [ ] **Step 3: Codegen + analyze**

```bash
cd app && dart run build_runner build --delete-conflicting-outputs && flutter analyze lib/providers/tts_playback_mode_provider.dart
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add app/lib/providers/tts_playback_mode_provider.dart \
        app/lib/providers/tts_playback_mode_provider.g.dart
git commit -m "feat(app): ttsPlaybackMode provider + prefetch helper"
```

---

## Phase F — Settings additions

### Task 15: 声音体检 card + 默认模式 segmented

**Files:** Modify `app/lib/page/settings_page/narrate.dart`; add L10n keys

- [ ] **Step 1: Add L10n keys**

In both `app/lib/l10n/app_en.arb` and `app/lib/l10n/app_zh-CN.arb`, add:

```json
{
  "tts_capability_card_title": "Voice health check",
  "tts_capability_card_title_zh": "服务器声音体检",
  "tts_capability_last_probed": "Last check: {date} · {tierEmoji} {tierLabel} (first byte {ms}ms, RTF {rtf})",
  "tts_capability_never_probed": "Not yet checked.",
  "tts_capability_recheck": "Re-run check",
  "tts_capability_tier_green": "Real-time ready",
  "tts_capability_tier_yellow": "Real-time strained",
  "tts_capability_tier_red": "Real-time unavailable",
  "tts_capability_tier_na": "Not available",
  "tts_default_mode_title": "Default playback mode",
  "tts_default_mode_auto": "Auto (recommended)",
  "tts_default_mode_always_live": "Always real-time server",
  "tts_default_mode_always_pregen": "Always pre-generate",
  "tts_default_mode_always_local": "Always local"
}
```

(Translate to zh-CN appropriately.)

- [ ] **Step 2: Run gen-l10n**

```bash
cd app && flutter gen-l10n
```

- [ ] **Step 3: Add the card widget**

In `app/lib/page/settings_page/narrate.dart`, find the build method and insert above the existing voice picker:

```dart
Widget _buildCapabilityCard(BuildContext context, WidgetRef ref) {
  final voiceFullId = Prefs().selectedVoiceFullId ?? '';
  final serverUrl = OmnigramApi.instance.dio.options.baseUrl;
  final cap = ref.watch(ttsCapabilityCacheProvider)['$serverUrl::$voiceFullId'];

  return Card(
    margin: const EdgeInsets.all(12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.of(context).tts_capability_card_title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(_capabilityLine(context, cap)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              final cache = ref.read(ttsCapabilityCacheProvider.notifier);
              await cache.probe(
                serverUrl: serverUrl,
                voiceFullId: voiceFullId,
                voice: voiceFullId.replaceFirst('server:', ''),
              );
            },
            child: Text(L10n.of(context).tts_capability_recheck),
          ),
        ],
      ),
    ),
  );
}

String _capabilityLine(BuildContext ctx, TtsCapability? cap) {
  if (cap == null) return L10n.of(ctx).tts_capability_never_probed;
  final emoji = switch (cap.tier) {
    TtsCapabilityTier.green => '🟢',
    TtsCapabilityTier.yellow => '🟡',
    TtsCapabilityTier.red => '🔴',
    TtsCapabilityTier.na => '⚪',
  };
  final label = switch (cap.tier) {
    TtsCapabilityTier.green => L10n.of(ctx).tts_capability_tier_green,
    TtsCapabilityTier.yellow => L10n.of(ctx).tts_capability_tier_yellow,
    TtsCapabilityTier.red => L10n.of(ctx).tts_capability_tier_red,
    TtsCapabilityTier.na => L10n.of(ctx).tts_capability_tier_na,
  };
  return L10n.of(ctx).tts_capability_last_probed(
    cap.probedAt.toLocal().toString().split('.').first,
    emoji,
    label,
    cap.firstByteMs,
    cap.rtf.toStringAsFixed(2),
  );
}
```

- [ ] **Step 4: Add default-mode segmented**

Below the capability card, add a `SegmentedButton<TtsDefaultMode>` bound to `Prefs().ttsDefaultMode` (read via `TtsDefaultModeCodec.fromPref`, write via `.prefValue`).

```dart
Widget _buildDefaultModeSegmented(BuildContext ctx, WidgetRef ref) {
  final mode = TtsDefaultModeCodec.fromPref(Prefs().ttsDefaultMode);
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.of(ctx).tts_default_mode_title, style: Theme.of(ctx).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<TtsDefaultMode>(
            segments: [
              ButtonSegment(value: TtsDefaultMode.auto, label: Text(L10n.of(ctx).tts_default_mode_auto)),
              ButtonSegment(value: TtsDefaultMode.alwaysLive, label: Text(L10n.of(ctx).tts_default_mode_always_live)),
              ButtonSegment(value: TtsDefaultMode.alwaysPregen, label: Text(L10n.of(ctx).tts_default_mode_always_pregen)),
              ButtonSegment(value: TtsDefaultMode.alwaysLocal, label: Text(L10n.of(ctx).tts_default_mode_always_local)),
            ],
            selected: {mode},
            onSelectionChanged: (s) {
              Prefs().ttsDefaultMode = s.first.prefValue;
              ref.invalidate(ttsCapabilityCacheProvider); // forces recompute downstream
            },
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 5: Wire both widgets into the existing `build` method** of `NarratePage`. Place above existing voice picker section.

- [ ] **Step 6: Build + run app, manually verify**

```bash
cd app && flutter analyze lib/page/settings_page/narrate.dart && flutter run -d <device>
```

Manually: open Settings → 朗读 → see the card and segmented control. Tap re-run check (server must be running).

- [ ] **Step 7: Commit**

```bash
git add app/lib/page/settings_page/narrate.dart app/lib/l10n/
git commit -m "feat(app): TTS settings — voice health check card + default mode"
```

---

## Phase G — Chapter status dots

### Task 16: ChapterStatusDot widget + AudiobookPage integration

**Files:** Create `app/lib/widgets/audiobook/chapter_status_dot.dart`; modify `app/lib/page/audiobook/audiobook_page.dart`

- [ ] **Step 1: Implement the dot widget**

```dart
import 'package:flutter/material.dart';
import 'package:omnigram/service/tts/tts_router.dart';

class ChapterStatusDot extends StatelessWidget {
  const ChapterStatusDot({super.key, required this.status, this.percent});
  final ChapterAudioStatus status;
  final int? percent;

  @override
  Widget build(BuildContext context) {
    final (color, glyph, label) = switch (status) {
      ChapterAudioStatus.notGenerated => (Colors.grey.shade400, '○', '未生成'),
      ChapterAudioStatus.generating => (Colors.blue, '◐', '生成中 ${percent ?? 0}%'),
      ChapterAudioStatus.ready => (Colors.green, '●', '已就绪'),
      ChapterAudioStatus.localCached => (Colors.amber, '◌', '本地'),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(glyph, style: TextStyle(color: color, fontSize: 16, fontFamily: 'monospace')),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontFamily: 'monospace')),
      ],
    );
  }
}
```

- [ ] **Step 2: Integrate into AudiobookPage chapter rows**

Open `app/lib/page/audiobook/audiobook_page.dart`, find where each chapter row is built (look for chapter status rendering — there's already a status check at the line referenced as "status == 2"). Replace ad-hoc status text with:

```dart
ChapterStatusDot(
  status: switch (chapter.status) {
    2 => ChapterAudioStatus.ready,
    1 => ChapterAudioStatus.generating,
    _ => ChapterAudioStatus.notGenerated,
  },
  percent: chapter.status == 1 ? _progressPercent(chapter, info) : null,
),
```

- [ ] **Step 3: Verify enum int mapping again**

If your status int mapping from Task 14 was different, use the same mapping here.

- [ ] **Step 4: Analyze + manual check**

```bash
cd app && flutter analyze lib/widgets/audiobook/ lib/page/audiobook/audiobook_page.dart
```

Run app, open a book's audiobook page, verify dots render correctly across `notGenerated`/`generating`/`ready` states.

- [ ] **Step 5: Commit**

```bash
git add app/lib/widgets/audiobook/chapter_status_dot.dart app/lib/page/audiobook/audiobook_page.dart
git commit -m "feat(app): chapter status dots in AudiobookPage"
```

---

## Phase H — Feature flag + rollout + progress

### Task 17: Feature flag init

**Files:** Modify whichever app-init file runs once on first launch (commonly `app/lib/main.dart` or an `AppBootstrap` provider)

- [ ] **Step 1: Locate first-run init**

```bash
grep -rn "first.run\|onAppStart\|firstLaunch\|migration" app/lib/main.dart app/lib/config/ | head -10
```

- [ ] **Step 2: Add feature-flag default-set**

In the first-run path (where prefs are seeded):

```dart
// Adaptive routing rollout (spec §13).
// Fresh install → ON. Upgrade install → leave null (treated as OFF) until
// the user opts in via settings, or until a release N+2 unconditionally
// flips to ON for all users.
if (Prefs().experimentalTtsAdaptiveRouting == null && _isFreshInstall()) {
  Prefs().experimentalTtsAdaptiveRouting = true;
}
```

`_isFreshInstall()` should check whatever existing marker the app uses (e.g., absence of `app_version_last_seen`); reuse the existing migration framework rather than inventing a new flag.

- [ ] **Step 3: Gate the routing**

In `tts_playback_mode_provider.dart`, at the top of `ttsPlaybackMode`:

```dart
final adaptiveOn = Prefs().experimentalTtsAdaptiveRouting ?? false;
if (!adaptiveOn) {
  // Legacy path — pretend tier=GREEN, no overrides; existing audio path used.
  return PlaybackMode.liveServer;
}
```

- [ ] **Step 4: Add a "实验性功能" toggle in settings**

Add to `narrate.dart`, near the bottom of the page:

```dart
SwitchListTile(
  title: Text(L10n.of(ctx).tts_experimental_adaptive_title),
  subtitle: Text(L10n.of(ctx).tts_experimental_adaptive_subtitle),
  value: Prefs().experimentalTtsAdaptiveRouting ?? false,
  onChanged: (v) {
    setState(() {
      Prefs().experimentalTtsAdaptiveRouting = v;
    });
  },
),
```

Add the two L10n keys (en + zh-CN); regen.

- [ ] **Step 5: Analyze, commit**

```bash
cd app && flutter analyze lib/main.dart lib/page/settings_page/narrate.dart lib/providers/tts_playback_mode_provider.dart
git add app/lib/main.dart app/lib/page/settings_page/narrate.dart app/lib/providers/tts_playback_mode_provider.dart app/lib/l10n/
git commit -m "feat(app): adaptive TTS routing feature flag + experimental toggle"
```

---

### Task 18: Update PROGRESS.md

**Files:** Modify `docs/superpowers/PROGRESS.md`

- [ ] **Step 1: Add Sprint 7 row**

Append a section under existing sprints:

```markdown
## Sprint 7 — TTS 自适应路由（Plan 1 of 2）✅

> 设计：`specs/2026-04-27-tts-adaptive-degradation-design.md` · 计划：`plans/2026-04-27-tts-adaptive-routing.md`

| Item | 状态 | 关键文件 | Commit |
|---|---|---|---|
| Server `/tts/probe` 端点 | ✅ | `server/service/tts/probe_handler.go` | <fill> |
| App `TtsCapability` 模型 + 缓存 | ✅ | `lib/models/tts/tts_capability.dart`, `lib/providers/tts_capability_provider.dart` | <fill> |
| `TtsRouter` 决策矩阵 | ✅ | `lib/service/tts/tts_router.dart` | <fill> |
| 三种 `TtsAudioSource` 实现 | ✅ | `live_server_source.dart`, `pregen_server_source.dart`, `local_fallback_source.dart` | <fill> |
| `ttsPlaybackMode` Provider | ✅ | `lib/providers/tts_playback_mode_provider.dart` | <fill> |
| 设置页"声音体检"卡 + 默认模式 | ✅ | `lib/page/settings_page/narrate.dart` | <fill> |
| `AudiobookPage` 章节状态点 | ✅ | `lib/widgets/audiobook/chapter_status_dot.dart` | <fill> |
| 灰度 feature flag | ✅ | `experimental_tts_adaptive_routing` | <fill> |
| Now-Playing UX (Plan 2) | ⏳ | `plans/2026-04-27-tts-now-playing.md` (TBD) | — |
```

- [ ] **Step 2: Update top-level sprint index** if applicable.

- [ ] **Step 3: Commit**

```bash
git add docs/superpowers/PROGRESS.md
git commit -m "docs(progress): Sprint 7 plan-1 entry — TTS adaptive routing"
```

---

## Verification checklist (run all before declaring done)

- [ ] `cd server && go test ./service/tts/...` — all pass
- [ ] `cd server && make swagger` — clean diff (committed)
- [ ] `cd app && dart run build_runner build --delete-conflicting-outputs` — no errors
- [ ] `cd app && flutter analyze lib/` — no errors
- [ ] `cd app && flutter test test/service/tts/ test/providers/tts_capability_provider_test.dart` — all pass
- [ ] Manual: log into a server with TTS enabled → settings page shows capability card auto-populated within 10s of login
- [ ] Manual: tap re-run check → card updates with new metrics
- [ ] Manual: switch default mode → `ttsPlaybackMode` provider value changes for an open chapter (verify via DevTools or a debug print)
- [ ] Manual: open `AudiobookPage` for a partially-generated book → dots reflect correct states; SSE-driven generation flips dots live
