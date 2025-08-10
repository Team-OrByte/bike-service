import ballerina/http;
import ballerina/log;
import bike_service.repository;
import ballerina/persist;
import ballerina/uuid;
import ballerina/time;


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

    resource function get bike/[string bikeId]() returns Response {

        log:printInfo("Received request: GET /bike/" + bikeId);

        repository:Bike|persist:Error bike = sClient->/bikes/[bikeId]();

        if bike is repository:Bike {
            log:printInfo("Successfully retrieved bike details");
            return {
                message: "Bike details retrieved successfully",
                data: bike
            };
        }
        else {
            log:printWarn("Bike not found with ID: " + bikeId);
            return {
                message: "Bike not found"
            };
        }
        
    }

    resource function post create\-bike(@http:Payload repository:BikeOptionalized bike) returns Response {

        string generatedBikeId = uuid:createType1AsString();
        string addedById = "7f34d7a7-c249-44c9-add1-50e79dda8703";
        
        time:Civil currentTime = time:utcToCivil(time:utcNow());

        //check all necessary fields are there
        if bike.modelName is () || bike.brand is () || bike.maxSpeed is () || bike.rangeKm is () || bike.weightKg is () {
            log:printError("Missing required fields for bike creation");
            return {
                message: "Missing required fields for bike creation"
            };
        }
        
        repository:Bike newBike = {
            bikeId: generatedBikeId,
            addedById: addedById,
            modelName: <string>bike.modelName,
            brand: <string>bike.brand,
            maxSpeed: <int>bike.maxSpeed,
            rangeKm: <int>bike.rangeKm,
            weightKg: <int>bike.weightKg,
            imageUrl: <string>bike.imageUrl,
            description: <string>bike.description,
            createdAt: currentTime,
            updatedAt: currentTime,
            isActive: true,
            isFlaggedForMaintenance: false,
            isReserved: false
        };

        string[]|persist:Error result = sClient->/bikes.post([newBike]);

        if result is string[] {
            log:printInfo("Successfully created bike with ID: " + result[0]);
            return {
                message: "Bike created successfully",
                data: result
            };
        }
        else {
            log:printError("Failed to create bike");
            return {
                message: "Failed to create bike"
            };
        }
        
        
    }

    resource function put update\-bike/[string bikeId](@http:Payload repository:BikeUpdate bikeUpdate) returns Response {

        log:printInfo("Received request: PUT /update-bike/" + bikeId);

        time:Civil currentTime = time:utcToCivil(time:utcNow());

        bikeUpdate.updatedAt = currentTime;

        //update necessary fields only
        repository:Bike|persist:Error result = sClient->/bikes/[bikeId].put(bikeUpdate);

        if result is repository:Bike {
            log:printInfo("Successfully updated bike with ID: " + bikeId);
            return {
                message: "Bike updated successfully",
                data: result
            };
        }
        else {
            log:printError("Failed to update bike with ID: " + bikeId);
            return {
                message: "Failed to update bike : " + result.toString()
            };
        }
    }

    resource function delete delete\-bike/[string bikeId]() returns Response {

        log:printInfo("Received request: DELETE /delete-bike/" + bikeId);

        repository:Bike|persist:Error result = sClient->/bikes/[bikeId].delete();

        if result is repository:Bike {
            log:printInfo("Successfully deleted bike with ID: " + bikeId);
            return {
                message: "Bike deleted successfully",
                data: result
            };
        }
        else {
            log:printError("Failed to delete bike with ID: " + bikeId);
            return {
                message: "Failed to delete bike : " + result.toString()
            };
        }
    }

    resource function put soft\-delete\-bike/[string bikeId]() returns Response {

        log:printInfo("Received request: PUT /soft-delete-bike/" + bikeId);

        repository:Bike|persist:Error result = sClient->/bikes/[bikeId].put({
            isActive: false
        });

        if result is repository:Bike {
            log:printInfo("Successfully soft deleted bike with ID: " + bikeId);
            return {
                message: "Bike soft deleted successfully",
                data: result
            };
        }
        else {
            log:printError("Failed to soft delete bike with ID: " + bikeId);
            return {
                message: "Failed to soft delete bike : " + result.toString()
            };
        }
    }

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
