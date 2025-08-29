import ballerina/log;
import ballerina/persist;
import ballerina/uuid;
import ballerina/time;
import ballerina/http;
import bike_service.repository;
import bike_service.common;

public class StationService {
    private final repository:Client dbClient;

    public function init(repository:Client dbClient) {
        self.dbClient = dbClient;
    }

    // Add new station
    public function addStation(repository:StationOptionalized stationData) returns common:Response|error {
        log:printInfo("StationService: Adding new station");
        
        // Validate required fields
        error? validationResult = self.validateStationData(stationData);
        if validationResult is error {
            log:printError("StationService: Validation failed: " + validationResult.message());
            return common:createErrorResponse(http:STATUS_BAD_REQUEST, validationResult.message());
        }

        string generatedStationId = uuid:createType1AsString();
        time:Civil currentTime = time:utcToCivil(time:utcNow());

        repository:Station newStation = {
            stationId: generatedStationId,
            name: <string>stationData.name,
            address: <string>stationData.address,
            description: <string>stationData.description,
            createdAt: currentTime,
            updatedAt: currentTime,
            imageUrl: <string>stationData.imageUrl,
            phone: <string>stationData.phone,
            latitude: <string>stationData.latitude,
            longitude: <string>stationData.longitude,
            operatingHours: <string>stationData.operatingHours
        };

        string[] result = check self.dbClient->/stations.post([newStation]);

        log:printInfo("StationService: Successfully added station with ID: " + result[0]);
        return common:createSuccessResponse(http:STATUS_CREATED, "Successfully added station", result);
    }

    // Get all stations
    public function getAllStations() returns common:Response|error {
        log:printInfo("StationService: Getting all stations");
        
        stream<repository:Station, persist:Error?> result = self.dbClient->/stations();
        repository:Station[] stationList = [];
        
        check result.forEach(function(repository:Station station) {
            stationList.push(station);
        });
        
        log:printInfo("StationService: Successfully retrieved station details");
        return common:createSuccessResponse(http:STATUS_OK, "Successfully retrieved station details", stationList);
    }

    // Get nearby stations (placeholder implementation)
    public function getNearbyStations(string latitude, string longitude, int radius) returns common:Response|error {
        log:printInfo("StationService: Getting nearby stations");
        
        // TODO: Implement actual distance calculation logic
        // For now, returning all stations as a placeholder
        stream<repository:Station, persist:Error?> result = self.dbClient->/stations();
        repository:Station[] stationList = [];
        
        check result.forEach(function(repository:Station station) {
            // TODO: Add distance filtering logic here
            stationList.push(station);
        });
        
        log:printInfo("StationService: Successfully retrieved nearby stations");
        return common:createSuccessResponse(http:STATUS_OK, "Successfully retrieved station details", stationList);
    }

    // Validate station data
    private function validateStationData(repository:StationOptionalized station) returns error? {
        check common:validateRequired(station.name, "name");
        check common:validateRequired(station.address, "address");
        check common:validateRequired(station.latitude, "latitude");
        check common:validateRequired(station.longitude, "longitude");
    }
}
