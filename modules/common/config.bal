// JWT Configuration
public type JWTConfig record {|
    string issuer;
    string audience;
    string certFile;
    string scopeKey;
|};

// CORS Configuration
public type CorsConfig record {|
    string[] allowOrigins;
    string[] allowMethods;
    string[] allowHeaders;
|};

// Default configurations
public const JWTConfig DEFAULT_JWT_CONFIG = {
    issuer: "Orbyte",
    audience: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa",
    certFile: "", // Will be set from configurable
    scopeKey: "scp"
};

public const CorsConfig DEFAULT_CORS_CONFIG = {
    allowOrigins: ["*"],
    allowMethods: ["POST", "PUT", "GET", "POST", "OPTIONS"],
    allowHeaders: ["Content-Type", "Access-Control-Allow-Origin", "X-Service-Name"]
};

// Create JWT validator configuration
public function createJWTValidatorConfig(string certFile, string scopes) returns map<anydata> {
    return {
        auth: [
            {
                jwtValidatorConfig: {
                    issuer: DEFAULT_JWT_CONFIG.issuer,
                    audience: DEFAULT_JWT_CONFIG.audience,
                    signatureConfig: {
                        certFile: certFile
                    },
                    scopeKey: DEFAULT_JWT_CONFIG.scopeKey
                },
                scopes: scopes
            }
        ]
    };
}
