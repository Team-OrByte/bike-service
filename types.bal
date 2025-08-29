type Response record {
    int statusCode;
    string message?;
    anydata data?;
};

type BikeStatus record {|
    boolean isActive;
    boolean isFlaggedForMaintenance;
    boolean isReserved;
|};

public type Claims record {|
    string? userId;
    string? email;
    string? role;
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