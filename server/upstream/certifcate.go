package upstream

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"math/big"
	"os"
	"sort"
	"strings"
	"time"

	"github.com/lxpio/omnigram/server/log"
)

const certificateHeader = "-----BEGIN CERTIFICATE-----\n"

// DefaultDomain  domain for the default certificate.
const DefaultDomain = "DEFAULT CERT"

// Certificate holds a SSL cert/key pair
// Certs and Key could be either a file path, or the file content itself.
type Certificate struct {
	CertFile FileOrContent `json:"certFile,omitempty" toml:"certFile,omitempty" yaml:"certFile,omitempty"`
	KeyFile  FileOrContent `json:"keyFile,omitempty" toml:"keyFile,omitempty" yaml:"keyFile,omitempty"`
}

// Certificates defines traefik certificates type
// Certs and Keys could be either a file path, or the file content itself.
type Certificates []Certificate

// GetCertificates retrieves the certificates as slice of tls.Certificate.
func (c Certificates) GetCertificates() []tls.Certificate {
	var certs []tls.Certificate

	for _, certificate := range c {
		cert, err := certificate.GetCertificate()
		if err != nil {
			log.D("Error while getting certificate: ", err)
			continue
		}

		certs = append(certs, cert)
	}

	return certs
}

// CreateTLSConfig creates a TLS config from Certificate structures.
func (c *Certificates) CreateTLSConfig(entryPointName string) (*tls.Config, error) {
	config := &tls.Config{}
	domainsCertificates := make(map[string]map[string]*tls.Certificate)

	if c.isEmpty() {
		config.Certificates = []tls.Certificate{}

		cert, err := DefaultCertificate()
		if err != nil {
			return nil, err
		}

		config.Certificates = append(config.Certificates, *cert)
	} else {
		for _, certificate := range *c {
			err := certificate.AppendCertificate(domainsCertificates, entryPointName)
			if err != nil {
				log.E("Unable to add a certificate to the entryPoint ", entryPointName, ` : `, err)
				continue
			}

			for _, certDom := range domainsCertificates {
				for _, cert := range certDom {
					config.Certificates = append(config.Certificates, *cert)
				}
			}
		}
	}
	return config, nil
}

// isEmpty checks if the certificates list is empty.
func (c *Certificates) isEmpty() bool {
	if len(*c) == 0 {
		return true
	}
	var key int
	for _, cert := range *c {
		if len(cert.CertFile.String()) != 0 && len(cert.KeyFile.String()) != 0 {
			break
		}
		key++
	}
	return key == len(*c)
}

// AppendCertificate appends a Certificate to a certificates map keyed by entrypoint.
func (c *Certificate) AppendCertificate(certs map[string]map[string]*tls.Certificate, ep string) error {
	certContent, err := c.CertFile.Read()
	if err != nil {
		return fmt.Errorf("unable to read CertFile : %w", err)
	}

	keyContent, err := c.KeyFile.Read()
	if err != nil {
		return fmt.Errorf("unable to read KeyFile : %w", err)
	}
	tlsCert, err := tls.X509KeyPair(certContent, keyContent)
	if err != nil {
		return fmt.Errorf("unable to generate TLS certificate : %w", err)
	}

	parsedCert, _ := x509.ParseCertificate(tlsCert.Certificate[0])

	var SANs []string
	if parsedCert.Subject.CommonName != "" {
		SANs = append(SANs, strings.ToLower(parsedCert.Subject.CommonName))
	}
	if parsedCert.DNSNames != nil {
		sort.Strings(parsedCert.DNSNames)
		for _, dnsName := range parsedCert.DNSNames {
			if dnsName != parsedCert.Subject.CommonName {
				SANs = append(SANs, strings.ToLower(dnsName))
			}
		}
	}
	if parsedCert.IPAddresses != nil {
		for _, ip := range parsedCert.IPAddresses {
			if ip.String() != parsedCert.Subject.CommonName {
				SANs = append(SANs, strings.ToLower(ip.String()))
			}
		}
	}
	certKey := strings.Join(SANs, ",")

	certExists := false
	if certs[ep] == nil {
		certs[ep] = make(map[string]*tls.Certificate)
	} else {
		for domains := range certs[ep] {
			if domains == certKey {
				certExists = true
				break
			}
		}
	}
	if certExists {
		log.D("Skipping addition of certificate for domain(s) ", certKey, "to EntryPoint", ep, " as it already exists for this Entrypoint.")
	} else {
		log.D("Adding certificate for domain(s) ", certKey)
		certs[ep][certKey] = &tlsCert
	}

	return err
}

// GetCertificate retrieves Certificate as tls.Certificate.
func (c *Certificate) GetCertificate() (tls.Certificate, error) {
	certContent, err := c.CertFile.Read()
	if err != nil {
		return tls.Certificate{}, fmt.Errorf("unable to read CertFile : %w", err)
	}

	keyContent, err := c.KeyFile.Read()
	if err != nil {
		return tls.Certificate{}, fmt.Errorf("unable to read KeyFile : %w", err)
	}

	cert, err := tls.X509KeyPair(certContent, keyContent)
	if err != nil {
		return tls.Certificate{}, fmt.Errorf("unable to generate TLS certificate : %w", err)
	}

	return cert, nil
}

// GetTruncatedCertificateName truncates the certificate name.
func (c *Certificate) GetTruncatedCertificateName() string {
	certName := c.CertFile.String()

	// Truncate certificate information only if it's a well formed certificate content with more than 50 characters
	if !c.CertFile.IsPath() && strings.HasPrefix(certName, certificateHeader) && len(certName) > len(certificateHeader)+50 {
		certName = strings.TrimPrefix(c.CertFile.String(), certificateHeader)[:50]
	}

	return certName
}

// String is the method to format the flag's value, part of the flag.Value interface.
// The String method's output will be used in diagnostics.
func (c *Certificates) String() string {
	if len(*c) == 0 {
		return ""
	}
	var result []string
	for _, certificate := range *c {
		result = append(result, certificate.CertFile.String()+","+certificate.KeyFile.String())
	}
	return strings.Join(result, ";")
}

// Set is the method to set the flag value, part of the flag.Value interface.
// Set's argument is a string to be parsed to set the flag.
// It's a comma-separated list, so we split it.
func (c *Certificates) Set(value string) error {
	certificates := strings.Split(value, ";")
	for _, certificate := range certificates {
		files := strings.Split(certificate, ",")
		if len(files) != 2 {
			return fmt.Errorf("bad certificates format: %s", value)
		}
		*c = append(*c, Certificate{
			CertFile: FileOrContent(files[0]),
			KeyFile:  FileOrContent(files[1]),
		})
	}
	return nil
}

// Type is type of the struct.
func (c *Certificates) Type() string {
	return "certificates"
}

// DefaultCertificate generates random TLS certificates.
func DefaultCertificate() (*tls.Certificate, error) {
	randomBytes := make([]byte, 100)
	_, err := rand.Read(randomBytes)
	if err != nil {
		return nil, err
	}
	zBytes := sha256.Sum256(randomBytes)
	z := hex.EncodeToString(zBytes[:sha256.Size])
	domain := fmt.Sprintf("%s.%s.default", z[:32], z[32:])

	certPEM, keyPEM, err := KeyPair(domain, time.Time{})
	if err != nil {
		return nil, err
	}

	certificate, err := tls.X509KeyPair(certPEM, keyPEM)
	if err != nil {
		return nil, err
	}

	return &certificate, nil
}

// KeyPair generates cert and key files.
func KeyPair(domain string, expiration time.Time) ([]byte, []byte, error) {
	rsaPrivKey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		return nil, nil, err
	}
	keyPEM := pem.EncodeToMemory(&pem.Block{Type: "RSA PRIVATE KEY", Bytes: x509.MarshalPKCS1PrivateKey(rsaPrivKey)})

	certPEM, err := PemCert(rsaPrivKey, domain, expiration)
	if err != nil {
		return nil, nil, err
	}
	return certPEM, keyPEM, nil
}

// PemCert generates PEM cert file.
func PemCert(privKey *rsa.PrivateKey, domain string, expiration time.Time) ([]byte, error) {
	derBytes, err := derCert(privKey, expiration, domain)
	if err != nil {
		return nil, err
	}

	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: derBytes}), nil
}

func derCert(privKey *rsa.PrivateKey, expiration time.Time, domain string) ([]byte, error) {
	serialNumberLimit := new(big.Int).Lsh(big.NewInt(1), 128)
	serialNumber, err := rand.Int(rand.Reader, serialNumberLimit)
	if err != nil {
		return nil, err
	}

	if expiration.IsZero() {
		expiration = time.Now().Add(365 * (24 * time.Hour))
	}

	template := x509.Certificate{
		SerialNumber: serialNumber,
		Subject: pkix.Name{
			CommonName: DefaultDomain,
		},
		NotBefore: time.Now(),
		NotAfter:  expiration,

		KeyUsage:              x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature | x509.KeyUsageKeyAgreement | x509.KeyUsageDataEncipherment,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
		DNSNames:              []string{domain},
	}

	return x509.CreateCertificate(rand.Reader, &template, &template, &privKey.PublicKey, privKey)
}

func createRootCACertPool(rootCAs []FileOrContent) *x509.CertPool {
	if len(rootCAs) == 0 {
		return nil
	}

	roots := x509.NewCertPool()

	for _, cert := range rootCAs {
		certContent, err := cert.Read()
		if err != nil {
			log.E("Error while read RootCAs", err)
			continue
		}
		roots.AppendCertsFromPEM(certContent)
	}

	return roots
}

// FileOrContent hold a file path or content.
type FileOrContent string

func (f FileOrContent) String() string {
	return string(f)
}

// IsPath returns true if the FileOrContent is a file path, otherwise returns false.
func (f FileOrContent) IsPath() bool {
	_, err := os.Stat(f.String())
	return err == nil
}

func (f FileOrContent) Read() ([]byte, error) {
	var content []byte
	if f.IsPath() {
		var err error
		content, err = os.ReadFile(f.String())
		if err != nil {
			return nil, err
		}
	} else {
		content = []byte(f)
	}
	return content, nil
}
