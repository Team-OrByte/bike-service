import ballerina/http;
import bike_service.repository;
import ballerinax/kafka;
import bike_service.common;
import bike_service.auth;
import bike_service.bike_service;
import bike_service.station_service;
import bike_service.ride_events;

configurable string pub_key = ?;
configurable string kafkaBootstrapServers = ?;

// Initialize database client and services
final repository:Client sClient = check new();
final bike_service:BikeService bikeService = new(sClient);
final station_service:StationService stationService = new(sClient);
final ride_events:RideEventHandler rideEventHandler = new(sClient);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["POST", "PUT", "GET", "POST", "OPTIONS"],
        allowHeaders: ["Content-Type", "Access-Control-Allow-Origin", "X-Service-Name"]
    }
}
service /bike\-service on new http:Listener(8090) {

    // Bike endpoints
    resource function get bikes() returns common:Response|error {
        return bikeService.getAllBikes();
    }

    resource function get bike/[string bikeId]() returns common:Response {
        return bikeService.getBikeById(bikeId);
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
    resource function post create\-bike(@http:Header string Authorization, @http:Payload repository:BikeOptionalized bike) returns common:Response|error {
        common:Claims claims = check auth:extractClaims(Authorization);
        string userId = check auth:getUserIdFromClaims(claims);
        return bikeService.createBike(bike, userId);
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
    resource function put update\-bike/[string bikeId](@http:Payload repository:BikeUpdate bikeUpdate) returns common:Response|error {
        return bikeService.updateBike(bikeId, bikeUpdate);
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
    resource function delete delete\-bike/[string bikeId]() returns common:Response|error {
        return bikeService.deleteBike(bikeId);
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
    resource function put soft\-delete\-bike/[string bikeId]() returns common:Response|error {
        return bikeService.softDeleteBike(bikeId);
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
    resource function put restore\-bike/[string bikeId]() returns common:Response|error {
        return bikeService.restoreBike(bikeId);
    }

    resource function get active\-bikes(int pageSize = 50, int pageOffset = 0) returns common:Response|error {
        return bikeService.getActiveBikes(pageSize, pageOffset);
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
    resource function put reserve\-bike/[string bikeId]() returns common:Response|error {
        return bikeService.reserveBike(bikeId);
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
    resource function put release\-bike/[string bikeId](string endLocation) returns common:Response|error {
        return bikeService.releaseBike(bikeId, endLocation);
    }

    resource function get unreserved\-bikes(int pageSize = 50, int pageOffset = 0) returns common:Response|error {
        return bikeService.getUnreservedBikes(pageSize, pageOffset);
    }

    // Station endpoints
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
    resource function post add\-station(@http:Payload repository:StationOptionalized station) returns common:Response|error {
        return stationService.addStation(station);
    }

    resource function get stations() returns common:Response|error {
        return stationService.getAllStations();
    }

    resource function get nearby\-stations(string latitude, string longitude, int radius) returns common:Response|error {
        return stationService.getNearbyStations(latitude, longitude, radius);
    }

    resource function get bikes\-by\-station/[string stationId](int pageSize = 50, int pageOffset = 0) returns common:Response|error {
        return bikeService.getBikesByStation(stationId, pageSize, pageOffset);
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
    resource function put update\-bike\-station/[string bikeId](string stationId) returns common:Response|error {
        return bikeService.updateBikeStation(bikeId, stationId);
    }
}

// Kafka configuration and listener
kafka:ConsumerConfiguration consumerConfiguration = {
    groupId: "ride-events",
    topics: ["ride-events"],
    pollingInterval: 1,
    autoCommit: false
};

listener kafka:Listener kafkaListener = new (kafkaBootstrapServers, consumerConfiguration);

service on kafkaListener {
    remote function onConsumerRecord(kafka:Caller caller, kafka:AnydataConsumerRecord[] records) returns error? {
        return rideEventHandler.handleKafkaRecords(caller, records);
    }
}
