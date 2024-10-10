package upstream

import (
	"bufio"
	"context"
	"errors"
	"io"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/utils"
	"golang.org/x/net/http/httpguts"
	"golang.org/x/net/http2"
)

// StatusClientClosedRequest non-standard HTTP status code for client disconnection.
const StatusClientClosedRequest = 499

// StatusClientClosedRequestText non-standard HTTP status for client disconnection.
const StatusClientClosedRequestText = "Client Closed Request"

// HandlerFunc defines the handler used by gin middleware as return value.
type HandlerFunc func(c *gin.Context) utils.Response

func NewProxyHandler(remoteAddr string) (HandlerFunc, error) {
	u, err := url.Parse(remoteAddr)
	if err != nil {

		log.E("failed to parse URL '%s': %s", remoteAddr, err)
		return nil, err
	}

	next, err := buildProxy(defaultRoundTripper, defaultBufferPool)

	if err != nil {

		log.E("failed to parse URL '%s': %s", remoteAddr, err)
		return nil, err
	}

	return NewPipeliningHandlerFunc(u, next), nil

	// return nil, err

}

func NewPipeliningHandlerFunc(u *url.URL, next http.Handler) HandlerFunc {

	return func(c *gin.Context) utils.Response {

		orginHost := c.Request.Host
		c.Request.URL = u
		c.Request.Host = orginHost

		println(u.String(), orginHost)

		// https://github.com/golang/go/blob/3d59583836630cf13ec4bfbed977d27b1b7adbdc/src/net/http/server.go#L201-L218
		if c.Request.Method == http.MethodPut || c.Request.Method == http.MethodPost {
			next.ServeHTTP(c.Writer, c.Request)
		} else {
			next.ServeHTTP(&writerWithoutCloseNotify{c.Writer}, c.Request)
		}

		return utils.SUCCESS

	}

}

func buildProxy(roundTripper http.RoundTripper, bufferPool httputil.BufferPool) (http.Handler, error) {

	proxy := &httputil.ReverseProxy{
		Director:      directorBuilder(),
		Transport:     roundTripper,
		FlushInterval: 100 * time.Millisecond,
		BufferPool:    bufferPool,
		ErrorHandler: func(w http.ResponseWriter, request *http.Request, err error) {
			statusCode := http.StatusInternalServerError

			switch {
			case errors.Is(err, io.EOF):
				statusCode = http.StatusBadGateway
			case errors.Is(err, context.Canceled):
				statusCode = StatusClientClosedRequest
			default:
				var netErr net.Error
				if errors.As(err, &netErr) {
					if netErr.Timeout() {
						statusCode = http.StatusGatewayTimeout
					} else {
						statusCode = http.StatusBadGateway
					}
				}
			}

			log.D("'%d %s' caused by: %v", statusCode, statusText(statusCode), err)

			w.WriteHeader(statusCode)
			_, werr := w.Write([]byte(statusText(statusCode)))
			if werr != nil {
				log.D("Error while writing status code", werr)
			}
		},
	}

	return proxy, nil
}

func directorBuilder() func(req *http.Request) {
	return func(outReq *http.Request) {

		// outReq.URL.Scheme = target.Scheme
		// outReq.URL.Host = target.Host

		u := outReq.URL
		if outReq.RequestURI != "" {
			parsedURL, err := url.ParseRequestURI(outReq.RequestURI)
			if err == nil {
				u = parsedURL
			}
		}

		// If a plugin/middleware adds semicolons in query params, they should be urlEncoded.
		outReq.URL.RawQuery = strings.ReplaceAll(u.RawQuery, ";", "&")

		outReq.URL.Path = u.Path
		outReq.URL.RawPath = u.RawPath
		outReq.URL.RawQuery = u.RawQuery
		outReq.RequestURI = "" // Outgoing request should not have RequestURI

		outReq.Proto = "HTTP/1.1"
		outReq.ProtoMajor = 1
		outReq.ProtoMinor = 1

		if _, ok := outReq.Header["User-Agent"]; !ok {
			outReq.Header.Set("User-Agent", "")
		}

		// Do not pass client Host header unless optsetter PassHostHeader is set.
		// log.D(`代理host：`, outReq.Host, outReq.URL.Host)
		// outReq.Host = outReq.URL.Host

		cleanWebSocketHeaders(outReq)
	}
}

// cleanWebSocketHeaders Even if the websocket RFC says that headers should be case-insensitive,
// some servers need Sec-WebSocket-Key, Sec-WebSocket-Extensions, Sec-WebSocket-Accept,
// Sec-WebSocket-Protocol and Sec-WebSocket-Version to be case-sensitive.
// https://tools.ietf.org/html/rfc6455#page-20
func cleanWebSocketHeaders(req *http.Request) {
	if !isWebSocketUpgrade(req) {
		return
	}

	req.Header["Sec-WebSocket-Key"] = req.Header["Sec-Websocket-Key"]
	delete(req.Header, "Sec-Websocket-Key")

	req.Header["Sec-WebSocket-Extensions"] = req.Header["Sec-Websocket-Extensions"]
	delete(req.Header, "Sec-Websocket-Extensions")

	req.Header["Sec-WebSocket-Accept"] = req.Header["Sec-Websocket-Accept"]
	delete(req.Header, "Sec-Websocket-Accept")

	req.Header["Sec-WebSocket-Protocol"] = req.Header["Sec-Websocket-Protocol"]
	delete(req.Header, "Sec-Websocket-Protocol")

	req.Header["Sec-WebSocket-Version"] = req.Header["Sec-Websocket-Version"]
	delete(req.Header, "Sec-Websocket-Version")
}

func isWebSocketUpgrade(req *http.Request) bool {
	return httpguts.HeaderValuesContainsToken(req.Header["Connection"], "Upgrade") &&
		strings.EqualFold(req.Header.Get("Upgrade"), "websocket")
}

type h2cTransportWrapper struct {
	*http2.Transport
}

func statusText(statusCode int) string {
	if statusCode == StatusClientClosedRequest {
		return StatusClientClosedRequestText
	}
	return http.StatusText(statusCode)
}

// writerWithoutCloseNotify helps to disable closeNotify.
type writerWithoutCloseNotify struct {
	W http.ResponseWriter
}

// Header returns the response headers.
func (w *writerWithoutCloseNotify) Header() http.Header {
	return w.W.Header()
}

// Write writes the data to the connection as part of an HTTP reply.
func (w *writerWithoutCloseNotify) Write(buf []byte) (int, error) {
	return w.W.Write(buf)
}

// WriteHeader sends an HTTP response header with the provided status code.
func (w *writerWithoutCloseNotify) WriteHeader(code int) {
	w.W.WriteHeader(code)
}

// Flush sends any buffered data to the client.
func (w *writerWithoutCloseNotify) Flush() {
	if f, ok := w.W.(http.Flusher); ok {
		f.Flush()
	}
}

// Hijack hijacks the connection.
func (w *writerWithoutCloseNotify) Hijack() (net.Conn, *bufio.ReadWriter, error) {
	return w.W.(http.Hijacker).Hijack()
}
