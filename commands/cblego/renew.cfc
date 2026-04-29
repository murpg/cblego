component {

    /**
     * Runs the LEGO renewal command with specified parameters.
     *
     * Supports both DNS-01 and HTTP-01 challenge types. The challenge type is
     * determined by the CHALLENGE_TYPE variable in the env file (defaults to "dns").
     *
     * @envFile  The environment file to load.
     * @server   CA hostname (default: "staging").
     * @path     Directory to use for storing the data. (default: "./.lego").
     */
    function run(required string envFile, string server = "staging", string path = "") {
        // Load environment variables from the .env file via commandbox-dotenv
        command("dotenv load #envFile#").run();

        print.line("Starting automated certificate renewal check...");

        // Pull required values explicitly out of systemSettings.
        var legoEmail   = trim(systemSettings.getSystemSetting("LEGO_EMAIL", ""));
        var domains     = trim(systemSettings.getSystemSetting("DOMAINS", ""));
        var renewalDays = trim(systemSettings.getSystemSetting("RENEWAL_DAYS_BEFORE_EXPIRY", "30"));

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

        print.line("Renewing using challenge type: " & ucase(challengeType) & "-01");

        // Build the lego command using CFML interpolation (#var#)
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

            var httpPort = trim(systemSettings.getSystemSetting("HTTP_PORT", ""));
            if (len(httpPort) > 0) {
                legoCmd &= " --http.port=#httpPort#";
            }

            var httpWebroot = trim(systemSettings.getSystemSetting("HTTP_WEBROOT", ""));
            if (len(httpWebroot) > 0) {
                legoCmd &= " --http.webroot=""#httpWebroot#""";
            }

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

        // Finalize the command with renew + days threshold
        legoCmd &= " renew --days #renewalDays#";

        print.redLine("Executing command: " & legoCmd);
        try {
            command(legoCmd).run();
            variables.print.greenLine("Renewal check completed successfully");
        } catch (any e) {
            return error("Error executing command: " & e.message);
        }
    }
}
