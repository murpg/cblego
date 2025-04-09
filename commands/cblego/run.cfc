component {

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
        } catch (any e) {
            return error("Error executing command: " & e.message);
        }
    }
}
