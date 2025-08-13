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