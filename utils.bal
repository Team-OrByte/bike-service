import bike_service.auth;
import bike_service.common;

public function extractClaims(string authHeader) returns Claims|error {
    common:Claims commonClaims = check auth:extractClaims(authHeader);
    
    // Convert to legacy Claims type for backward compatibility
    Claims legacyClaims = {
        userId: commonClaims.userId,
        email: commonClaims.email,
        role: commonClaims.role
    };
    
    return legacyClaims;
}