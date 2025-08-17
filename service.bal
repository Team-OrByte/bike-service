import ballerina/http;
import ballerina/log;
import bike_service.repository;
import ballerina/persist;
import ballerina/uuid;
import ballerina/time;
import ballerina/sql;

// configurable string pub_key = ?;

final repository:Client sClient = check new();

// @http:ServiceConfig{
//      auth: [
//         {
//             jwtValidatorConfig: {
//                 issuer: "Orbyte",
//                 audience: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa",
//                 signatureConfig: {
//                     certFile: pub_key
//                 },
//                 scopeKey: "scp"
//             },
//             scopes: ["user"]
//         }
//     ]
// }
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "OPTIONS"],
        allowHeaders: ["Content-Type", "Stripe-Signature"]
    }
}
service /bike\-service on new http:Listener(8090) {

    resource function get bikes() returns Response|error{

        log:printInfo("Received request: GET /bikes");

        stream <repository:Bike,persist:Error?> bikes = sClient->/bikes;
        repository:Bike[] bikeList = [];

        check bikes.forEach(function(repository:Bike bike) {
            bikeList.push(bike);
        });

        log:printInfo("Successfully retrieved bike details");

        return {
            statusCode: http:STATUS_OK,
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
                statusCode: http:STATUS_OK,
                message: "Bike details retrieved successfully",
                data: bike
            };
        }
        else {
            log:printWarn("Bike not found with ID: " + bikeId);
            return {
                statusCode: http:STATUS_NOT_FOUND,
                message: "Bike not found"
            };
        }
        
    }

    resource function post create\-bike(@http:Payload repository:BikeOptionalized bike) returns Response|error {

        string generatedBikeId = uuid:createType1AsString();
        string addedById = "7f34d7a7-c249-44c9-add1-50e79dda8703";
        
        time:Civil currentTime = time:utcToCivil(time:utcNow());

        //check all necessary fields are there
        if bike.modelName is () || bike.brand is () || bike.maxSpeed is () || bike.rangeKm is () || bike.weightKg is () {
            log:printError("Missing required fields for bike creation");
            return {
                statusCode: http:STATUS_BAD_REQUEST,
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
            isReserved: false,
            batteryLevel: <int>bike.batteryLevel,
            stationId: <string>bike.stationId
        };

        string[] result = check sClient->/bikes.post([newBike]);

        log:printInfo("Successfully created bike with ID: " + result[0]);
        return {
            statusCode: http:STATUS_OK,
            message: "Bike created successfully",
            data: result
        };
    }

    resource function put update\-bike/[string bikeId](@http:Payload repository:BikeUpdate bikeUpdate) returns Response|error {

        log:printInfo("Received request: PUT /update-bike/" + bikeId);

        time:Civil currentTime = time:utcToCivil(time:utcNow());

        bikeUpdate.updatedAt = currentTime;

        //update necessary fields only
        repository:Bike result = check sClient->/bikes/[bikeId].put(bikeUpdate);

        log:printInfo("Successfully updated bike with ID: " + bikeId);
        return {
            statusCode: http:STATUS_OK,
            message: "Bike updated successfully",
            data: result
        };
    }

    resource function delete delete\-bike/[string bikeId]() returns Response|error {

        log:printInfo("Received request: DELETE /delete-bike/" + bikeId);

        repository:Bike result = check  sClient->/bikes/[bikeId].delete();

        log:printInfo("Successfully deleted bike with ID: " + bikeId);
        return {
            statusCode: http:STATUS_OK,
            message: "Bike deleted successfully",
            data: result
        };
    }

    resource function put soft\-delete\-bike/[string bikeId]() returns Response | error {

        log:printInfo("Received request: PUT /soft-delete-bike/" + bikeId);

        repository:Bike result = check sClient->/bikes/[bikeId].put({
            isActive: false
        });

        log:printInfo("Successfully soft deleted bike with ID: " + bikeId);
        return {
            statusCode: http:STATUS_OK,
            message: "Bike soft deleted successfully",
            data: result
        };
        
    }

    resource function put restore\-bike/[string bikeId]() returns Response|error {

        log:printInfo("Received request: POST /restore-bike/" + bikeId);

        repository:Bike result = check sClient->/bikes/[bikeId].put({
            isActive: true
        });

        log:printInfo("Successfully restored bike with ID: " + bikeId);
        return {
            statusCode: http:STATUS_OK,
            message: "Bike restored successfully",
            data: result
        };
    }

    resource function get active\-bikes(int pageSize = 50, int pageOffset = 0) returns Response | error {

        log:printInfo("Received request: GET /active-bikes");

        sql:ParameterizedQuery whereClause = `"isActive" = true`;
        sql:ParameterizedQuery orderByClause = `"createdAt" `;
        sql:ParameterizedQuery limitClause = `${pageSize} OFFSET ${pageOffset}`;

        stream<repository:BikeOptionalized, persist:Error?> result = sClient->/bikes(
            <repository:BikeTargetType>repository:BikeOptionalized,
            whereClause,
            orderByClause,
            limitClause
        );

        repository:BikeOptionalized[] bikeList = [];
        check result.forEach(function(repository:BikeOptionalized bike) {
            bikeList.push(bike);
        });

        log:printInfo("Successfully retrieved bike details");
        return {
            statusCode: http:STATUS_OK,
            message: "Successfully retrieved bike details",
            data: bikeList
        };
    }

    resource function put reserve\-bike/[string bikeId]() returns Response|error {
        log:printInfo("Received request: PUT /reserve-bike/" + bikeId);

        //check if the bike is already reserved,under maintenance or deleted
        BikeStatus|persist:Error availabilityCheck = check sClient->/bikes/[bikeId]();

        if availabilityCheck is BikeStatus {
            if !availabilityCheck.isActive {
                log:printError("Failed to reserve bike with ID: " + bikeId);
                return {
                    statusCode: http:STATUS_BAD_REQUEST,
                    message: "Bike is deleted or under maintenance"
                };
            }
            else if availabilityCheck.isReserved {
                log:printError("Failed to reserve bike with ID: " + bikeId);
                return {
                    statusCode: http:STATUS_BAD_REQUEST,
                    message: "Bike is already reserved"
                };
            }            
        }

        repository:Bike result = check sClient->/bikes/[bikeId].put({
            isReserved: true
        });

        log:printInfo("Successfully reserved bike with ID: " + bikeId);
        return {
            statusCode: http:STATUS_OK,
            message: "Bike reserved successfully",
            data: result
        };
    }

    resource function put release\-bike/[string bikeId]() returns Response | error{
        log:printInfo("Received request: PUT /reserve-bike/" + bikeId);

        repository:Bike result = check sClient->/bikes/[bikeId].put({
            isReserved: false
        });

        log:printInfo("Successfully released bike with ID: " + bikeId);
        return {
            statusCode: http:STATUS_OK,
            message: "Bike released successfully",
            data: result
        };
    }

    resource function get unreserved\-bikes(int pageSize = 50, int pageOffset = 0) returns Response|error {
        log:printInfo("Received request: GET /unreserved-bikes");

        sql:ParameterizedQuery whereClause = `"isReserved" = false`;
        sql:ParameterizedQuery orderByClause = `"createdAt" `;
        sql:ParameterizedQuery limitClause = `${pageSize} OFFSET ${pageOffset}`;

        stream<repository:BikeOptionalized, persist:Error?> result = sClient->/bikes(
            <repository:BikeTargetType>repository:BikeOptionalized,
            whereClause,
            orderByClause,
            limitClause
        );

        repository:BikeOptionalized[] bikeList = [];
        check result.forEach(function(repository:BikeOptionalized bike) {
            bikeList.push(bike);
        });

        return {
            statusCode: http:STATUS_OK,
            message: "Successfully retrieved bike details",
            data: bikeList
        };
    }

    //add a station
    resource function post add\-station(@http:Payload repository:StationOptionalized station) returns Response|error {
        log:printInfo("Received request: POST /add-station");
        string generatedBikeId = uuid:createType1AsString();
        time:Civil currentTime = time:utcToCivil(time:utcNow());

        repository:Station newStation = {
            stationId: generatedBikeId,
            name: <string>station.name,
            address: <string>station.address,
            description: <string>station.description,
            createdAt: currentTime,
            updatedAt: currentTime,
            imageUrl: <string>station.imageUrl,
            phone: <string>station.phone,
            latitude: <string>station.latitude,
            longitude: <string>station.longitude,
            operatingHours: <string>station.operatingHours
        };

        string[] result = check sClient->/stations.post([newStation]);

        return {
            statusCode: http:STATUS_CREATED,
            message: "Successfully added station",
            data: result
        };
    }

    resource function get stations() returns Response|error {
        log:printInfo("Received request: GET /stations");
        stream<repository:Station, persist:Error?> result = sClient->/stations();
        repository:Station[] stationList = [];
        check result.forEach(function(repository:Station station) {
            stationList.push(station);
        });
        return {
            statusCode: http:STATUS_OK,
            message: "Successfully retrieved station details",
            data: stationList
        };
    }

    resource function get nearby\-stations(string latitude, string longitude, int radius) returns Response|error {
        log:printInfo("Received request: GET /nearby-stations");

        //implement the logic for this
        stream<repository:Station, persist:Error?> result = sClient->/stations();
        repository:Station[] stationList = [];
        check result.forEach(function(repository:Station station) {
            stationList.push(station);
        });
        return {
            statusCode: http:STATUS_OK,
            message: "Successfully retrieved station details",
            data: stationList
        };
    }

    resource function get bikes\-by\-station/[string stationId]( int pageSize = 50, int pageOffset = 0) returns Response|error {
        log:printInfo("Received request: GET /bikes-by-station");
        //implement the logic for this
        sql:ParameterizedQuery whereClause = `"stationId" = ${stationId}`;
        sql:ParameterizedQuery orderByClause = `"createdAt" `;
        sql:ParameterizedQuery limitClause = `${pageSize} OFFSET ${pageOffset}`;
        stream<repository:BikeOptionalized, persist:Error?> result = sClient->/bikes(
            <repository:BikeTargetType>repository:BikeOptionalized,
            whereClause,
            orderByClause,
            limitClause
        );
        repository:BikeOptionalized[] bikeList = [];
        check result.forEach(function(repository:BikeOptionalized bike) {
            bikeList.push(bike);
        });
        return {
            statusCode: http:STATUS_OK,
            message: "Successfully retrieved bike details",
            data: bikeList
        };
    }

    resource function put update\-bike\-station/[string bikeId](string stationId) returns Response|error {
        log:printInfo("Received request: PUT /update-bike-station/" + bikeId);

        //implement the logic for this
        repository:Bike result = check sClient->/bikes/[bikeId].put({
            stationId: stationId
        });
        return {
            statusCode: http:STATUS_OK,
            message: "Successfully updated bike station",
            data: result
        };
    }
    
}
