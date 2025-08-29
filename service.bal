import ballerina/http;
import ballerina/log;
import bike_service.repository;
import ballerina/persist;
import ballerina/uuid;
import ballerina/time;
import ballerina/sql;
import ballerinax/kafka;

configurable string pub_key = ?;
configurable string kafkaBootstrapServers = ?;

final repository:Client sClient = check new();

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["POST", "PUT", "GET", "POST", "OPTIONS"],
        allowHeaders: ["Content-Type", "Access-Control-Allow-Origin", "X-Service-Name"]
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

    @http:ResourceConfig {
            auth: [
            {
                jwtValidatorConfig: {
                    issuer: "Orbyte",
                    audience: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa",
                    signatureConfig: {
                        certFile: pub_key
                    },
                    scopeKey: "scp"
                },
                scopes: "admin"
            }
        ]
    }
    resource function post create\-bike(@http:Header string Authorization,@http:Payload repository:BikeOptionalized bike) returns Response|error {

        string generatedBikeId = uuid:createType1AsString();

        Claims claims = check extractClaims(Authorization);
        string userId;
        if claims.userId is string {
            userId = <string>claims.userId;
        } else {
            return {
                statusCode: http:STATUS_UNAUTHORIZED,
                message: "Unauthorized"
            };
        }

        string addedById = userId;
        
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

    @http:ResourceConfig {
        auth: [
        {
            jwtValidatorConfig: {
                issuer: "Orbyte",
                audience: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa",
                signatureConfig: {
                    certFile: pub_key
                },
                scopeKey: "scp"
            },
            scopes: "admin"
        }
    ]
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

    @http:ResourceConfig {
        auth: [
        {
            jwtValidatorConfig: {
                issuer: "Orbyte",
                audience: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa",
                signatureConfig: {
                    certFile: pub_key
                },
                scopeKey: "scp"
            },
            scopes: "admin"
        }
    ]
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

    @http:ResourceConfig {
        auth: [
        {
            jwtValidatorConfig: {
                issuer: "Orbyte",
                audience: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa",
                signatureConfig: {
                    certFile: pub_key
                },
                scopeKey: "scp"
            },
            scopes: "admin"
        }
    ]
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

    @http:ResourceConfig {
        auth: [
        {
            jwtValidatorConfig: {
                issuer: "Orbyte",
                audience: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa",
                signatureConfig: {
                    certFile: pub_key
                },
                scopeKey: "scp"
            },
            scopes: "admin"
        }
    ]
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

    @http:ResourceConfig {
        auth: [
        {
            jwtValidatorConfig: {
                issuer: "Orbyte",
                audience: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa",
                signatureConfig: {
                    certFile: pub_key
                },
                scopeKey: "scp"
            },
            scopes: "user"
        }
    ]
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

    @http:ResourceConfig {
        auth: [
        {
            jwtValidatorConfig: {
                issuer: "Orbyte",
                audience: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa",
                signatureConfig: {
                    certFile: pub_key
                },
                scopeKey: "scp"
            },
            scopes: "user"
        }
    ]
    }
    resource function put release\-bike/[string bikeId](string endLocation) returns Response | error{
        log:printInfo("Received request: PUT /reserve-bike/" + bikeId);

        repository:Bike result = check sClient->/bikes/[bikeId].put({
            isReserved: false,
            stationId: endLocation
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
    @http:ResourceConfig {
        auth: [
        {
            jwtValidatorConfig: {
                issuer: "Orbyte",
                audience: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa",
                signatureConfig: {
                    certFile: pub_key
                },
                scopeKey: "scp"
            },
            scopes: "admin"
        }
    ]
    }
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
        sql:ParameterizedQuery whereClause = `"stationId" = ${stationId} and "isActive" = true and "isReserved" = false`;
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

    @http:ResourceConfig {
        auth: [
        {
            jwtValidatorConfig: {
                issuer: "Orbyte",
                audience: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa",
                signatureConfig: {
                    certFile: pub_key
                },
                scopeKey: "scp"
            },
            scopes: "user"
        }
    ]
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

//implement the kafka listeners for ride events

kafka:ConsumerConfiguration consumerConfiguration = {
    groupId: "ride-events",
    topics: ["ride-events"],
    pollingInterval: 1,
    autoCommit: false
};

listener kafka:Listener kafkaListener = new (kafkaBootstrapServers,consumerConfiguration);

service on kafkaListener {
    remote function onConsumerRecord(kafka:Caller caller, kafka:AnydataConsumerRecord[] records) returns error? {
        
        foreach kafka:AnydataConsumerRecord kafkaRecord in records {
            anydata messageValue = kafkaRecord.value;
            string messageString;
            
            if messageValue is byte[] {
                messageString = check string:fromBytes(messageValue);
            } else if messageValue is string {
                messageString = messageValue;
            } else {
                messageString = messageValue.toString();
            }
            
            log:printInfo("Received Kafka message: " + messageString);
            
            // Parse the JSON message to RideEvent
            json messageJson = check messageString.fromJsonString();
            RideEvent rideEvent = check messageJson.cloneWithType(RideEvent);
            
            // Handle the ride event
            error? result = handleRideEvent(rideEvent);
            if result is error {
                log:printError("Error handling ride event: " + result.message());
                // Don't commit if there's an error
                return result;
            }
        }
        
        // Commit the messages after successful processing
        check caller->commit();
        log:printInfo("Successfully committed Kafka messages");
    }
}

// Function to handle different ride events
function handleRideEvent(RideEvent rideEvent) returns error? {
    match rideEvent.eventType {
        RIDE_STARTED => {
            log:printInfo("Ride started - User: " + rideEvent.userId + ", Bike: " + rideEvent.bikeId + ", Station: " + (rideEvent.startStation ?: "Unknown"));
            // For ride started, we might want to ensure the bike is reserved
            // This is typically handled by the reservation endpoint, but we can add validation here
            return validateBikeReservation(rideEvent.bikeId);
        }
        RIDE_ENDED => {
            log:printInfo("Ride ended - User: " + rideEvent.userId + ", Bike: " + rideEvent.bikeId + ", End Station: " + (rideEvent.endStation ?: "Unknown"));
            // Release the bike and update its station
            return releaseBikeAfterRide(rideEvent);
        }
    }
}

// Function to validate bike reservation
function validateBikeReservation(string bikeId) returns error? {
    repository:Bike|persist:Error bike = sClient->/bikes/[bikeId]();
    
    if bike is repository:Bike {
        if !bike.isReserved {
            log:printWarn("Bike " + bikeId + " is not reserved but ride started");
            // Optionally, we could reserve it here
            repository:Bike _ = check sClient->/bikes/[bikeId].put({
                isReserved: true
            });
            log:printInfo("Auto-reserved bike " + bikeId + " for active ride");
        }
    } else {
        log:printError("Bike " + bikeId + " not found during ride start validation");
        return error("Bike not found");
    }
}

// Function to release bike after ride ends
function releaseBikeAfterRide(RideEvent rideEvent) returns error? {
    string bikeId = rideEvent.bikeId;
    string? endStation = rideEvent.endStation;
    
    // Prepare update data
    repository:BikeUpdate updateData = {
        isReserved: false
    };
    
    // If end station is provided, update the bike's station
    if endStation is string && endStation.trim() != "" {
        updateData.stationId = endStation;
        log:printInfo("Releasing bike " + bikeId + " at station " + endStation);
    } else {
        log:printInfo("Releasing bike " + bikeId + " (station unchanged)");
    }
    
    // Update the bike in the database
    repository:Bike|persist:Error result = sClient->/bikes/[bikeId].put(updateData);
    
    if result is repository:Bike {
        log:printInfo("Successfully released bike " + bikeId + " after ride completion");
        
        // Log ride details if available
        if rideEvent.duration is int && rideEvent.fare is decimal {
            log:printInfo("Ride details - Duration: " + rideEvent.duration.toString() + " minutes, Fare: $" + rideEvent.fare.toString());
        }
    } else {
        log:printError("Failed to release bike " + bikeId + ": " + result.message());
        return error("Failed to release bike: " + result.message());
    }
}


