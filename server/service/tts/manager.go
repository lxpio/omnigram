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
func (m *TTSManager) Synthesize(ctx context.Context, text string, opts SynthesisOptions) (io.ReadCloser, error) {
	ctx, cancel := context.WithTimeout(ctx, m.timeout)
	defer cancel()

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
		log.W("primary TTS failed, falling back: " + err.Error())
	}

	if m.fallback != nil {
		return m.fallback.Synthesize(ctx, text, opts)
	}
	return nil, errors.New("all TTS providers unavailable")
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
