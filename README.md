# CommandBox Lego Module

> A CommandBox module that wraps the Lego ACME client for easy SSL certificate generation

This module provides a convenient way to generate SSL certificates using Let's Encrypt directly from your CommandBox CLI. It integrates the Lego ACME client, allowing you to generate certificates using DNS challenges with support for multiple DNS providers.

## How Lego Works

Lego uses DNS-01 challenge for domain validation instead of the traditional HTTP-01 challenge (which uses the `.well-known` folder). This means:

1. You must have your domain registered with a supported DNS provider (see list below)
2. You need API credentials/tokens from your DNS provider
3. Lego will automatically:
   - Create required DNS records for verification
   - Wait for DNS propagation
   - Complete the Let's Encrypt challenge
   - Clean up the temporary DNS records
   - Issue your certificate

This method is more reliable than HTTP validation as it works even for internal/private domains and doesn't require public web server access.

## Prerequisites

- CommandBox 5.x+
- Lego binary installed and available in your system PATH
- Domain registered with a supported DNS provider
- API credentials for your DNS provider

## Installing Lego

### Windows

1. Using Scoop:
```bash
scoop install lego
```

2. Using PowerShell Script (Recommended):
   - Download and run the  [Install-Lego.ps1](https://github.com/murpg/Docs/blob/main/installLegoWindows.md#installation-script) script which:
     - Finds your CommandBox installation
     - Downloads the latest Lego binary
     - Places it alongside your Box executable
     - Adds the location to your PATH

3. Manual Installation:
   - Download the latest Windows binary from [Lego Releases](https://github.com/go-acme/lego/releases)
   - Extract the `lego.exe` to a folder (e.g., `C:\Program Files\Lego\`)
   - Add the folder to your PATH:
     - Open System Properties → Advanced → Environment Variables
     - Under System Variables, find and select "Path"
     - Click Edit → New
     - Add the folder path (e.g., `C:\Program Files\Lego\`)
     - Click OK to save

### Mac

Using Homebrew:
```bash
brew install lego
```

### Linux

1. Using package managers:
   
   For Ubuntu/Debian:
   ```bash
   sudo snap install lego
   ```

   For Arch Linux:
   ```bash
   yay -S lego
   ```

2. Manual Installation:
   ```bash
   # Download latest release
   curl -L "https://github.com/go-acme/lego/releases/download/v4.x.x/lego_v4.x.x_linux_amd64.tar.gz" -o lego.tar.gz

   # Extract
   tar xf lego.tar.gz

   # Move to system path
   sudo mv lego /usr/local/bin/

   # Verify installation
   lego --version
   ```

### Verifying Installation

After installation, verify Lego is available in your PATH:
```bash
lego --version
```

You should see output like:
```
lego version x.x.x ...
```

### Troubleshooting Installation

If you get "command not found" or "lego is not recognized", either:
1. Lego isn't installed
2. It's not in your system PATH

#### Windows Troubleshooting
```bash
# Check if lego exists in your current directory
dir lego.exe

# Check if lego exists in your PATH by seeing all locations
where lego
```

#### Mac/Linux Troubleshooting
```bash
# Check if lego exists in your PATH
which lego

# Check all folders in your PATH
echo $PATH
```

If Lego isn't found, ensure you've:
1. Completed the installation steps above
2. Added the installation directory to your PATH
3. Restarted your terminal/command prompt after PATH changes

## Installation Checklist

✓ Install Lego using your OS-specific method  
✓ Verify Lego is in your PATH using `lego --version`  
✓ Configure your DNS provider credentials  
✓ Install the CommandBox module

## Installation

Install this module by running the following command in CommandBox:

```bash
box install commandbox-cblego
```

## DNS Provider Configuration

This module requires you to have:
1. A domain registered with one of the supported DNS providers
2. API credentials for your provider
3. Proper environment variables set for authentication

You can find detailed information about required API keys, tokens, and environment variables for your specific DNS provider in the [Lego DNS provider documentation](https://go-acme.github.io/lego/dns/).

### Environment Variables Examples

Here are examples for common DNS providers:

#### Cloudflare
```bash
# Using Token Authentication (Recommended)
export CLOUDFLARE_DNS_API_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
export CLOUDFLARE_ZONE_API_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# Or using a single token with both permissions
export CLOUDFLARE_DNS_API_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Using Email+Key Authentication (Legacy)
export CLOUDFLARE_EMAIL=you@example.com
export CLOUDFLARE_API_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Optional: Specify Zone Name (useful for troubleshooting)
export CLOUDFLARE_ZONE_NAME=yourdomain.com

# Optional: Set propagation timeout (in seconds)
export CLOUDFLARE_PROPAGATION_TIMEOUT=300
```

#### easyDNS
```bash
# Using direct values
export EASYDNS_TOKEN=XXXXXXXXXXXXXXXX
export EASYDNS_KEY=XXXXXXXXXXXXXXXX

# Or using files
export EASYDNS_TOKEN_FILE=/path/to/token/file
export EASYDNS_KEY_FILE=/path/to/key/file
```

### Certificate Examples

#### Basic Certificate
```bash
cblego --accept-tos \
       --email you@example.com \
       --dns easydns \
       -d example.com \
       run
```

#### Wildcard Certificate
```bash
EASYDNS_TOKEN=XXXXXXXXXXXXXXXX \
EASYDNS_KEY=XXXXXXXXXXXXXXXX \
cblego --accept-tos \
       --email you@example.com \
       --dns easydns \
       -d '*.example.com' \
       run
```

Note: 
- The wildcard syntax MUST use single quotes: '*.example.com'
- A wildcard certificate (*.example.com) only covers first-level subdomains (like sub.example.com)
- Wildcards do NOT cover the root domain (example.com) or deeper subdomain levels (sub.sub.example.com)
- If you need both root and subdomains, use: -d 'example.com' -d '*.example.com'
- DNS validation is required for wildcard certificates

### Advanced Certificate Examples

#### Development Environment with Debug Logging
```bash
cblego --accept-tos \
       --server https://acme-staging-v02.api.letsencrypt.org/directory \
       --email you@example.com \
       --dns easydns \
       --domains dev.example.com \
       --path ./dev-certs \
       run
```

#### Using Custom DNS Resolvers

If you're experiencing DNS propagation issues, you can specify custom DNS resolvers:

```bash
cblego --accept-tos \
       --email you@example.com \
       --dns cloudflare \
       --dns.resolvers="1.1.1.1:53" \
       -d example.com \
       run
```

For EasyDNS specifically, you might want to use their own nameservers:

```bash
cblego --accept-tos \
       --email you@example.com \
       --dns easydns \
       --dns.resolvers="dns1.easydns.com:53,dns2.easydns.com:53" \
       -d example.com \
       run
```

This is particularly helpful when:
- Your DNS provider has propagation delays
- You're in a "hidden master" DNS setup
- You're behind a corporate firewall that affects DNS resolution
- Let's Encrypt can't resolve your domain properly
- You have multi-part TLDs (like .co.uk domains) with EasyDNS

### API Authentication Troubleshooting

If you encounter authentication issues, follow these steps:

1. Verify Environment Variables
```bash
# For easyDNS
echo $EASYDNS_TOKEN
echo $EASYDNS_KEY

# For Cloudflare
echo $CLOUDFLARE_DNS_API_TOKEN
echo $CLOUDFLARE_EMAIL
```

2. Common Issues and Solutions:

#### "Invalid Credentials" Error
- Double-check your API tokens/keys for typos
- Ensure you're using the correct credential type (some providers have multiple API key types)
- Verify the credentials have sufficient permissions for DNS management

#### "Access Denied" Error
- Check if your account has DNS zone management permissions
- Verify the domain is properly set up in your DNS provider
- Ensure your API tokens have access to the specific domain

#### "Token Expired" Error
- Generate new API credentials
- Check if your provider requires token renewal
- Verify your account is in good standing

#### "Rate Limit Exceeded"
- Use the staging environment for testing
- Implement a delay between requests
- Check if your provider has rate limit tiers

#### "Invalid request headers" or "Failed to find zone" (Cloudflare)
- Ensure the domain/zone is properly added to your Cloudflare account
- Create a new API token with explicit Zone:Read and DNS:Edit permissions
- Try adding `CLOUDFLARE_ZONE_NAME=yourdomain.com` to your environment
- Verify that your API token has access to the specific zone

3. Provider-Specific Validation

For easyDNS:
```bash
# Test API access
curl -H "Authorization: Basic $(echo -n "XXXXXXXXXXXXXXXX:XXXXXXXXXXXXXXXX" | base64)" \
     https://rest.easydns.net/domain/list

# Test with custom resolvers
EASYDNS_TOKEN=XXXXXXXXXXXXXXXX \
EASYDNS_KEY=XXXXXXXXXXXXXXXX \
cblego --accept-tos \
       --email you@example.com \
       --dns easydns \
       --dns.resolvers="dns1.easydns.com:53,dns2.easydns.com:53" \
       -d example.com \
       run
```

If you have domains with multi-part TLDs (like .co.uk domains), using EasyDNS's own nameservers as resolvers can help avoid permission errors.

For Cloudflare:
```bash
# Test API token validity
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" \
     -H "Content-Type:application/json"

# Test zone access
curl -X GET "https://api.cloudflare.com/client/v4/zones?name=yourdomain.com" \
     -H "Authorization: Bearer XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" \
     -H "Content-Type:application/json"
```

4. Debug Mode
If you're still having issues, run with debug output:
```bash
LEGO_DEBUG=1 cblego --accept-tos \
                    --email you@example.com \
                    --dns easydns \
                    --domains example.com \
                    run
```

5. Common Resolution Steps:
- Clear any existing environment variables and reset them
- Generate new API credentials from your provider's dashboard
- Verify DNS propagation tools can see your domain
- Check provider's API status page for service issues
- Ensure your system time is accurately synchronized
- Verify your account has no outstanding billing issues

### Supported DNS Providers

The module supports over 80 DNS providers that Lego supports, including:

- Amazon Route 53
- Cloudflare
- DigitalOcean
- Google Cloud DNS
- Azure DNS
- [And many more...](https://go-acme.github.io/lego/dns/)

Check if your DNS provider is supported by visiting the [Lego DNS provider documentation](https://go-acme.github.io/lego/dns/)

## Certificate Files

After successful certificate generation, you'll find the following files in your `.lego` directory:

- `certificates/domain.com.crt` - Server certificate (including CA certificate)
- `certificates/domain.com.key` - Private key
- `certificates/domain.com.issuer.crt` - CA certificate
- `certificates/domain.com.json` - Certificate metadata

## Install CommandBox Lego

Install this module by running the following command in CommandBox:

```bash
box install commandbox-cblego
```

For cloudflare

```bash
cblego run envfile=cloudflare.env staging=staging|prod path=Optinal|Path To Store Lego certificate
```

Example cloudflare.env file:
```
# Cloudflare API Configuration
CLOUDFLARE_DNS_API_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
CLOUDFLARE_EMAIL=your_email@example.com
CLOUDFLARE_ZONE_NAME=yourdomain.com
CLOUDFLARE_PROPAGATION_TIMEOUT=300
DNS_PROVIDER=cloudflare

# For wildcard certificates, use the wildcard domain
# A wildcard covers only first-level subdomains (e.g., *.example.com covers sub.example.com but NOT sub.sub.example.com)
# Note: Wildcards do NOT cover the root domain (example.com)
DOMAINS=*.yourdomain.com

# If you need both root domain and subdomains:
# DOMAINS=yourdomain.com,*.yourdomain.com

# For specific domains without wildcards, list each required domain
# DOMAINS=yourdomain.com,www.yourdomain.com,api.yourdomain.com

LEGO_EMAIL=your_email@example.com
```

For easydns

```bash
cblego run envfile=easydns.env staging=staging|prod path=Optinal|Path To Store Lego certificate
```

Example easydns.env file:
```
# EasyDNS API Configuration
EASYDNS_TOKEN=XXXXXXXXXXXXXXXX
EASYDNS_KEY=XXXXXXXXXXXXXXXX
# Optional: Increase propagation timeout for multi-part TLDs
EASYDNS_PROPAGATION_TIMEOUT=300
# Optional: Use EasyDNS endpoint (sandbox for testing)
EASYDNS_ENDPOINT=https://sandbox.rest.easydns.net
DNS_PROVIDER=easydns

# For wildcard certificates, use the wildcard domain
# A wildcard covers only first-level subdomains (e.g., *.example.com covers sub.example.com but NOT sub.sub.example.com)
# Note: Wildcards do NOT cover the root domain (example.com)
DOMAINS=*.yourdomain.com

# If you need both root domain and subdomains:
# DOMAINS=yourdomain.com,*.yourdomain.com

# For specific domains without wildcards, list each required domain
# DOMAINS=yourdomain.com,www.yourdomain.com,admin.yourdomain.com

LEGO_EMAIL=your_email@example.com
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
