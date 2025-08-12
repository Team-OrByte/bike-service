// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/time;

public type Bike record {|
    readonly string bikeId;
    string addedById;
    boolean isActive;
    boolean isFlaggedForMaintenance;
    string modelName;
    string brand;
    int maxSpeed;
    int rangeKm;
    int weightKg;
    string imageUrl;
    string description;
    time:Civil createdAt;
    time:Civil updatedAt;
    boolean isReserved;
|};

public type BikeOptionalized record {|
    string bikeId?;
    string addedById?;
    boolean isActive?;
    boolean isFlaggedForMaintenance?;
    string modelName?;
    string brand?;
    int maxSpeed?;
    int rangeKm?;
    int weightKg?;
    string imageUrl?;
    string description?;
    time:Civil createdAt?;
    time:Civil updatedAt?;
    boolean isReserved?;
|};

public type BikeTargetType typedesc<BikeOptionalized>;

public type BikeInsert Bike;

public type BikeUpdate record {|
    string addedById?;
    boolean isActive?;
    boolean isFlaggedForMaintenance?;
    string modelName?;
    string brand?;
    int maxSpeed?;
    int rangeKm?;
    int weightKg?;
    string imageUrl?;
    string description?;
    time:Civil createdAt?;
    time:Civil updatedAt?;
    boolean isReserved?;
|};

