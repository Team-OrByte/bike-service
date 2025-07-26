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
}
