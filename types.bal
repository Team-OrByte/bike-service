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
