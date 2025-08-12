type Response record {
    string message?;
    anydata data?;
};

type BikeStatus record {|
    boolean isActive;
    boolean isFlaggedForMaintenance;
    boolean isReserved;
|};