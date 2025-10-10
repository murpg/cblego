component singleton {

     function getCertificateInfo(string certPath) {

        var loc = {};
        loc.finalOutput = structNew();
        loc.jsonOutput = structNew();
        loc.finalOutput.path = arguments.certPath;

        //arguments.certPath = "E:\project\gerorge\kishore\.lego\certificates\main.devmilnet.com.crt"; // !!! IMPORTANT: Update this path !!!

        loc.externalMetadata = {
            "dnsProvider": "cloudflare",
            "envFile": "cloudflare.env",
            "lastRenewal": "2025-01-15T10:30:00Z",
            "renewalCount": 0
        };

        try {

            loc.certFactory = CreateObject("java", "java.security.cert.CertificateFactory").getInstance("X.509");
            loc.fis = CreateObject("java", "java.io.FileInputStream").init(arguments.certPath);
            loc.x509Cert = loc.certFactory.generateCertificate(loc.fis);
            loc.x509Cert = javaCast("java.security.cert.X509Certificate", loc.x509Cert);

            loc.sdf = CreateObject("java", "java.text.SimpleDateFormat").init("yyyy-MM-dd'T'HH:mm:ss'Z'");
            loc.sdf.setTimeZone(CreateObject("java", "java.util.TimeZone").getTimeZone("UTC"));

            loc.finalOutput.issueDate = loc.sdf.format(loc.x509Cert.getNotBefore());
            loc.finalOutput.expiryDate = loc.sdf.format(loc.x509Cert.getNotAfter());

            loc.domainsList = [];

            // --- Improved Subject Alternative Names (SANs) extraction ---
            loc.sanNamesCollection = loc.x509Cert.getSubjectAlternativeNames();

            
            if (!isNull(loc.sanNamesCollection)) {
                // ColdFusion can sometimes directly convert Java Collections to CF Arrays
                // However, iterating with the Java Iterator is generally safer for complex types.
                loc.sanIterator = loc.sanNamesCollection.iterator();
                while (loc.sanIterator.hasNext()) {
                    loc.sanEntry = loc.sanIterator.next(); // This is a Java List, e.g., [2, "example.com"]

                    // Check if sanEntry is actually a List and has at least two elements
                    if (isInstanceOf(loc.sanEntry, "java.util.List") && loc.sanEntry.size() >= 2) {
                        loc.nameType = loc.sanEntry.get(0); // This is an Integer object
                        loc.nameValue = loc.sanEntry.get(1); // This can be String or byte[]

                        // Ensure nameType is an Integer and its value is 2 (for DNS Name)
                        if (isInstanceOf(loc.nameType, "java.lang.Integer") && loc.nameType.intValue() == 2) {
                            // Ensure nameValue is a String before adding
                            if (isInstanceOf(loc.nameValue, "java.lang.String")) {
                                arrayAppend(loc.domainsList, loc.nameValue.toString());
                            }
                        }
                    }
                }
            }
        

            // Add the Common Name (CN) from the Subject DN if it's not already in SANs
            loc.subjectDN = loc.x509Cert.getSubjectX500Principal().getName();
        
            loc.cnMatch = reMatch("CN=([^,]+)", loc.subjectDN);

            if (arrayLen(loc.cnMatch) >= 2) {
                loc.commonName = loc.cnMatch[2]; // The captured group for CN
                if (!arrayContains(loc.domainsList, loc.commonName)) {
                    arrayAppend(loc.domainsList, loc.commonName);
                }
            }


            loc.finalOutput.domains = loc.domainsList;

            loc.fis.close();

            structAppend(loc.finalOutput, loc.externalMetadata, true);

            loc.jsonOutput = loc.finalOutput;

        } catch (any e) {
            loc.jsonOutput = { success: false, error: e};
        }

        return loc.jsonOutput;
    }

        
    // Function to load certificate from file
    function loadCertificateFromFile(certPath) {
        try {
            // Create Java objects
            var fileInputStream = createObject("java", "java.io.FileInputStream").init(certPath);
            var certificateFactory = createObject("java", "java.security.cert.CertificateFactory").getInstance("X.509");
            
            // Load certificate
            var certificate = certificateFactory.generateCertificate(fileInputStream);
            fileInputStream.close();
            
            return certificate;
        } catch (any e) {
            throw("Error loading certificate: " & e.message);
        }
    }

    // Function to load certificate from URL/domain
    function loadCertificateFromURL(domain, port = 443) {
        try {
            // Load necessary Java classes
            var SSLSocketFactory = createObject("java", "javax.net.ssl.SSLSocketFactory");
            var SSLSession = createObject("java", "javax.net.ssl.SSLSession");
            var X509Certificate = createObject("java", "java.security.cert.X509Certificate");

            // Create SSL Socket Connection
            var factory = SSLSocketFactory.getDefault();
            var socket = factory.createSocket(domain, javacast("int", port));
            socket.startHandshake();

            // Get SSL Session and Certificates
            var los = socket.getSession();
            var certificates = los.getPeerCertificates();

            // Return the first certificate (end-entity certificate)
            var cert = certificates[1];  // certificates[0] is the root sometimes, 1 is end-entity.
            
            // Optionally, get Certificate details:
            var certDetails = {
                success: true,
                subjectDN: cert.getSubjectDN().getName(),
                issuerDN: cert.getIssuerDN().getName(),
                serialNumber: cert.getSerialNumber().toString(),
                notBefore: cert.getNotBefore(),
                notAfter: cert.getNotAfter(),
                signatureAlgorithm: cert.getSigAlgName()
            };

            return certDetails;

        } catch (any e) {
           var certDetails = { success: false};
        }

        return certDetails;

    }

    // Function to check basic validity (expiration dates)
    function checkCertificateValidity(certificate) {
        var result = {
            isValid: false,
            notBefore: "",
            notAfter: "",
            daysUntilExpiry: 0,
            error: ""
        };
        
        try {
            // Check validity
            certificate.checkValidity();
            result.isValid = true;
            
            // Get dates
            result.notBefore = certificate.getNotBefore();
            result.notAfter = certificate.getNotAfter();
            
            // Calculate days until expiry
            var now = createObject("java", "java.util.Date").init();
            var expiryTime = certificate.getNotAfter().getTime();
            var currentTime = now.getTime();
            result.daysUntilExpiry = int((expiryTime - currentTime) / (1000 * 60 * 60 * 24));
            
        } catch (java.security.cert.CertificateExpiredException e) {
            result.error = "Certificate is expired";
        } catch (java.security.cert.CertificateNotYetValidException e) {
            result.error = "Certificate is not yet valid";
        } catch (any e) {
            result.error = "Validation error: " & e.message;
        }
        
        return result;
    }

    // Function to extract certificate details
    function getCertificateDetails(certificate) {
        var details = {};
        
        try {
            details.subject = certificate.getSubjectDN().toString();
            details.issuer = certificate.getIssuerDN().toString();
            details.serialNumber = certificate.getSerialNumber().toString();
            details.version = certificate.getVersion();
            details.signatureAlgorithm = certificate.getSigAlgName();
            
            // Get Subject Alternative Names if available
            try {
                var sans = certificate.getSubjectAlternativeNames();
                details.subjectAltNames = [];
                if (sans != null) {
                    var iterator = sans.iterator();
                    while (iterator.hasNext()) {
                        var san = iterator.next();
                        arrayAppend(details.subjectAltNames, san.get(1));
                    }
                }
            } catch (any e) {
                details.subjectAltNames = [];
            }
            
            // Check if self-signed
            details.isSelfSigned = (details.subject == details.issuer);
            
        } catch (any e) {
            details.error = "Error extracting details: " & e.message;
        }
        
        return details;
    }

    // Function to verify certificate signature
    function verifyCertificateSignature(certificate, issuerCertificate = null) {
        try {
            if (issuerCertificate == null) {
                // Self-signed verification
                certificate.verify(certificate.getPublicKey());
            } else {
                // Verify against issuer
                certificate.verify(issuerCertificate.getPublicKey());
            }
            return true;
        } catch (any e) {
            return false;
        }
    }

    // Function to get system trust store
    function getSystemTrustStore() {
        try {
            var keyStore = createObject("java", "java.security.KeyStore").getInstance("JKS");
            var javaHome = createObject("java", "java.lang.System").getProperty("java.home");
            var trustStorePath = javaHome & "/lib/security/cacerts";
            
            var fileInputStream = createObject("java", "java.io.FileInputStream").init(trustStorePath);
            keyStore.load(fileInputStream, "changeit".toCharArray());
            fileInputStream.close();
            
            return keyStore;
        } catch (any e) {
            throw("Error loading system trust store: " & e.message);
        }
    }

    // Comprehensive certificate validation function
    function validateCertificate(certificateSource, sourceType = "file") {
        var result = {
            isValid: false,
            details: {},
            validity: {},
            signatureValid: false,
            trustedBySystem: false,
            error: ""
        };
        
        try {
            // Load certificate based on source type
            var certificate = null;
            if (sourceType == "file") {
                certificate = loadCertificateFromFile(certificateSource);
            } else if (sourceType == "url") {
                var parts = listToArray(certificateSource, ":");
                var domain = parts[1];
                var port = (arrayLen(parts) > 1) ? parts[2] : 443;
                certificate = loadCertificateFromURL(domain, port);
            }
            
            if (certificate == null) {
                result.error = "Could not load certificate";
                return result;
            }
            
            // Get certificate details
            result.details = getCertificateDetails(certificate);
            
            // Check validity dates
            result.validity = checkCertificateValidity(certificate);
            
            // Verify signature (self-signed check)
            if (result.details.isSelfSigned) {
                result.signatureValid = verifyCertificateSignature(certificate);
            }
            
            // Check against system trust store (simplified check)
            try {
                var trustStore = getSystemTrustStore();
                var aliases = trustStore.aliases();
                result.trustedBySystem = false;
                
                while (aliases.hasMoreElements()) {
                    var alias = aliases.nextElement();
                    if (trustStore.isCertificateEntry(alias)) {
                        var trustedCert = trustStore.getCertificate(alias);
                        if (certificate.equals(trustedCert)) {
                            result.trustedBySystem = true;
                            break;
                        }
                    }
                }
            } catch (any e) {
                result.trustedBySystem = false;
            }
            
            // Overall validity
            result.isValid = result.validity.isValid && 
                            (result.signatureValid || result.trustedBySystem);
            
        } catch (any e) {
            result.error = "Validation failed: " & e.message;
        }
        
        return result;
    }
}