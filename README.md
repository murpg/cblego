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

## DNS Providers List

This is a list of DNS providers supported by the [lego ACME client](https://go-acme.github.io/lego/dns/){:target="_blank"}. Each provider link will open in a new tab.

| Provider | Website |
| --- | --- |
| Active24 | [active24](https://go-acme.github.io/lego/dns/active24/) |
| Akamai EdgeDNS | [edgedns](https://go-acme.github.io/lego/dns/edgedns/) |
| Alibaba Cloud DNS | [alidns](https://go-acme.github.io/lego/dns/alidns/) |
| all-inkl | [allinkl](https://go-acme.github.io/lego/dns/allinkl/) |
| Amazon Lightsail | [lightsail](https://go-acme.github.io/lego/dns/lightsail/) |
| Amazon Route 53 | [route53](https://go-acme.github.io/lego/dns/route53/) |
| ArvanCloud | [arvancloud](https://go-acme.github.io/lego/dns/arvancloud/) |
| Aurora DNS | [auroradns](https://go-acme.github.io/lego/dns/auroradns/) |
| Autodns | [autodns](https://go-acme.github.io/lego/dns/autodns/) |
| Axelname | [axelname](https://go-acme.github.io/lego/dns/axelname/) |
| Azure (deprecated) | [azure](https://go-acme.github.io/lego/dns/azure/) |
| Azure DNS | [azuredns](https://go-acme.github.io/lego/dns/azuredns/) |
| Baidu Cloud | [baiducloud](https://go-acme.github.io/lego/dns/baiducloud/) |
| Bindman | [bindman](https://go-acme.github.io/lego/dns/bindman/) |
| Bluecat | [bluecat](https://go-acme.github.io/lego/dns/bluecat/) |
| BookMyName | [bookmyname](https://go-acme.github.io/lego/dns/bookmyname/) |
| Brandit (deprecated) | [brandit](https://go-acme.github.io/lego/dns/brandit/) |
| Bunny | [bunny](https://go-acme.github.io/lego/dns/bunny/) |
| Checkdomain | [checkdomain](https://go-acme.github.io/lego/dns/checkdomain/) |
| Civo | [civo](https://go-acme.github.io/lego/dns/civo/) |
| Cloud.ru | [cloudru](https://go-acme.github.io/lego/dns/cloudru/) |
| CloudDNS | [clouddns](https://go-acme.github.io/lego/dns/clouddns/) |
| Cloudflare | [cloudflare](https://go-acme.github.io/lego/dns/cloudflare/) |
| ClouDNS | [cloudns](https://go-acme.github.io/lego/dns/cloudns/) |
| CloudXNS (Deprecated) | [cloudxns](https://go-acme.github.io/lego/dns/cloudxns/) |
| ConoHa | [conoha](https://go-acme.github.io/lego/dns/conoha/) |
| Constellix | [constellix](https://go-acme.github.io/lego/dns/constellix/) |
| Core-Networks | [corenetworks](https://go-acme.github.io/lego/dns/corenetworks/) |
| CPanel/WHM | [cpanel](https://go-acme.github.io/lego/dns/cpanel/) |
| Derak Cloud | [derak](https://go-acme.github.io/lego/dns/derak/) |
| deSEC.io | [desec](https://go-acme.github.io/lego/dns/desec/) |
| Designate DNSaaS for Openstack | [designate](https://go-acme.github.io/lego/dns/designate/) |
| Digital Ocean | [digitalocean](https://go-acme.github.io/lego/dns/digitalocean/) |
| DirectAdmin | [directadmin](https://go-acme.github.io/lego/dns/directadmin/) |
| DNS Made Easy | [dnsmadeeasy](https://go-acme.github.io/lego/dns/dnsmadeeasy/) |
| dnsHome.de | [dnshomede](https://go-acme.github.io/lego/dns/dnshomede/) |
| DNSimple | [dnsimple](https://go-acme.github.io/lego/dns/dnsimple/) |
| DNSPod (deprecated) | [dnspod](https://go-acme.github.io/lego/dns/dnspod/) |
| Domain Offensive (do.de) | [dode](https://go-acme.github.io/lego/dns/dode/) |
| Domeneshop | [domeneshop](https://go-acme.github.io/lego/dns/domeneshop/) |
| DreamHost | [dreamhost](https://go-acme.github.io/lego/dns/dreamhost/) |
| Duck DNS | [duckdns](https://go-acme.github.io/lego/dns/duckdns/) |
| Dyn | [dyn](https://go-acme.github.io/lego/dns/dyn/) |
| Dynu | [dynu](https://go-acme.github.io/lego/dns/dynu/) |
| EasyDNS | [easydns](https://go-acme.github.io/lego/dns/easydns/) |
| Efficient IP | [efficientip](https://go-acme.github.io/lego/dns/efficientip/) |
| Epik | [epik](https://go-acme.github.io/lego/dns/epik/) |
| Exoscale | [exoscale](https://go-acme.github.io/lego/dns/exoscale/) |
| External program | [exec](https://go-acme.github.io/lego/dns/exec/) |
| F5 XC | [f5xc](https://go-acme.github.io/lego/dns/f5xc/) |
| freemyip.com | [freemyip](https://go-acme.github.io/lego/dns/freemyip/) |
| G-Core | [gcore](https://go-acme.github.io/lego/dns/gcore/) |
| Gandi | [gandi](https://go-acme.github.io/lego/dns/gandi/) |
| Gandi Live DNS (v5) | [gandiv5](https://go-acme.github.io/lego/dns/gandiv5/) |
| Glesys | [glesys](https://go-acme.github.io/lego/dns/glesys/) |
| Go Daddy | [godaddy](https://go-acme.github.io/lego/dns/godaddy/) |
| Google Cloud | [gcloud](https://go-acme.github.io/lego/dns/gcloud/) |
| Google Domains | [googledomains](https://go-acme.github.io/lego/dns/googledomains/) |
| Hetzner | [hetzner](https://go-acme.github.io/lego/dns/hetzner/) |
| Hosting.de | [hostingde](https://go-acme.github.io/lego/dns/hostingde/) |
| Hosttech | [hosttech](https://go-acme.github.io/lego/dns/hosttech/) |
| HTTP request | [httpreq](https://go-acme.github.io/lego/dns/httpreq/) |
| http.net | [httpnet](https://go-acme.github.io/lego/dns/httpnet/) |
| Huawei Cloud | [huaweicloud](https://go-acme.github.io/lego/dns/huaweicloud/) |
| Hurricane Electric DNS | [hurricane](https://go-acme.github.io/lego/dns/hurricane/) |
| HyperOne | [hyperone](https://go-acme.github.io/lego/dns/hyperone/) |
| IBM Cloud (SoftLayer) | [ibmcloud](https://go-acme.github.io/lego/dns/ibmcloud/) |
| IIJ DNS Platform Service | [iijdpf](https://go-acme.github.io/lego/dns/iijdpf/) |
| Infoblox | [infoblox](https://go-acme.github.io/lego/dns/infoblox/) |
| Infomaniak | [infomaniak](https://go-acme.github.io/lego/dns/infomaniak/) |
| Internet Initiative Japan | [iij](https://go-acme.github.io/lego/dns/iij/) |
| Internet.bs | [internetbs](https://go-acme.github.io/lego/dns/internetbs/) |
| INWX | [inwx](https://go-acme.github.io/lego/dns/inwx/) |
| Ionos | [ionos](https://go-acme.github.io/lego/dns/ionos/) |
| IPv64 | [ipv64](https://go-acme.github.io/lego/dns/ipv64/) |
| iwantmyname | [iwantmyname](https://go-acme.github.io/lego/dns/iwantmyname/) |
| Joker | [joker](https://go-acme.github.io/lego/dns/joker/) |
| Joohoi's ACME-DNS | [acme-dns](https://go-acme.github.io/lego/dns/acme-dns/) |
| Liara | [liara](https://go-acme.github.io/lego/dns/liara/) |
| Lima-City | [limacity](https://go-acme.github.io/lego/dns/limacity/) |
| Linode (v4) | [linode](https://go-acme.github.io/lego/dns/linode/) |
| Liquid Web | [liquidweb](https://go-acme.github.io/lego/dns/liquidweb/) |
| Loopia | [loopia](https://go-acme.github.io/lego/dns/loopia/) |
| LuaDNS | [luadns](https://go-acme.github.io/lego/dns/luadns/) |
| Mail-in-a-Box | [mailinabox](https://go-acme.github.io/lego/dns/mailinabox/) |
| ManageEngine CloudDNS | [manageengine](https://go-acme.github.io/lego/dns/manageengine/) |
| Manual | [manual](https://go-acme.github.io/lego/dns/manual/) |
| Metaname | [metaname](https://go-acme.github.io/lego/dns/metaname/) |
| Metaregistrar | [metaregistrar](https://go-acme.github.io/lego/dns/metaregistrar/) |
| mijn.host | [mijnhost](https://go-acme.github.io/lego/dns/mijnhost/) |
| Mittwald | [mittwald](https://go-acme.github.io/lego/dns/mittwald/) |
| myaddr.{tools,dev,io} | [myaddr](https://go-acme.github.io/lego/dns/myaddr/) |
| MyDNS.jp | [mydnsjp](https://go-acme.github.io/lego/dns/mydnsjp/) |
| MythicBeasts | [mythicbeasts](https://go-acme.github.io/lego/dns/mythicbeasts/) |
| Name.com | [namedotcom](https://go-acme.github.io/lego/dns/namedotcom/) |
| Namecheap | [namecheap](https://go-acme.github.io/lego/dns/namecheap/) |
| Namesilo | [namesilo](https://go-acme.github.io/lego/dns/namesilo/) |
| NearlyFreeSpeech.NET | [nearlyfreespeech](https://go-acme.github.io/lego/dns/nearlyfreespeech/) |
| Netcup | [netcup](https://go-acme.github.io/lego/dns/netcup/) |
| Netlify | [netlify](https://go-acme.github.io/lego/dns/netlify/) |
| Nicmanager | [nicmanager](https://go-acme.github.io/lego/dns/nicmanager/) |
| NIFCloud | [nifcloud](https://go-acme.github.io/lego/dns/nifcloud/) |
| Njalla | [njalla](https://go-acme.github.io/lego/dns/njalla/) |
| Nodion | [nodion](https://go-acme.github.io/lego/dns/nodion/) |
| NS1 | [ns1](https://go-acme.github.io/lego/dns/ns1/) |
| Open Telekom Cloud | [otc](https://go-acme.github.io/lego/dns/otc/) |
| Oracle Cloud | [oraclecloud](https://go-acme.github.io/lego/dns/oraclecloud/) |
| OVH | [ovh](https://go-acme.github.io/lego/dns/ovh/) |
| plesk.com | [plesk](https://go-acme.github.io/lego/dns/plesk/) |
| Porkbun | [porkbun](https://go-acme.github.io/lego/dns/porkbun/) |
| PowerDNS | [pdns](https://go-acme.github.io/lego/dns/pdns/) |
| Rackspace | [rackspace](https://go-acme.github.io/lego/dns/rackspace/) |
| Rain Yun/雨云 | [rainyun](https://go-acme.github.io/lego/dns/rainyun/) |
| RcodeZero | [rcodezero](https://go-acme.github.io/lego/dns/rcodezero/) |
| reg.ru | [regru](https://go-acme.github.io/lego/dns/regru/) |
| Regfish | [regfish](https://go-acme.github.io/lego/dns/regfish/) |
| RFC2136 | [rfc2136](https://go-acme.github.io/lego/dns/rfc2136/) |
| RimuHosting | [rimuhosting](https://go-acme.github.io/lego/dns/rimuhosting/) |
| Sakura Cloud | [sakuracloud](https://go-acme.github.io/lego/dns/sakuracloud/) |
| Scaleway | [scaleway](https://go-acme.github.io/lego/dns/scaleway/) |
| Selectel | [selectel](https://go-acme.github.io/lego/dns/selectel/) |
| Selectel v2 | [selectelv2](https://go-acme.github.io/lego/dns/selectelv2/) |
| SelfHost.(de\|eu) | [selfhostde](https://go-acme.github.io/lego/dns/selfhostde/) |
| Servercow | [servercow](https://go-acme.github.io/lego/dns/servercow/) |
| Shellrent | [shellrent](https://go-acme.github.io/lego/dns/shellrent/) |
| Simply.com | [simply](https://go-acme.github.io/lego/dns/simply/) |
| Sonic | [sonic](https://go-acme.github.io/lego/dns/sonic/) |
| Spaceship | [spaceship](https://go-acme.github.io/lego/dns/spaceship/) |
| Stackpath | [stackpath](https://go-acme.github.io/lego/dns/stackpath/) |
| Technitium | [technitium](https://go-acme.github.io/lego/dns/technitium/) |
| Tencent Cloud DNS | [tencentcloud](https://go-acme.github.io/lego/dns/tencentcloud/) |
| Timeweb Cloud | [timewebcloud](https://go-acme.github.io/lego/dns/timewebcloud/) |
| TransIP | [transip](https://go-acme.github.io/lego/dns/transip/) |
| UKFast SafeDNS | [safedns](https://go-acme.github.io/lego/dns/safedns/) |
| Ultradns | [ultradns](https://go-acme.github.io/lego/dns/ultradns/) |
| Variomedia | [variomedia](https://go-acme.github.io/lego/dns/variomedia/) |
| VegaDNS | [vegadns](https://go-acme.github.io/lego/dns/vegadns/) |
| Vercel | [vercel](https://go-acme.github.io/lego/dns/vercel/) |
| Versio.[nl\|eu\|uk] | [versio](https://go-acme.github.io/lego/dns/versio/) |
| VinylDNS | [vinyldns](https://go-acme.github.io/lego/dns/vinyldns/) |
| VK Cloud | [vkcloud](https://go-acme.github.io/lego/dns/vkcloud/) |
| Volcano Engine/火山引擎 | [volcengine](https://go-acme.github.io/lego/dns/volcengine/) |
| Vscale | [vscale](https://go-acme.github.io/lego/dns/vscale/) |
| Vultr | [vultr](https://go-acme.github.io/lego/dns/vultr/) |
| Webnames | [webnames](https://go-acme.github.io/lego/dns/webnames/) |
| Websupport | [websupport](https://go-acme.github.io/lego/dns/websupport/) |
| WEDOS | [wedos](https://go-acme.github.io/lego/dns/wedos/) |
| West.cn/西部数码 | [westcn](https://go-acme.github.io/lego/dns/westcn/) |
| Yandex 360 | [yandex360](https://go-acme.github.io/lego/dns/yandex360/) |
| Yandex Cloud | [yandexcloud](https://go-acme.github.io/lego/dns/yandexcloud/) |
| Yandex PDD | [yandex](https://go-acme.github.io/lego/dns/yandex/) |
| Zone.ee | [zoneee](https://go-acme.github.io/lego/dns/zoneee/) |
| Zonomi | [zonomi](https://go-acme.github.io/lego/dns/zonomi/) |

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
