type Bike record {
    string bikeId;
    string addedById;
    boolean isActive;
    boolean isFlaggedForMaintenance;
    string modelName;
    string brand;
    int maxSpeed;
    int rangeKm;
    int weightKg;
    string imageUrl?;
    string description?;
    string createdAt; 
    string updatedAt;
};

type BikeInsert record {
    string addedById;
    boolean isActive;
    boolean isFlaggedForMaintenance;
    string modelName;
    string brand;
    int maxSpeed;
    int rangeKm;
    int weightKg;
    string imageUrl?;
    string description?;
};

type BikeUpdate record {
    boolean isActive?;
    boolean isFlaggedForMaintenance?;
    string modelName?;
    string brand?;
    int maxSpeed?;
    int rangeKm?;
    int weightKg?;
    string imageUrl?;
    string description?;
};

type Response record {
    string message?;
    anydata data?;
};