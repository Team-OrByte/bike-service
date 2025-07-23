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
            model_name, brand, max_speed, range_km, weight_kg, image_url, 
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
}
