import ballerina/log;
import ballerina/persist;
import ballerina/uuid;
import ballerina/time;
import ballerina/sql;
import ballerina/http;
import bike_service.repository;
import bike_service.common;

public class BikeService {
    private final repository:Client dbClient;

    public function init(repository:Client dbClient) {
        self.dbClient = dbClient;
    }

    // Get all bikes
    public function getAllBikes() returns common:Response|error {
        log:printInfo("BikeService: Getting all bikes");
        
        stream<repository:Bike, persist:Error?> bikes = self.dbClient->/bikes;
        repository:Bike[] bikeList = [];

        check bikes.forEach(function(repository:Bike bike) {
            bikeList.push(bike);
        });

        log:printInfo("BikeService: Successfully retrieved bike details");
        return common:createSuccessResponse(http:STATUS_OK, "Bikes retrieved successfully", bikeList);
    }

    // Get bike by ID
    public function getBikeById(string bikeId) returns common:Response {
        log:printInfo("BikeService: Getting bike with ID: " + bikeId);

        repository:Bike|persist:Error bike = self.dbClient->/bikes/[bikeId]();

        if bike is repository:Bike {
            log:printInfo("BikeService: Successfully retrieved bike details");
            return common:createSuccessResponse(http:STATUS_OK, "Bike details retrieved successfully", bike);
        } else {
            log:printWarn("BikeService: Bike not found with ID: " + bikeId);
            return common:createErrorResponse(http:STATUS_NOT_FOUND, "Bike not found");
        }
    }

    // Create new bike
    public function createBike(repository:BikeOptionalized bikeData, string addedById) returns common:Response|error {
        log:printInfo("BikeService: Creating new bike");

        // Validate required fields
        error? validationResult = self.validateBikeData(bikeData);
        if validationResult is error {
            log:printError("BikeService: Validation failed: " + validationResult.message());
            return common:createErrorResponse(http:STATUS_BAD_REQUEST, validationResult.message());
        }

        string generatedBikeId = uuid:createType1AsString();
        time:Civil currentTime = time:utcToCivil(time:utcNow());

        repository:Bike newBike = {
            bikeId: generatedBikeId,
            addedById: addedById,
            modelName: <string>bikeData.modelName,
            brand: <string>bikeData.brand,
            maxSpeed: <int>bikeData.maxSpeed,
            rangeKm: <int>bikeData.rangeKm,
            weightKg: <int>bikeData.weightKg,
            imageUrl: <string>bikeData.imageUrl,
            description: <string>bikeData.description,
            createdAt: currentTime,
            updatedAt: currentTime,
            isActive: true,
            isFlaggedForMaintenance: false,
            isReserved: false,
            batteryLevel: <int>bikeData.batteryLevel,
            stationId: <string>bikeData.stationId
        };

        string[] result = check self.dbClient->/bikes.post([newBike]);

        log:printInfo("BikeService: Successfully created bike with ID: " + result[0]);
        return common:createSuccessResponse(http:STATUS_OK, "Bike created successfully", result);
    }

    // Update bike
    public function updateBike(string bikeId, repository:BikeUpdate bikeUpdate) returns common:Response|error {
        log:printInfo("BikeService: Updating bike with ID: " + bikeId);

        time:Civil currentTime = time:utcToCivil(time:utcNow());
        bikeUpdate.updatedAt = currentTime;

        repository:Bike result = check self.dbClient->/bikes/[bikeId].put(bikeUpdate);

        log:printInfo("BikeService: Successfully updated bike with ID: " + bikeId);
        return common:createSuccessResponse(http:STATUS_OK, "Bike updated successfully", result);
    }

    // Delete bike
    public function deleteBike(string bikeId) returns common:Response|error {
        log:printInfo("BikeService: Deleting bike with ID: " + bikeId);

        repository:Bike result = check self.dbClient->/bikes/[bikeId].delete();

        log:printInfo("BikeService: Successfully deleted bike with ID: " + bikeId);
        return common:createSuccessResponse(http:STATUS_OK, "Bike deleted successfully", result);
    }

    // Soft delete bike
    public function softDeleteBike(string bikeId) returns common:Response|error {
        log:printInfo("BikeService: Soft deleting bike with ID: " + bikeId);

        repository:Bike result = check self.dbClient->/bikes/[bikeId].put({
            isActive: false
        });

        log:printInfo("BikeService: Successfully soft deleted bike with ID: " + bikeId);
        return common:createSuccessResponse(http:STATUS_OK, "Bike soft deleted successfully", result);
    }

    // Restore bike
    public function restoreBike(string bikeId) returns common:Response|error {
        log:printInfo("BikeService: Restoring bike with ID: " + bikeId);

        repository:Bike result = check self.dbClient->/bikes/[bikeId].put({
            isActive: true
        });

        log:printInfo("BikeService: Successfully restored bike with ID: " + bikeId);
        return common:createSuccessResponse(http:STATUS_OK, "Bike restored successfully", result);
    }

    // Get active bikes with pagination
    public function getActiveBikes(int pageSize = 50, int pageOffset = 0) returns common:Response|error {
        log:printInfo("BikeService: Getting active bikes");

        sql:ParameterizedQuery whereClause = `"isActive" = true`;
        sql:ParameterizedQuery orderByClause = `"createdAt" `;
        sql:ParameterizedQuery limitClause = `${pageSize} OFFSET ${pageOffset}`;

        stream<repository:BikeOptionalized, persist:Error?> result = self.dbClient->/bikes(
            <repository:BikeTargetType>repository:BikeOptionalized,
            whereClause,
            orderByClause,
            limitClause
        );

        repository:BikeOptionalized[] bikeList = [];
        check result.forEach(function(repository:BikeOptionalized bike) {
            bikeList.push(bike);
        });

        log:printInfo("BikeService: Successfully retrieved active bikes");
        return common:createSuccessResponse(http:STATUS_OK, "Successfully retrieved bike details", bikeList);
    }

    // Reserve bike
    public function reserveBike(string bikeId) returns common:Response|error {
        log:printInfo("BikeService: Reserving bike with ID: " + bikeId);

        // Check bike availability
        common:BikeStatus|persist:Error availabilityCheck = check self.dbClient->/bikes/[bikeId]();

        if availabilityCheck is common:BikeStatus {
            if !availabilityCheck.isActive {
                log:printError("BikeService: Failed to reserve bike - inactive: " + bikeId);
                return common:createErrorResponse(http:STATUS_BAD_REQUEST, "Bike is deleted or under maintenance");
            }
            if availabilityCheck.isReserved {
                log:printError("BikeService: Failed to reserve bike - already reserved: " + bikeId);
                return common:createErrorResponse(http:STATUS_BAD_REQUEST, "Bike is already reserved");
            }
        }

        repository:Bike result = check self.dbClient->/bikes/[bikeId].put({
            isReserved: true
        });

        log:printInfo("BikeService: Successfully reserved bike with ID: " + bikeId);
        return common:createSuccessResponse(http:STATUS_OK, "Bike reserved successfully", result);
    }

    // Release bike
    public function releaseBike(string bikeId, string endLocation) returns common:Response|error {
        log:printInfo("BikeService: Releasing bike with ID: " + bikeId);

        repository:Bike result = check self.dbClient->/bikes/[bikeId].put({
            isReserved: false,
            stationId: endLocation
        });

        log:printInfo("BikeService: Successfully released bike with ID: " + bikeId);
        return common:createSuccessResponse(http:STATUS_OK, "Bike released successfully", result);
    }

    // Get unreserved bikes
    public function getUnreservedBikes(int pageSize = 50, int pageOffset = 0) returns common:Response|error {
        log:printInfo("BikeService: Getting unreserved bikes");

        sql:ParameterizedQuery whereClause = `"isReserved" = false`;
        sql:ParameterizedQuery orderByClause = `"createdAt" `;
        sql:ParameterizedQuery limitClause = `${pageSize} OFFSET ${pageOffset}`;

        stream<repository:BikeOptionalized, persist:Error?> result = self.dbClient->/bikes(
            <repository:BikeTargetType>repository:BikeOptionalized,
            whereClause,
            orderByClause,
            limitClause
        );

        repository:BikeOptionalized[] bikeList = [];
        check result.forEach(function(repository:BikeOptionalized bike) {
            bikeList.push(bike);
        });

        return common:createSuccessResponse(http:STATUS_OK, "Successfully retrieved bike details", bikeList);
    }

    // Get bikes by station
    public function getBikesByStation(string stationId, int pageSize = 50, int pageOffset = 0) returns common:Response|error {
        log:printInfo("BikeService: Getting bikes by station: " + stationId);
        
        sql:ParameterizedQuery whereClause = `"stationId" = ${stationId} and "isActive" = true and "isReserved" = false`;
        sql:ParameterizedQuery orderByClause = `"createdAt" `;
        sql:ParameterizedQuery limitClause = `${pageSize} OFFSET ${pageOffset}`;
        
        stream<repository:BikeOptionalized, persist:Error?> result = self.dbClient->/bikes(
            <repository:BikeTargetType>repository:BikeOptionalized,
            whereClause,
            orderByClause,
            limitClause
        );
        
        repository:BikeOptionalized[] bikeList = [];
        check result.forEach(function(repository:BikeOptionalized bike) {
            bikeList.push(bike);
        });
        
        return common:createSuccessResponse(http:STATUS_OK, "Successfully retrieved bike details", bikeList);
    }

    // Update bike station
    public function updateBikeStation(string bikeId, string stationId) returns common:Response|error {
        log:printInfo("BikeService: Updating bike station for ID: " + bikeId);

        repository:Bike result = check self.dbClient->/bikes/[bikeId].put({
            stationId: stationId
        });
        
        return common:createSuccessResponse(http:STATUS_OK, "Successfully updated bike station", result);
    }

    // Validate bike data
    private function validateBikeData(repository:BikeOptionalized bike) returns error? {
        check common:validateRequired(bike.modelName, "modelName");
        check common:validateRequired(bike.brand, "brand");
        check common:validateRequired(bike.maxSpeed, "maxSpeed");
        check common:validateRequired(bike.rangeKm, "rangeKm");
        check common:validateRequired(bike.weightKg, "weightKg");
    }
}
