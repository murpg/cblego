# Lego CLI - Let's Encrypt Client Help

**Version:** 4.25.1

## Overview

Lego is a Let's Encrypt client written in Go that helps you register accounts, create, install, renew, and manage SSL/TLS certificates.

## Usage

```
lego [global options] command [command options]
```

## Commands

| Command | Description |
|---------|-------------|
| `run` | Register an account, then create and install a certificate |
| `revoke` | Revoke a certificate |
| `renew` | Renew a certificate |
| `dnshelp` | Shows additional help for the '--dns' global option |
| `list` | Display certificates and accounts information |
| `help, h` | Shows a list of commands or help for one command |

## Global Options

### Basic Configuration

| Option | Description | Default |
|--------|-------------|---------|
| `--domains value, -d value` | Add a domain to the process. Can be specified multiple times | |
| `--server value, -s value` | CA hostname (and optionally :port). The server certificate must be trusted | `https://acme-v02.api.letsencrypt.org/directory` |
| `--accept-tos, -a` | Accept the current Let's Encrypt terms of service | `false` |
| `--email value, -m value` | Email used for registration and recovery contact | |
| `--path value` | Directory to use for storing the data | `C:\Users\gmurphy\.lego` |

### Certificate Configuration

| Option | Description | Default |
|--------|-------------|---------|
| `--disable-cn` | Disable the use of the common name in the CSR | `false` |
| `--csr value, -c value` | Certificate signing request filename, if an external CSR is to be used | |
| `--key-type value, -k value` | Key type to use for private keys. Supported: rsa2048, rsa3072, rsa4096, rsa8192, ec256, ec384 | `ec256` |
| `--filename value` | (deprecated) Filename of the generated certificate | |

### External Account Binding (EAB)

| Option | Description | Default |
|--------|-------------|---------|
| `--eab` | Use External Account Binding for account registration. Requires --kid and --hmac | `false` |
| `--kid value` | Key identifier from External CA. Used for External Account Binding | |
| `--hmac value` | MAC key from External CA. Should be in Base64 URL Encoding without padding format | |

### HTTP-01 Challenge Options

| Option | Description | Default |
|--------|-------------|---------|
| `--http` | Use the HTTP-01 challenge to solve challenges. Can be mixed with other types | `false` |
| `--http.port value` | Set the port and interface to use for HTTP-01 based challenges. Supported: interface:port or :port | `:80` |
| `--http.delay value` | Delay between the starts of the HTTP server and the validation of the challenge | `0s` |
| `--http.proxy-header value` | Validate against this HTTP header when solving HTTP-01 based challenges behind a reverse proxy | `Host` |
| `--http.webroot value` | Set the webroot folder to use for HTTP-01 based challenges to write directly to the .well-known/acme-challenge file | |
| `--http.memcached-host value` | Set the memcached host(s) to use for HTTP-01 based challenges. Can be specified multiple times | |
| `--http.s3-bucket value` | Set the S3 bucket name to use for HTTP-01 based challenges | |

### TLS-ALPN-01 Challenge Options

| Option | Description | Default |
|--------|-------------|---------|
| `--tls` | Use the TLS-ALPN-01 challenge to solve challenges. Can be mixed with other types | `false` |
| `--tls.port value` | Set the port and interface to use for TLS-ALPN-01 based challenges. Supported: interface:port or :port | `:443` |
| `--tls.delay value` | Delay between the start of the TLS listener and the validation of the challenge | `0s` |

### DNS-01 Challenge Options

| Option | Description | Default |
|--------|-------------|---------|
| `--dns value` | Solve a DNS-01 challenge using the specified provider. Can be mixed with other types. Run 'lego dnshelp' for help | |
| `--dns.disable-cp` | (deprecated) use dns.propagation-disable-ans instead | `false` |
| `--dns.propagation-disable-ans` | Disables the need to await propagation of the TXT record to all authoritative name servers | `false` |
| `--dns.propagation-rns` | Use all the recursive nameservers to check the propagation of the TXT record | `false` |
| `--dns.propagation-wait value` | Disables all the propagation checks of the TXT record and uses a wait duration instead | `0s` |
| `--dns.resolvers value` | Set the resolvers to use for performing (recursive) CNAME resolving and apex domain determination. Can be specified multiple times | System resolvers or Google's DNS |

### Output Format Options

| Option | Description | Default |
|--------|-------------|---------|
| `--pem` | Generate an additional .pem (base64) file by concatenating the .key and .crt files together | `false` |
| `--pfx` | Generate an additional .pfx (PKCS#12) file by concatenating the .key and .crt and issuer .crt files together | `false` |
| `--pfx.pass value` | The password used to encrypt the .pfx (PCKS#12) file | `changeit` |
| `--pfx.format value` | The encoding format to use when encrypting the .pfx (PCKS#12) file. Supported: RC2, DES, SHA256 | `RC2` |

### Network and Timeout Options

| Option | Description | Default |
|--------|-------------|---------|
| `--http-timeout value` | Set the HTTP timeout value to a specific value in seconds | `0` |
| `--tls-skip-verify` | Skip the TLS verification of the ACME server | `false` |
| `--dns-timeout value` | Set the DNS timeout value to a specific value in seconds. Used only when performing authoritative name server queries | `10` |
| `--cert.timeout value` | Set the certificate timeout value to a specific value in seconds. Only used when obtaining certificates | `30` |
| `--overall-request-limit value` | ACME overall requests limit | `18` |

### Miscellaneous Options

| Option | Description |
|--------|-------------|
| `--user-agent value` | Add to the user-agent sent to the CA to identify an application embedding lego-cli |
| `--help, -h` | Show help |
| `--version, -v` | Print the version |

## Environment Variables

Several options can be set using environment variables (shown in brackets in the original help).

### `LEGO_SERVER` - Set the CA server
**What it does:** Specifies which Certificate Authority (CA) server to connect to for issuing certificates.

**Default:** Let's Encrypt production server (`https://acme-v02.api.letsencrypt.org/directory`)

**When to use:**
- **Testing:** Use Let's Encrypt staging server (`https://acme-staging-v02.api.letsencrypt.org/directory`) to avoid rate limits during development
- **Other CAs:** Use different certificate authorities like ZeroSSL, Buypass, or private ACME servers
- **Example:** `export LEGO_SERVER="https://acme-staging-v02.api.letsencrypt.org/directory"`

### `LEGO_EMAIL` - Set the email address
**What it does:** Sets the email address for your ACME account registration and certificate recovery notifications.

**When to use:**
- **Required for registration:** Most CAs require an email for account creation
- **Recovery:** Used if you lose access to your private key and need to recover certificates
- **Notifications:** Some CAs send expiration reminders to this email
- **Example:** `export LEGO_EMAIL="admin@example.com"`

### `LEGO_PATH` - Set the storage directory
**What it does:** Specifies where Lego stores account information, private keys, and certificates.

**Default:** `~/.lego` (or `C:\Users\username\.lego` on Windows)

**When to use:**
- **Custom location:** Store certificates in a specific directory (like `/etc/ssl/lego`)
- **Multiple environments:** Keep different certificate sets separate
- **Backup/restore:** Point to a backed-up certificate directory
- **Example:** `export LEGO_PATH="/etc/ssl/certificates"`

### `LEGO_EAB` - Enable External Account Binding
**What it does:** Enables External Account Binding, which links your ACME account to an existing account with the CA.

**When to use:**
- **Commercial CAs:** Some certificate authorities require you to have a paid account before issuing certificates
- **Enterprise environments:** Organizations that need to tie certificate issuance to billing/management accounts
- **ZeroSSL:** Requires EAB for programmatic certificate issuance
- **Must be used with:** `LEGO_EAB_KID` and `LEGO_EAB_HMAC`

### `LEGO_EAB_KID` - Set the EAB Key ID
**What it does:** Provides the Key Identifier that the CA gives you for External Account Binding.

**When to use:**
- **Only with EAB:** Must be set when `LEGO_EAB=true`
- **From your CA:** You get this value from your certificate authority's dashboard/API
- **Example:** `export LEGO_EAB_KID="eab_kid_1234567890abcdef"`

### `LEGO_EAB_HMAC` - Set the EAB HMAC key
**What it does:** Provides the HMAC (Hash-based Message Authentication Code) key for External Account Binding authentication.

**When to use:**
- **Only with EAB:** Must be set when `LEGO_EAB=true`
- **Security:** This is a secret key - treat it like a password
- **Format:** Must be in Base64 URL encoding without padding
- **Example:** `export LEGO_EAB_HMAC="base64url_encoded_hmac_key"`

### `LEGO_PFX` - Enable PFX file generation
**What it does:** Tells Lego to generate an additional `.pfx` file (PKCS#12 format) alongside the standard `.crt` and `.key` files.

**When to use:**
- **Windows servers:** IIS and other Windows applications prefer PFX format
- **Importing certificates:** PFX files bundle the certificate, private key, and CA chain in one file
- **Application compatibility:** Some applications only accept PKCS#12 format
- **Example:** `export LEGO_PFX=true`

### `LEGO_PFX_PASSWORD` - Set PFX password
**What it does:** Sets the password used to encrypt the PFX file.

**Default:** `"changeit"`

**When to use:**
- **Security:** Always change from the default password in production
- **Application requirements:** Some applications expect specific passwords
- **Automation:** Use in scripts where the password needs to be consistent
- **Example:** `export LEGO_PFX_PASSWORD="my_secure_password"`

### `LEGO_PFX_FORMAT` - Set PFX format
**What it does:** Specifies the encryption algorithm used when creating the PFX file.

**Default:** `RC2`
**Options:** `RC2`, `DES`, `SHA256`

**When to use:**
- **Compatibility:** Some older applications only support specific encryption formats
- **Security:** `SHA256` is more secure than `RC2` or `DES`
- **Modern applications:** Use `SHA256` for better security
- **Legacy systems:** Use `RC2` or `DES` if required by older software
- **Example:** `export LEGO_PFX_FORMAT="SHA256"`

### Practical Example
Here's how you might use several environment variables together for a production Windows environment:

```bash
export LEGO_EMAIL="certificates@mycompany.com"
export LEGO_PATH="/opt/certificates"
export LEGO_PFX=true
export LEGO_PFX_PASSWORD="SecurePassword123!"
export LEGO_PFX_FORMAT="SHA256"

lego --domains example.com --http run
```

This would create certificates for `example.com` and generate both standard certificate files and a secure PFX file ready for Windows deployment.

## Challenge Types

Lego supports three types of ACME challenges for proving domain ownership. Each method has different requirements and use cases:

### HTTP-01 Challenge (`--http`)
**How it works:** The CA sends a challenge token, and Lego serves a specific file at `http://yourdomain.com/.well-known/acme-challenge/TOKEN` to prove you control the domain.

**Requirements:**
- Port 80 must be accessible from the internet
- Domain must resolve to the server running Lego
- Can be used with reverse proxies

**When to use:**
- **Simple setup:** Easiest method for basic web servers
- **Single domains:** Works well for individual domains
- **Web hosting:** When you already have a web server running

**Limitations:**
- **Port 80 required:** Must have port 80 open and accessible
- **No wildcards:** Cannot issue wildcard certificates (*.example.com)
- **Public access:** Domain must be publicly accessible

**Example:**
```bash
lego --domains example.com --http --accept-tos --email admin@example.com run
```

**Advanced options:**
- `--http.webroot`: Use existing web server by writing files to webroot
- `--http.port`: Change the port (useful behind reverse proxies)
- `--http.proxy-header`: Handle reverse proxy setups

### TLS-ALPN-01 Challenge (`--tls`)
**How it works:** The CA connects to your domain on port 443 and checks for a special certificate with the challenge token embedded in a TLS extension.

**Requirements:**
- Port 443 must be accessible from the internet
- Domain must resolve to the server running Lego
- No existing TLS service can be running on port 443 during validation

**When to use:**
- **Port 80 blocked:** When HTTP is not available but HTTPS is
- **Security requirements:** Some environments block HTTP but allow HTTPS
- **Firewall restrictions:** When only port 443 is open

**Limitations:**
- **Port 443 required:** Must have exclusive access to port 443 during validation
- **No wildcards:** Cannot issue wildcard certificates
- **Service interruption:** Must temporarily stop existing TLS services

**Example:**
```bash
lego --domains example.com --tls --accept-tos --email admin@example.com run
```

**Advanced options:**
- `--tls.port`: Change the port if using a non-standard setup
- `--tls.delay`: Add delay before validation starts

### DNS-01 Challenge (`--dns`)
**How it works:** Lego creates a TXT record at `_acme-challenge.yourdomain.com` with a challenge token to prove you control the DNS for the domain.

**Requirements:**
- Access to modify DNS records for the domain
- Supported DNS provider (use `lego dnshelp` to see available providers)
- API credentials for your DNS provider

**When to use:**
- **Wildcard certificates:** Only method that supports `*.example.com` certificates
- **Internal servers:** Servers not accessible from the internet
- **Multiple subdomains:** Efficient for many subdomains
- **Firewall restrictions:** When ports 80/443 are not accessible
- **Load balancers:** When you can't control individual server ports

**Advantages:**
- **Wildcard support:** Can issue `*.example.com` certificates
- **No server requirements:** Works for internal/private servers
- **Multiple domains:** Efficient for many domains/subdomains
- **No port requirements:** Doesn't need open ports

**Limitations:**
- **DNS provider support:** Must use a supported DNS provider
- **API access:** Requires DNS API credentials
- **Propagation delays:** DNS changes take time to propagate

**Example:**
```bash
# For Cloudflare DNS
export CLOUDFLARE_EMAIL="admin@example.com"
export CLOUDFLARE_API_KEY="your-api-key"
lego --domains example.com --domains "*.example.com" --dns cloudflare --accept-tos --email admin@example.com run

# For Route53 DNS
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
lego --domains example.com --dns route53 --accept-tos --email admin@example.com run
```

**Advanced options:**
- `--dns.propagation-wait`: Set a fixed wait time instead of checking propagation
- `--dns.propagation-disable-ans`: Skip checking all authoritative nameservers
- `--dns.resolvers`: Use specific DNS resolvers for verification

### Choosing the Right Challenge Type

| Scenario | Recommended Challenge | Reason |
|----------|----------------------|---------|
| Simple web server with public access | HTTP-01 | Easiest setup, no additional configuration needed |
| Need wildcard certificates (*.example.com) | DNS-01 | Only method that supports wildcards |
| Internal/private servers | DNS-01 | No need for public accessibility |
| Port 80 blocked, port 443 open | TLS-ALPN-01 | Alternative when HTTP is unavailable |
| Multiple subdomains | DNS-01 | More efficient than individual HTTP challenges |
| Behind load balancer/CDN | DNS-01 | Avoids routing complexities |
| High security environment | DNS-01 | No need to expose challenge ports |

### Combining Challenge Types
You can mix different challenge types for different domains in a single command:

```bash
lego --domains example.com --http \
     --domains internal.example.com --dns cloudflare \
     --domains "*.api.example.com" --dns cloudflare \
     --accept-tos --email admin@example.com run
```

This example uses HTTP-01 for the main domain and DNS-01 for internal and wildcard domains.
