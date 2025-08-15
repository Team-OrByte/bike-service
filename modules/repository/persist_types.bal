// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/time;

public type Bike record {|
    readonly string bikeId;
    string stationId;
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
    int batteryLevel;
|};

public type BikeOptionalized record {|
    string bikeId?;
    string stationId?;
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
    int batteryLevel?;
|};

public type BikeTargetType typedesc<BikeOptionalized>;

public type BikeInsert Bike;

public type BikeUpdate record {|
    string stationId?;
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
    int batteryLevel?;
|};

public type Station record {|
    readonly string stationId;
    string name;
    string address;
    string description;
    string imageUrl;
    string phone;
    string latitude;
    string longitude;
    string operatingHours;
    time:Civil createdAt;
    time:Civil updatedAt;
|};

public type StationOptionalized record {|
    string stationId?;
    string name?;
    string address?;
    string description?;
    string imageUrl?;
    string phone?;
    string latitude?;
    string longitude?;
    string operatingHours?;
    time:Civil createdAt?;
    time:Civil updatedAt?;
|};

public type StationTargetType typedesc<StationOptionalized>;

public type StationInsert Station;

public type StationUpdate record {|
    string name?;
    string address?;
    string description?;
    string imageUrl?;
    string phone?;
    string latitude?;
    string longitude?;
    string operatingHours?;
    time:Civil createdAt?;
    time:Civil updatedAt?;
|};

