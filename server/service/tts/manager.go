package tts

import (
	"context"
	"errors"
	"io"
	"net"
	"sync"
	"time"

	"github.com/lxpio/omnigram/server/log"
)

// TTSManager manages Provider lifecycle, fallback chain, and circuit breaker.
type TTSManager struct {
	primary  TTSProvider
	fallback TTSProvider
	breaker  *circuitBreaker
	timeout  time.Duration
}

// NewTTSManager creates a manager with primary and optional fallback provider.
func NewTTSManager(primary, fallback TTSProvider, timeout time.Duration) *TTSManager {
	return &TTSManager{
		primary:  primary,
		fallback: fallback,
		breaker:  newCircuitBreaker(5, 30*time.Second),
		timeout:  timeout,
	}
}

// Synthesize tries primary with retry, falls back on failure.
//
// NOTE: we intentionally do NOT wrap `ctx` with a local WithTimeout here.
// Providers return an `io.ReadCloser` whose body is streamed by the caller
// after Synthesize returns; a `defer cancel()` would cancel the context the
// moment we return, truncating the response body mid-stream. Per-request
// timeouts are enforced by the sidecar's own `http.Client.Timeout`, and the
// caller (handler / worker) controls the overall deadline via its own ctx.
func (m *TTSManager) Synthesize(ctx context.Context, text string, opts SynthesisOptions) (io.ReadCloser, error) {
	var primaryErr error
	if m.breaker.allow() {
		result, err := m.primary.Synthesize(ctx, text, opts)
		if err != nil && isRetryable(err) {
			result, err = m.primary.Synthesize(ctx, text, opts)
		}
		if err == nil {
			m.breaker.success()
			return result, nil
		}
		m.breaker.fail()
		primaryErr = err
		log.W("primary TTS failed (voice=" + opts.Voice + "): " + err.Error())
	} else {
		primaryErr = errors.New("primary unavailable (circuit breaker open)")
	}

	// Only fall back if the fallback provider can actually honour the
	// requested voice. Otherwise the listener hears a totally different
	// voice for the affected sentences — much worse UX than surfacing a
	// transient error and letting the caller retry.
	if m.fallback != nil && providerSupportsVoice(m.fallback, opts.Voice) {
		log.W("falling back to " + m.fallback.Name() + " for voice " + opts.Voice)
		return m.fallback.Synthesize(ctx, text, opts)
	}
	if m.fallback != nil {
		log.W("skipping fallback " + m.fallback.Name() + ": voice '" + opts.Voice + "' not in its voice list")
	}
	if primaryErr != nil {
		return nil, primaryErr
	}
	return nil, errors.New("all TTS providers unavailable")
}

// providerSupportsVoice returns true when the voice is empty (provider may
// substitute its own default) or when the voice id appears in the provider's
// Voices() list. We deliberately do exact-id matching: a Kokoro voice like
// `af_sky` should never silently become an Edge voice like
// `zh-CN-XiaoxiaoNeural`.
func providerSupportsVoice(p TTSProvider, voice string) bool {
	if voice == "" {
		return true
	}
	for _, v := range p.Voices() {
		if v.ID == voice {
			return true
		}
	}
	return false
}

// HealthCheck checks primary provider health.
func (m *TTSManager) HealthCheck(ctx context.Context) error {
	if m.primary != nil {
		return m.primary.HealthCheck(ctx)
	}
	return errors.New("no primary TTS provider configured")
}

// isRetryable returns true for transient network errors.
func isRetryable(err error) bool {
	if errors.Is(err, context.DeadlineExceeded) || errors.Is(err, context.Canceled) {
		return false
	}
	var netErr net.Error
	if errors.As(err, &netErr) {
		return netErr.Timeout()
	}
	return false
}

// circuitBreaker prevents repeated calls to a failing provider.
type circuitBreaker struct {
	mu           sync.Mutex
	failures     int
	threshold    int
	lastFailure  time.Time
	resetTimeout time.Duration
}

func newCircuitBreaker(threshold int, resetTimeout time.Duration) *circuitBreaker {
	return &circuitBreaker{
		threshold:    threshold,
		resetTimeout: resetTimeout,
	}
}

func (cb *circuitBreaker) allow() bool {
	cb.mu.Lock()
	defer cb.mu.Unlock()

	if cb.failures < cb.threshold {
		return true
	}
	// Reset after timeout
	if time.Since(cb.lastFailure) > cb.resetTimeout {
		cb.failures = 0
		return true
	}
	return false
}

func (cb *circuitBreaker) success() {
	cb.mu.Lock()
	defer cb.mu.Unlock()
	cb.failures = 0
}

func (cb *circuitBreaker) fail() {
	cb.mu.Lock()
	defer cb.mu.Unlock()
	cb.failures++
	cb.lastFailure = time.Now()
}
