import ballerina/http;
import ballerinax/postgresql;
import ballerina/sql;
import ballerina/log;
import ballerina/uuid;
import ballerina/time;

configurable int db_port = ?;
configurable string db_host = ?;
configurable string db_pass = ?;
configurable string db_user = ?;
configurable string db_name = ?;

postgresql:Options postgresqlOptions = {
  connectTimeout: 10
};

postgresql:Client dbClient = check new (username = db_user, password = db_pass, database = db_name,host=db_host,port=db_port, options = postgresqlOptions);

service /bike\-service on new http:Listener(8090) {

    resource function get bikes() returns Response{

        log:printInfo("Received request: GET /bikes");

        sql:ParameterizedQuery query = `SELECT * FROM bikes`;

        stream<Bike, sql:Error?> result = dbClient->query(query, Bike);

        Bike[] bikes = [];

        error? e = result.forEach(function(Bike bike) {
            bikes.push(bike);
        });

        if e is error {
            log:printError("Error while processing bikes stream", err = e.toString());
            return {
                message: "Failed to insert bike" 
            };
        } else {
            log:printInfo("Successfully retrieved bikes: " + bikes.length().toString());
            return {
                message : "Bikes list retrieved successfully",
                data : bikes
            };
        }

        
    }

    resource function get bike/[string bikeId]() returns Response {

        log:printInfo("Received request: GET /bike/" + bikeId);

        sql:ParameterizedQuery query = `SELECT * FROM bikes WHERE bike_id = ${bikeId}`;

        stream<Bike, sql:Error?> result = dbClient->query(query, Bike);

        Bike[] bikes = [];

        error? e = result.forEach(function(Bike bike) {
            bikes.push(bike);
        });

        if e is error {
            log:printError("Error while processing bike stream", err = e.toString());
            return {
                message: "Failed to retrieve bike details"
            };
        }

        if bikes.length() == 0 {
            log:printWarn("Bike not found with ID: " + bikeId);
            return {
                message: "Bike not found"
            };
        }

        log:printInfo("Successfully retrieved bike details for ID: " + bikeId);
        return {
            message: "Bike details retrieved successfully",
            data: bikes[0]
        };
        
    }

    resource function post create\-bike(@http:Payload BikeInsert bike) returns Response {

        string generatedBikeId = uuid:createType1AsString();
        
        string currentTime = time:utcToString(time:utcNow());
        
        Bike newBike = {
            bikeId: generatedBikeId,
            addedById: bike.addedById,
            isActive: bike.isActive,
            isFlaggedForMaintenance: bike.isFlaggedForMaintenance,
            modelName: bike.modelName,
            brand: bike.brand,
            maxSpeed: bike.maxSpeed,
            rangeKm: bike.rangeKm,
            weightKg: bike.weightKg,
            imageUrl: bike.imageUrl,
            description: bike.description,
            createdAt: currentTime,
            updatedAt: currentTime
        };

        log:printInfo("Received request: POST /create-bike");

        sql:ParameterizedQuery insertQuery = `INSERT INTO bikes 
            (bike_id, added_by_id, is_active, is_flagged_for_maintenance, 
            model_name, brand, max_speed_kmh, range_km, weight_kg, image_url, 
            description, created_at, updated_at) 
            VALUES (${newBike.bikeId}, ${newBike.addedById}, ${newBike.isActive}, 
            ${newBike.isFlaggedForMaintenance}, ${newBike.modelName}, ${newBike.brand}, 
            ${newBike.maxSpeed}, ${newBike.rangeKm}, ${newBike.weightKg}, 
            ${newBike.imageUrl}, ${newBike.description}, ${newBike.createdAt}, ${newBike.updatedAt})`;

         var result = dbClient->execute(insertQuery);

        if result is sql:Error {
            log:printError("Failed to insert bike", err = result.toString());
            return {
                message: "Failed to insert bike"
            };
        }

        log:printInfo("Bike successfully created with ID: " + newBike.bikeId);
        return {
            message: "Bike created successfully",
            data: { id: newBike.bikeId }
        };
        
    }

    resource function put update\-bike/[string bikeId](@http:Payload BikeUpdate bikeUpdate) returns Response {

        log:printInfo("Received request: PUT /update-bike/" + bikeId);

        // First check if the bike exists
        sql:ParameterizedQuery checkQuery = `SELECT bike_id FROM bikes WHERE bike_id = ${bikeId}`;
        
        stream<record {string bike_id;}, sql:Error?> checkResult = dbClient->query(checkQuery);
        
        record {string bike_id;}[] existingBikes = [];
        error? checkError = checkResult.forEach(function(record {string bike_id;} bike) {
            existingBikes.push(bike);
        });

        if checkError is error {
            log:printError("Error while checking bike existence", err = checkError.toString());
            return {
                message: "Failed to check bike existence"
            };
        }

        if existingBikes.length() == 0 {
            log:printWarn("Bike not found with ID: " + bikeId);
            return {
                message: "Bike not found"
            };
        }

        // Get current time for updated_at
        string currentTime = time:utcToString(time:utcNow());

        // Use individual parameterized queries based on what fields are provided
        sql:ExecutionResult|sql:Error result;
        
        // Selective update - we'll use a simpler approach for now
        // First get the current bike data
        sql:ParameterizedQuery getCurrentQuery = `SELECT * FROM bikes WHERE bike_id = ${bikeId}`;
        stream<Bike, sql:Error?> currentResult = dbClient->query(getCurrentQuery, Bike);
        
        Bike? currentBike = ();
        error? fetchError = currentResult.forEach(function(Bike bike) {
            currentBike = bike;
        });
        
        if fetchError is error || currentBike is () {
            log:printError("Failed to fetch current bike data");
            return {
                message: "Failed to fetch current bike data"
            };
        }

        Bike bike = <Bike>currentBike;

        // Use current values or new values
        boolean finalIsActive = bikeUpdate.isActive ?: bike.isActive;
        boolean finalIsFlagged = bikeUpdate.isFlaggedForMaintenance ?: bike.isFlaggedForMaintenance;
        string finalModelName = bikeUpdate.modelName ?: bike.modelName;
        string finalBrand = bikeUpdate.brand ?: bike.brand;
        int finalMaxSpeed = bikeUpdate.maxSpeed ?: bike.maxSpeed;
        int finalRangeKm = bikeUpdate.rangeKm ?: bike.rangeKm;
        int finalWeightKg = bikeUpdate.weightKg ?: bike.weightKg;
        string? finalImageUrl = bikeUpdate.imageUrl ?: bike.imageUrl;
        string? finalDescription = bikeUpdate.description ?: bike.description;

        sql:ParameterizedQuery updateQuery = `UPDATE bikes SET 
            is_active = ${finalIsActive}, 
            is_flagged_for_maintenance = ${finalIsFlagged}, 
            model_name = ${finalModelName}, 
            brand = ${finalBrand}, 
            max_speed_kmh = ${finalMaxSpeed}, 
            range_km = ${finalRangeKm}, 
            weight_kg = ${finalWeightKg}, 
            image_url = ${finalImageUrl}, 
            description = ${finalDescription}, 
            updated_at = ${currentTime} 
            WHERE bike_id = ${bikeId}`;
        result = dbClient->execute(updateQuery);
        

        if result is sql:Error {
            log:printError("Failed to update bike", err = result.toString());
            return {
                message: "Failed to update bike"
            };
        }

        log:printInfo("Bike successfully updated with ID: " + bikeId);
        return {
            message: "Bike updated successfully",
            data: { id: bikeId }
        };
        
    }

    resource function delete delete\-bike/[string bikeId]() returns Response {

        log:printInfo("Received request: DELETE /delete-bike/" + bikeId);

        // First check if the bike exists and is currently active
        sql:ParameterizedQuery checkQuery = `SELECT bike_id, is_active FROM bikes WHERE bike_id = ${bikeId}`;
        
        stream<record {string bike_id; boolean is_active;}, sql:Error?> checkResult = dbClient->query(checkQuery);
        
        record {string bike_id; boolean is_active;}[] existingBikes = [];
        error? checkError = checkResult.forEach(function(record {string bike_id; boolean is_active;} bike) {
            existingBikes.push(bike);
        });

        if checkError is error {
            log:printError("Error while checking bike existence", err = checkError.toString());
            return {
                message: "Failed to check bike existence"
            };
        }

        if existingBikes.length() == 0 {
            log:printWarn("Bike not found with ID: " + bikeId);
            return {
                message: "Bike not found"
            };
        }

        // Check if bike is already soft deleted
        if !existingBikes[0].is_active {
            log:printWarn("Bike is already deleted with ID: " + bikeId);
            return {
                message: "Bike is already deleted"
            };
        }

        // Get current time for updated_at
        string currentTime = time:utcToString(time:utcNow());

        // Perform soft delete by setting is_active to false
        sql:ParameterizedQuery deleteQuery = `UPDATE bikes SET 
            is_active = false, 
            updated_at = ${currentTime} 
            WHERE bike_id = ${bikeId}`;

        var result = dbClient->execute(deleteQuery);

        if result is sql:Error {
            log:printError("Failed to soft delete bike", err = result.toString());
            return {
                message: "Failed to delete bike"
            };
        }

        log:printInfo("Bike successfully soft deleted with ID: " + bikeId);
        return {
            message: "Bike deleted successfully",
            data: { id: bikeId }
        };
        
    }

    resource function post restore\-bike/[string bikeId]() returns Response {

        log:printInfo("Received request: POST /restore-bike/" + bikeId);

        // First check if the bike exists and is currently inactive
        sql:ParameterizedQuery checkQuery = `SELECT bike_id, is_active FROM bikes WHERE bike_id = ${bikeId}`;
        
        stream<record {string bike_id; boolean is_active;}, sql:Error?> checkResult = dbClient->query(checkQuery);
        
        record {string bike_id; boolean is_active;}[] existingBikes = [];
        error? checkError = checkResult.forEach(function(record {string bike_id; boolean is_active;} bike) {
            existingBikes.push(bike);
        });

        if checkError is error {
            log:printError("Error while checking bike existence", err = checkError.toString());
            return {
                message: "Failed to check bike existence"
            };
        }

        if existingBikes.length() == 0 {
            log:printWarn("Bike not found with ID: " + bikeId);
            return {
                message: "Bike not found"
            };
        }

        // Check if bike is already active
        if existingBikes[0].is_active {
            log:printWarn("Bike is already active with ID: " + bikeId);
            return {
                message: "Bike is already active"
            };
        }

        // Get current time for updated_at
        string currentTime = time:utcToString(time:utcNow());

        // Restore bike by setting is_active to true
        sql:ParameterizedQuery restoreQuery = `UPDATE bikes SET 
            is_active = true, 
            updated_at = ${currentTime} 
            WHERE bike_id = ${bikeId}`;

        var result = dbClient->execute(restoreQuery);

        if result is sql:Error {
            log:printError("Failed to restore bike", err = result.toString());
            return {
                message: "Failed to restore bike"
            };
        }

        log:printInfo("Bike successfully restored with ID: " + bikeId);
        return {
            message: "Bike restored successfully",
            data: { id: bikeId }
        };
        
    }

    resource function get active\-bikes(int pageSize = 50, int pageOffset = 0) returns Response {

        log:printInfo("Received request: GET /active-bikes");

        sql:ParameterizedQuery query = `SELECT * FROM bikes WHERE is_active = true ORDER BY created_at DESC LIMIT ${pageSize} OFFSET ${pageOffset}`;
        sql:ParameterizedQuery countQuery = `SELECT COUNT(*) as total FROM bikes WHERE is_active = true`;

        stream<Bike, sql:Error?> result = dbClient->query(query, Bike);

        Bike[] bikes = [];

        error? e = result.forEach(function(Bike bike) {
            bikes.push(bike);
        });

        if e is error {
            log:printError("Error while processing active bikes stream", err = e.toString());
            return {
                message: "Failed to retrieve active bikes"
            };
        }

        // Get total count for pagination info
        stream<record {int total;}, sql:Error?> countResult = dbClient->query(countQuery);
        
        int totalCount = 0;
        error? countError = countResult.forEach(function(record {int total;} countRecord) {
            totalCount = countRecord.total;
        });

        if countError is error {
            log:printWarn("Failed to get total count, using bikes array length");
            totalCount = bikes.length();
        }

        log:printInfo("Successfully retrieved " + bikes.length().toString() + " active bikes out of " + totalCount.toString() + " total active bikes");
        
        return {
            message: "Active bikes retrieved successfully",
            data: {
                bikes: bikes,
                pagination: {
                    total: totalCount,
                    pageSize: pageSize,
                    offset: pageOffset,
                    returned: bikes.length()
                }
            }
        };
       
    }

}
