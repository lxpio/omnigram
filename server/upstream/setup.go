package upstream

import (
	"crypto/tls"
	"errors"
	"net"
	"net/http"
	"time"

	"golang.org/x/net/http2"
)

var (
	defaultRoundTripper http.RoundTripper
	defaultBufferPool   *bufferPool
)

func init() {
	// 初始化数据库连接
	// 初始化日志

	defaultRoundTripper, _ = createRoundTripper(nil)
	defaultBufferPool = NewBufferPool()
}

// createRoundTripper creates an http.RoundTripper configured with the Transport configuration settings.
// For the settings that can't be configured in Traefik it uses the default http.Transport settings.
// An exception to this is the MaxIdleConns setting as we only provide the option MaxIdleConnsPerHost in Traefik at this point in time.
// Setting this value to the default of 100 could lead to confusing behavior and backwards compatibility issues.
func createRoundTripper(cfg *ServersTransport) (http.RoundTripper, error) {
	if cfg == nil {

		cfg = &ServersTransport{
			ServerName:          "",
			InsecureSkipVerify:  false,
			RootCAs:             nil,
			Certificates:        nil,
			MaxIdleConnsPerHost: 200,
			ForwardingTimeouts:  nil,
			DisableHTTP2:        false,
		}

		return nil, errors.New("no transport configuration given")
	}

	dialer := &net.Dialer{
		Timeout:   30 * time.Second,
		KeepAlive: 30 * time.Second,
	}

	if cfg.ForwardingTimeouts != nil {
		dialer.Timeout = time.Duration(cfg.ForwardingTimeouts.DialTimeout)
	}

	transport := &http.Transport{
		Proxy:                 http.ProxyFromEnvironment,
		DialContext:           dialer.DialContext,
		MaxIdleConnsPerHost:   cfg.MaxIdleConnsPerHost,
		IdleConnTimeout:       90 * time.Second,
		TLSHandshakeTimeout:   10 * time.Second,
		ExpectContinueTimeout: 1 * time.Second,
		ReadBufferSize:        64 * 1024,
		WriteBufferSize:       64 * 1024,
	}

	if cfg.ForwardingTimeouts != nil {
		transport.ResponseHeaderTimeout = time.Duration(cfg.ForwardingTimeouts.ResponseHeaderTimeout)
		transport.IdleConnTimeout = time.Duration(cfg.ForwardingTimeouts.IdleConnTimeout)
	}

	if cfg.InsecureSkipVerify || len(cfg.RootCAs) > 0 || len(cfg.ServerName) > 0 || len(cfg.Certificates) > 0 {
		transport.TLSClientConfig = &tls.Config{
			ServerName:         cfg.ServerName,
			InsecureSkipVerify: cfg.InsecureSkipVerify,
			RootCAs:            createRootCACertPool(cfg.RootCAs),
			Certificates:       cfg.Certificates.GetCertificates(),
		}
	}

	// Return directly HTTP/1.1 transport when HTTP/2 is disabled
	if cfg.DisableHTTP2 {
		return transport, nil
	}

	transport.RegisterProtocol("h2c", &h2cTransportWrapper{
		Transport: &http2.Transport{
			DialTLS: func(netw, addr string, cfg *tls.Config) (net.Conn, error) {
				return net.Dial(netw, addr)
			},
			AllowHTTP: true,
		},
	})

	return newSmartRoundTripper(transport)
}
