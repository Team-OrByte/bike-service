import ballerina/jwt;
import bike_service.common;

public function extractClaims(string authHeader) returns common:Claims|error {
    int? index = authHeader.indexOf("Bearer ");
    if index is () {
        return error("Invalid Authorization header format");
    }

    string jwtString = authHeader.substring(index + 7);
    
    var decoded = jwt:decode(jwtString);
    if decoded is [jwt:Header, jwt:Payload] {
        jwt:Payload payload = decoded[1];
        common:Claims claims = {role: (), userId: (), email: ()};

        // Extract userId
        if payload["userId"] is string {
            claims.userId = payload["userId"].toString();
        }

        // Extract email
        if payload["sub"] is string {
            claims.email = payload["sub"];
        }

        // Extract scopes
        if (payload["scp"] is string) {
            claims.role = payload["scp"].toString();
        }

        return claims;
    } else if decoded is jwt:Error {
        return error("JWT decode failed: " + decoded.toString());
    }
}

public function getUserIdFromClaims(common:Claims claims) returns string|error {
    if claims.userId is string {
        return <string>claims.userId;
    } else {
        return error("User ID not found in claims");
    }
}
