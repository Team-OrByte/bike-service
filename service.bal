import ballerina/http;
import ballerina/log;
import bike_service.repository;
import ballerina/persist;


final repository:Client sClient = check new();

service /bike\-service on new http:Listener(8090) {

    resource function get bikes() returns Response{

        log:printInfo("Received request: GET /bikes");

        stream <repository:Bike,persist:Error?> bikes = sClient->/bikes;
        repository:Bike[] bikeList = [];
        error? e = bikes.forEach(function(repository:Bike bike) {
            bikeList.push(bike);
        });

        if e is error {
            log:printError("Error while processing bike stream", err = e.toString());
            return {
                message: "Failed to retrieve bike details"
            };
        }

        log:printInfo("Successfully retrieved bike details");

        return {
            message: "Bikes retrieved successfully",
            data: bikeList
        };
    }

    // resource function get bike/[string bikeId]() returns Response {

    //     log:printInfo("Received request: GET /bike/" + bikeId);

    //     sql:ParameterizedQuery query = `SELECT * FROM bikes WHERE bikeId = ${bikeId}`;

    //     stream<Bike, sql:Error?> result = dbClient->query(query, Bike);

    //     Bike[] bikes = [];

    //     error? e = result.forEach(function(Bike bike) {
    //         bikes.push(bike);
    //     });

    //     if e is error {
    //         log:printError("Error while processing bike stream", err = e.toString());
    //         return {
    //             message: "Failed to retrieve bike details"
    //         };
    //     }

    //     if bikes.length() == 0 {
    //         log:printWarn("Bike not found with ID: " + bikeId);
    //         return {
    //             message: "Bike not found"
    //         };
    //     }

    //     log:printInfo("Successfully retrieved bike details for ID: " + bikeId);
    //     return {
    //         message: "Bike details retrieved successfully",
    //         data: bikes[0]
    //     };
        
    // }

    // resource function post create\-bike(@http:Payload BikeInsert bike) returns Response {

    //     string generatedBikeId = uuid:createType1AsString();
        
    //     time:Civil currentTime = time:utcToCivil(time:utcNow());
        
    //     Bike newBike = {
    //         bikeId: generatedBikeId,
    //         addedById: bike.addedById,
    //         modelName: bike.modelName,
    //         brand: bike.brand,
    //         maxSpeed: bike.maxSpeed,
    //         rangeKm: bike.rangeKm,
    //         weightKg: bike.weightKg,
    //         imageUrl: bike.imageUrl,
    //         description: bike.description,
    //         createdAt: currentTime,
    //         updatedAt: currentTime,
    //         isActive: true,
    //         isFlaggedForMaintenance: false,
    //         isReserved: false
    //     };

    //     log:printInfo("Received request: POST /create-bike");

    //     sql:ParameterizedQuery insertQuery = `INSERT INTO bikes 
    //         (bikeId, addedById, isActive, isFlaggedForMaintenance, 
    //         modelName, brand, maxSpeed, rangeKm, weightKg, imageUrl, 
    //         description, createdAt, updatedAt) 
    //         VALUES (${newBike.bikeId}, ${newBike.addedById}, ${newBike.isActive}, 
    //         ${newBike.isFlaggedForMaintenance}, ${newBike.modelName}, ${newBike.brand}, 
    //         ${newBike.maxSpeed}, ${newBike.rangeKm}, ${newBike.weightKg}, 
    //         ${newBike.imageUrl}, ${newBike.description}, ${newBike.createdAt}, ${newBike.updatedAt})`;

    //      var result = dbClient->execute(insertQuery);

    //     if result is sql:Error {
    //         log:printError("Failed to insert bike", err = result.toString());
    //         return {
    //             message: "Failed to insert bike"
    //         };
    //     }

    //     log:printInfo("Bike successfully created with ID: " + newBike.bikeId);
    //     return {
    //         message: "Bike created successfully",
    //         data: { id: newBike.bikeId }
    //     };
        
    // }

    // resource function put update\-bike/[string bikeId](@http:Payload BikeUpdate bikeUpdate) returns Response {

    //     log:printInfo("Received request: PUT /update-bike/" + bikeId);

    //     time:Civil currentTime = time:utcToCivil(time:utcNow());

    //     sql:ExecutionResult|sql:Error result;
        
    //     sql:ParameterizedQuery getCurrentQuery = `SELECT * FROM bikes WHERE bikeId = ${bikeId}`;
    //     stream<Bike, sql:Error?> currentResult = dbClient->query(getCurrentQuery, Bike);
        
    //     Bike? currentBike = ();
    //     error? fetchError = currentResult.forEach(function(Bike bike) {
    //         currentBike = bike;
    //     });
        
    //     if fetchError is error || currentBike is () {
    //         log:printError("Failed to fetch current bike data");
    //         return {
    //             message: "Failed to fetch current bike data"
    //         };
    //     }

    //     Bike bike = <Bike>currentBike;

    //     boolean finalIsActive = bikeUpdate.isActive ?: bike.isActive;
    //     boolean finalIsFlagged = bikeUpdate.isFlaggedForMaintenance ?: bike.isFlaggedForMaintenance;
    //     string finalModelName = bikeUpdate.modelName ?: bike.modelName;
    //     string finalBrand = bikeUpdate.brand ?: bike.brand;
    //     int finalMaxSpeed = bikeUpdate.maxSpeed ?: bike.maxSpeed;
    //     int finalRangeKm = bikeUpdate.rangeKm ?: bike.rangeKm;
    //     int finalWeightKg = bikeUpdate.weightKg ?: bike.weightKg;
    //     string? finalImageUrl = bikeUpdate.imageUrl ?: bike.imageUrl;
    //     string? finalDescription = bikeUpdate.description ?: bike.description;
    //     boolean isReserved = bikeUpdate.isReserved ?: bike.isReserved;

    //     sql:ParameterizedQuery updateQuery = `UPDATE bikes SET 
    //         isActive = ${finalIsActive}, 
    //         isFlaggedForMaintenance = ${finalIsFlagged}, 
    //         modelName = ${finalModelName}, 
    //         brand = ${finalBrand}, 
    //         maxSpeed = ${finalMaxSpeed}, 
    //         rangeKm = ${finalRangeKm}, 
    //         weightKg = ${finalWeightKg}, 
    //         imageUrl = ${finalImageUrl}, 
    //         description = ${finalDescription}, 
    //         updatedAt = ${currentTime},
    //         isReserved = ${isReserved}, 
    //         WHERE bikeId = ${bikeId}`;
    //     result = dbClient->execute(updateQuery);
        

    //     if result is sql:Error {
    //         log:printError("Failed to update bike", err = result.toString());
    //         return {
    //             message: "Failed to update bike"
    //         };
    //     }

    //     log:printInfo("Bike successfully updated with ID: " + bikeId);
    //     return {
    //         message: "Bike updated successfully",
    //         data: { id: bikeId }
    //     };
        
    // }

    // resource function delete delete\-bike/[string bikeId]() returns Response {

    //     log:printInfo("Received request: DELETE /delete-bike/" + bikeId);

    //     // First check if the bike exists and is currently active
    //     sql:ParameterizedQuery checkQuery = `SELECT bikeId, isActive FROM bikes WHERE bikeId = ${bikeId}`;
        
    //     stream<record {string bikeId; boolean isActive;}, sql:Error?> checkResult = dbClient->query(checkQuery);
        
    //     record {string bikeId; boolean isActive;}[] existingBikes = [];
    //     error? checkError = checkResult.forEach(function(record {string bikeId; boolean isActive;} bike) {
    //         existingBikes.push(bike);
    //     });

    //     if checkError is error {
    //         log:printError("Error while checking bike existence", err = checkError.toString());
    //         return {
    //             message: "Failed to check bike existence"
    //         };
    //     }

    //     if existingBikes.length() == 0 {
    //         log:printWarn("Bike not found with ID: " + bikeId);
    //         return {
    //             message: "Bike not found"
    //         };
    //     }

    //     // Check if bike is already soft deleted
    //     if !existingBikes[0].isActive {
    //         log:printWarn("Bike is already deleted with ID: " + bikeId);
    //         return {
    //             message: "Bike is already deleted"
    //         };
    //     }

    //     // Get current time for updated_at
    //     string currentTime = time:utcToString(time:utcNow());

    //     // Perform soft delete by setting is_active to false
    //     sql:ParameterizedQuery deleteQuery = `UPDATE bikes SET 
    //         is_active = false, 
    //         updated_at = ${currentTime} 
    //         WHERE bike_id = ${bikeId}`;

    //     var result = dbClient->execute(deleteQuery);

    //     if result is sql:Error {
    //         log:printError("Failed to soft delete bike", err = result.toString());
    //         return {
    //             message: "Failed to delete bike"
    //         };
    //     }

    //     log:printInfo("Bike successfully soft deleted with ID: " + bikeId);
    //     return {
    //         message: "Bike deleted successfully",
    //         data: { id: bikeId }
    //     };
        
    // }

    // resource function post restore\-bike/[string bikeId]() returns Response {

    //     log:printInfo("Received request: POST /restore-bike/" + bikeId);

    //     // First check if the bike exists and is currently inactive
    //     sql:ParameterizedQuery checkQuery = `SELECT bike_id, is_active FROM bikes WHERE bike_id = ${bikeId}`;
        
    //     stream<record {string bike_id; boolean is_active;}, sql:Error?> checkResult = dbClient->query(checkQuery);
        
    //     record {string bike_id; boolean is_active;}[] existingBikes = [];
    //     error? checkError = checkResult.forEach(function(record {string bike_id; boolean is_active;} bike) {
    //         existingBikes.push(bike);
    //     });

    //     if checkError is error {
    //         log:printError("Error while checking bike existence", err = checkError.toString());
    //         return {
    //             message: "Failed to check bike existence"
    //         };
    //     }

    //     if existingBikes.length() == 0 {
    //         log:printWarn("Bike not found with ID: " + bikeId);
    //         return {
    //             message: "Bike not found"
    //         };
    //     }

    //     // Check if bike is already active
    //     if existingBikes[0].is_active {
    //         log:printWarn("Bike is already active with ID: " + bikeId);
    //         return {
    //             message: "Bike is already active"
    //         };
    //     }

    //     // Get current time for updated_at
    //     string currentTime = time:utcToString(time:utcNow());

    //     // Restore bike by setting is_active to true
    //     sql:ParameterizedQuery restoreQuery = `UPDATE bikes SET 
    //         is_active = true, 
    //         updated_at = ${currentTime} 
    //         WHERE bike_id = ${bikeId}`;

    //     var result = dbClient->execute(restoreQuery);

    //     if result is sql:Error {
    //         log:printError("Failed to restore bike", err = result.toString());
    //         return {
    //             message: "Failed to restore bike"
    //         };
    //     }

    //     log:printInfo("Bike successfully restored with ID: " + bikeId);
    //     return {
    //         message: "Bike restored successfully",
    //         data: { id: bikeId }
    //     };
        
    // }

    // resource function get active\-bikes(int pageSize = 50, int pageOffset = 0) returns Response {

    //     log:printInfo("Received request: GET /active-bikes");

    //     sql:ParameterizedQuery query = `SELECT * FROM bikes WHERE is_active = true ORDER BY created_at DESC LIMIT ${pageSize} OFFSET ${pageOffset}`;
    //     sql:ParameterizedQuery countQuery = `SELECT COUNT(*) as total FROM bikes WHERE is_active = true`;

    //     stream<Bike, sql:Error?> result = dbClient->query(query, Bike);

    //     Bike[] bikes = [];

    //     error? e = result.forEach(function(Bike bike) {
    //         bikes.push(bike);
    //     });

    //     if e is error {
    //         log:printError("Error while processing active bikes stream", err = e.toString());
    //         return {
    //             message: "Failed to retrieve active bikes"
    //         };
    //     }

    //     // Get total count for pagination info
    //     stream<record {int total;}, sql:Error?> countResult = dbClient->query(countQuery);
        
    //     int totalCount = 0;
    //     error? countError = countResult.forEach(function(record {int total;} countRecord) {
    //         totalCount = countRecord.total;
    //     });

    //     if countError is error {
    //         log:printWarn("Failed to get total count, using bikes array length");
    //         totalCount = bikes.length();
    //     }

    //     log:printInfo("Successfully retrieved " + bikes.length().toString() + " active bikes out of " + totalCount.toString() + " total active bikes");
        
    //     return {
    //         message: "Active bikes retrieved successfully",
    //         data: {
    //             bikes: bikes,
    //             pagination: {
    //                 total: totalCount,
    //                 pageSize: pageSize,
    //                 offset: pageOffset,
    //                 returned: bikes.length()
    //             }
    //         }
    //     };
       
    // }

    // resource function put reserve\-bike/[string bikeId]() returns Response {
    //     log:printInfo("Received request: PUT /reserve-bike/" + bikeId);

    //     // Check if the bike exists and is active
    //     sql:ParameterizedQuery checkQuery = `SELECT * FROM bikes WHERE bikeId = ${bikeId}`;
        
    //     Bike|sql:Error bike = dbClient->queryRow(checkQuery);

        
        
    //     return {
    //         message: "Bike reservation functionality is not implemented yet",
    //         data : {}
    //     };

    // }

    // resource function put release\-bike/[string bikeId]() returns Response {
    //     log:printInfo("Received request: PUT /reserve-bike/" + bikeId);

    //     // Check if the bike exists and is active
    //     sql:ParameterizedQuery checkQuery = `SELECT bike_id, is_active FROM bikes WHERE bike_id = ${bikeId}`;
        
    //     stream<record {string bikeId; boolean isActive; boolean isReserved;}, sql:Error?> checkResult = dbClient->query(checkQuery);
        
        
    //     return {
    //         message: "Bike reservation functionality is not implemented yet",
    //         data : {}
    //     };

    // }

}
