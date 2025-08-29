// Common response structure
public type Response record {
    int statusCode;
    string message?;
    anydata data?;
};

// Authentication related types
public type Claims record {|
    string? userId;
    string? email;
    string? role;
|};

// Bike status for availability checks
public type BikeStatus record {|
    boolean isActive;
    boolean isFlaggedForMaintenance;
    boolean isReserved;
|};

// Ride event types for Kafka
public enum RideEventType {
    RIDE_STARTED,
    RIDE_ENDED
}

public type RideEvent record {|
    RideEventType eventType;
    string userId;
    string rideId;
    string bikeId;
    string startStation?;
    string endStation?;
    int duration?;
    decimal fare?;
|};

// Common validation functions
public function validateRequired(anydata value, string fieldName) returns error? {
    if value is () {
        return error("Missing required field: " + fieldName);
    }
}

public function createSuccessResponse(int statusCode, string message, anydata data = ()) returns Response {
    return {
        statusCode: statusCode,
        message: message,
        data: data
    };
}

public function createErrorResponse(int statusCode, string message) returns Response {
    return {
        statusCode: statusCode,
        message: message
    };
}
