component {

    property name="certificateManager" inject="CertificateManager@commandbox-cblego";
    property name="fileSystemUtil"     inject="FileSystem";

    /**
     * Runs the LEGO command with specified parameters.
     *
     * @envFile  The environment file to load.
     * @server   CA hostname (default: "staging").
     * @path     Directory to use for storing the data. (default: "./.lego").
     */
    function run(required string envFile, string server = "staging", string path = "") {
        // Load environment variables
        command("dotenv load #envFile#").run();
        
        // Define base Lego command
        var legoCmd = "!lego --email=%LEGO_EMAIL% --accept-tos --dns=%DNS_PROVIDER% --domains=%DOMAINS%";
        
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

            saveCertificateMetadata( arguments.envfile, arguments.path );

        } catch (any e) {
            return error("Error executing command: " & e.message);
        }
    } 

    private function saveCertificateMetadata(string envfile, string path = "") {

        var directory = variables.fileSystemUtil.resolvePath( arguments.path );

        var metadataFile = directory & "certificates.json";

        var metadata = fileExists(metadataFile) ? deserializeJSON(fileRead(metadataFile)) : {"certificates": []};

        var domain  = listFirst(systemSettings.getSystemSetting( 'DOMAINS' ));

        var certPath = directory & ".lego\certificates\#domain#.crt";

        if( fileExists(certPath) ){

            var certInfo = variables.certificateManager.getCertificateInfo(certPath);
            
            metadata.certificates.append({
                "domains": certInfo.domains,
                "issueDate": certInfo.issueDate,
                "expiryDate": certInfo.expiryDate,
                "dnsProvider": systemSettings.getSystemSetting( 'DNS_PROVIDER' ),
                "envFile": envfile,
                "path": certPath,
                "lastRenewal": now(),
                "renewalCount": 0
            });
            
            fileWrite(metadataFile, serializeJSON(metadata));

            variables.print.greenLine("Certificate generation info stored certificates.json");
        }else{
             return error("Error certPath file does not exist: " & certPath);
        }
    }
}
