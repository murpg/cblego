component {

    property name="certificateManager" inject="CertificateManager@commandbox-cblego";
    property name="fileSystemUtil"     inject="FileSystem";

    /**
     * Runs the LEGO command with specified parameters.
     *
     * Supports both DNS-01 and HTTP-01 challenge types. The challenge type is
     * determined by the CHALLENGE_TYPE variable in the env file (defaults to "dns").
     *
     * For DNS-01 challenges, set DNS_PROVIDER in your env file (e.g. cloudflare, easydns).
     * For HTTP-01 challenges, optionally set HTTP_PORT (default :80) and HTTP_WEBROOT.
     *
     * @envFile  The environment file to load.
     * @server   CA hostname (default: "staging").
     * @path     Directory to use for storing the data. (default: "./.lego").
     */
    function run(required string envFile, string server = "staging", string path = "") {
        // Load environment variables from the .env file via commandbox-dotenv
        command("dotenv load #envFile#").run();

        // Pull required values explicitly out of systemSettings.
        // We do this rather than relying on shell-style %VAR% expansion
        // inside the command string, which is unreliable across CommandBox versions.
        var legoEmail = trim(systemSettings.getSystemSetting("LEGO_EMAIL", ""));
        var domains   = trim(systemSettings.getSystemSetting("DOMAINS", ""));

        if (len(legoEmail) == 0) {
            return error("LEGO_EMAIL is not set in the env file.");
        }
        if (len(domains) == 0) {
            return error("DOMAINS is not set in the env file.");
        }

        // Determine challenge type (defaults to "dns" for backward compatibility)
        var challengeType = "dns";
        try {
            challengeType = lcase(trim(systemSettings.getSystemSetting("CHALLENGE_TYPE", "dns")));
        } catch (any e) {
            challengeType = "dns";
        }

        // Validate challenge type
        if (challengeType != "dns" && challengeType != "http") {
            return error("Invalid CHALLENGE_TYPE [" & challengeType & "]. Must be 'dns' or 'http'.");
        }

        print.line("Using challenge type: " & ucase(challengeType) & "-01");

        // Build the lego command using CFML interpolation (#var#).
        // CFML expands these BEFORE the string is passed to command().run(),
        // so lego receives real values, not placeholder tokens.
        var legoCmd = "!lego --email=#legoEmail# --accept-tos --domains=#domains#";

        // Add challenge-specific flags
        if (challengeType == "dns") {
            var dnsProvider = trim(systemSettings.getSystemSetting("DNS_PROVIDER", ""));
            if (len(dnsProvider) == 0) {
                return error("DNS_PROVIDER must be set in the env file when CHALLENGE_TYPE=dns.");
            }
            legoCmd &= " --dns=#dnsProvider#";
        } else {
            // HTTP-01 challenge
            legoCmd &= " --http";

            // Optional: HTTP port (defaults to :80 in lego)
            var httpPort = trim(systemSettings.getSystemSetting("HTTP_PORT", ""));
            if (len(httpPort) > 0) {
                legoCmd &= " --http.port=#httpPort#";
            }

            // Optional: webroot path - serve via existing web server's .well-known folder
            var httpWebroot = trim(systemSettings.getSystemSetting("HTTP_WEBROOT", ""));
            if (len(httpWebroot) > 0) {
                legoCmd &= " --http.webroot=""#httpWebroot#""";
            }

            // Optional: proxy header for reverse proxy setups
            var httpProxyHeader = trim(systemSettings.getSystemSetting("HTTP_PROXY_HEADER", ""));
            if (len(httpProxyHeader) > 0) {
                legoCmd &= " --http.proxy-header=#httpProxyHeader#";
            }
        }

        // Determine server environment
        legoCmd &= (arguments.server == "prod")
            ? " --server=https://acme-v02.api.letsencrypt.org/directory"
            : " --server=https://acme-staging-v02.api.letsencrypt.org/directory";

        // Append path if provided
        if (len(trim(arguments.path)) > 0) {
            legoCmd &= " --path=#arguments.path#";
        }

        // Finalize command
        legoCmd &= " run";

        print.redLine("Executing command: " & legoCmd);
        try {
            command(legoCmd).run();

            variables.print.greenLine("Certificate generation request completed");

            saveCertificateMetadata(arguments.envfile, arguments.path, challengeType, domains);

        } catch (any e) {
            return error("Error executing command: " & e.message);
        }
    }

    private function saveCertificateMetadata(string envfile, string path = "", string challengeType = "dns", string domains = "") {

        var directory = variables.fileSystemUtil.resolvePath(arguments.path);

        var metadataFile = directory & "certificates.json";

        var metadata = fileExists(metadataFile) ? deserializeJSON(fileRead(metadataFile)) : {"certificates": []};

        // Take the first domain from the comma-separated DOMAINS list as the cert filename root
        var domain = listFirst(arguments.domains);

        var certPath = directory & ".lego/certificates/#domain#.crt";

        if (fileExists(certPath)) {

            var certInfo = variables.certificateManager.getCertificateInfo(certPath);

            // Determine which provider/method was used based on challenge type
            var providerInfo = "";
            if (arguments.challengeType == "dns") {
                providerInfo = systemSettings.getSystemSetting('DNS_PROVIDER', '');
            } else {
                providerInfo = "http-01";
            }

            metadata.certificates.append({
                "domains": certInfo.domains,
                "issueDate": certInfo.issueDate,
                "expiryDate": certInfo.expiryDate,
                "challengeType": arguments.challengeType & "-01",
                "dnsProvider": providerInfo,
                "envFile": envfile,
                "path": certPath,
                "lastRenewal": now(),
                "renewalCount": 0
            });

            fileWrite(metadataFile, serializeJSON(metadata));

            variables.print.greenLine("Certificate generation info stored certificates.json");
        } else {
            return error("Error: certificate file does not exist at " & certPath);
        }
    }
}
