package upstream

import (
	"net/http"
	"time"

	"golang.org/x/net/http/httpguts"
	"golang.org/x/net/http2"
)

type ServersTransport struct {
	ServerName          string              `json:"serverName,omitempty" toml:"serverName,omitempty" yaml:"serverName,omitempty"`                                          // ServerName used to contact the server
	InsecureSkipVerify  bool                `json:"insecureSkipVerify,omitempty" toml:"insecureSkipVerify,omitempty" yaml:"insecureSkipVerify,omitempty" export:"true"`    // Disable SSL certificate verification.
	RootCAs             []FileOrContent     `json:"rootCAs,omitempty" toml:"rootCAs,omitempty" yaml:"rootCAs,omitempty"`                                                   // Add cert file for self-signed certificate.
	Certificates        Certificates        `json:"certificates,omitempty" toml:"certificates,omitempty" yaml:"certificates,omitempty" export:"true"`                      // Certificates for mTLS.
	MaxIdleConnsPerHost int                 `json:"maxIdleConnsPerHost,omitempty" toml:"maxIdleConnsPerHost,omitempty" yaml:"maxIdleConnsPerHost,omitempty" export:"true"` // If non-zero, controls the maximum idle (keep-alive) to keep per-host. If zero, DefaultMaxIdleConnsPerHost is used
	ForwardingTimeouts  *ForwardingTimeouts `json:"forwardingTimeouts,omitempty" toml:"forwardingTimeouts,omitempty" yaml:"forwardingTimeouts,omitempty" export:"true"`    // Timeouts for requests forwarded to the backend servers.
	DisableHTTP2        bool                `json:"disableHTTP2,omitempty" toml:"disableHTTP2,omitempty" yaml:"disableHTTP2,omitempty" export:"true"`                      // Disable HTTP/2 for connections with backend servers.
}

// ForwardingTimeouts contains timeout configurations for forwarding requests to the backend servers.
type ForwardingTimeouts struct {
	DialTimeout           time.Duration `json:"dialTimeout,omitempty" toml:"dialTimeout,omitempty" yaml:"dialTimeout,omitempty" export:"true"`                               //The amount of time to wait until a connection to a backend server can be established. If zero, no timeout exists.
	ResponseHeaderTimeout time.Duration `json:"responseHeaderTimeout,omitempty" toml:"responseHeaderTimeout,omitempty" yaml:"responseHeaderTimeout,omitempty" export:"true"` //The amount of time to wait for a server's response headers after fully writing the request (including its body, if any). If zero, no timeout exists.
	IdleConnTimeout       time.Duration `json:"idleConnTimeout,omitempty" toml:"idleConnTimeout,omitempty" yaml:"idleConnTimeout,omitempty" export:"true"`                   //The maximum period for which an idle HTTP keep-alive connection will remain open before closing itself
}

// SetDefaults sets the default values.
func (f *ForwardingTimeouts) SetDefaults() {
	f.DialTimeout = 30 * time.Second
	f.IdleConnTimeout = 90 * time.Second
}

func newSmartRoundTripper(transport *http.Transport) (http.RoundTripper, error) {
	transportHTTP1 := transport.Clone()

	err := http2.ConfigureTransport(transport)
	if err != nil {
		return nil, err
	}

	return &smartRoundTripper{
		http2: transport,
		http:  transportHTTP1,
	}, nil
}

type smartRoundTripper struct {
	http2 *http.Transport
	http  *http.Transport
}

// smartRoundTripper implements RoundTrip while making sure that HTTP/2 is not used
// with protocols that start with a Connection Upgrade, such as SPDY or Websocket.
func (m *smartRoundTripper) RoundTrip(req *http.Request) (*http.Response, error) {
	// If we have a connection upgrade, we don't use HTTP/2
	if httpguts.HeaderValuesContainsToken(req.Header["Connection"], "Upgrade") {
		return m.http.RoundTrip(req)
	}

	return m.http2.RoundTrip(req)
}
