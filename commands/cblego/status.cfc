component {

    property name="certificateManager" inject="CertificateManager@commandbox-cblego";

    /**
     * Runs the LEGO command with specified parameters.
     *
     * @envFile  The environment file to load.
     */
    function run(required string envFile) {
        // Load environment variables
        command("dotenv load #envFile#").run();

        var domain  = listFirst(systemSettings.getSystemSetting( 'DOMAINS' ));

        var result = certificateManager.loadCertificateFromURL(domain);

        if(result.success){
            if(ParseDateTime(result.NOTAFTER) GTE Now()){
                variables.print.greenLine("Certificate Status: Active");
            }else{
                return error("Certificate Status: InActive");
            }
        }else{
            return error("Certificate Status: Not Valid");
        }
        
    }    
}