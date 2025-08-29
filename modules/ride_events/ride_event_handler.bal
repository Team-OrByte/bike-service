import ballerina/log;
import ballerina/persist;
import ballerinax/kafka;
import bike_service.repository;
import bike_service.common;

public class RideEventHandler {
    private final repository:Client dbClient;

    public function init(repository:Client dbClient) {
        self.dbClient = dbClient;
    }

    // Main event handler for Kafka messages
    public function handleKafkaRecords(kafka:Caller caller, kafka:AnydataConsumerRecord[] records) returns error? {
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
            
            log:printInfo("RideEventHandler: Received Kafka message: " + messageString);
            
            // Parse the JSON message to RideEvent
            json messageJson = check messageString.fromJsonString();
            common:RideEvent rideEvent = check messageJson.cloneWithType(common:RideEvent);
            
            // Handle the ride event
            error? result = self.handleRideEvent(rideEvent);
            if result is error {
                log:printError("RideEventHandler: Error handling ride event: " + result.message());
                return result;
            }
        }
        
        // Commit the messages after successful processing
        check caller->commit();
        log:printInfo("RideEventHandler: Successfully committed Kafka messages");
    }

    // Handle different ride events
    public function handleRideEvent(common:RideEvent rideEvent) returns error? {
        match rideEvent.eventType {
            common:RIDE_STARTED => {
                log:printInfo("RideEventHandler: Ride started - User: " + rideEvent.userId + 
                            ", Bike: " + rideEvent.bikeId + 
                            ", Station: " + (rideEvent.startStation ?: "Unknown"));
                return self.validateBikeReservation(rideEvent.bikeId);
            }
            common:RIDE_ENDED => {
                log:printInfo("RideEventHandler: Ride ended - User: " + rideEvent.userId + 
                            ", Bike: " + rideEvent.bikeId + 
                            ", End Station: " + (rideEvent.endStation ?: "Unknown"));
                return self.releaseBikeAfterRide(rideEvent);
            }
        }
    }

    // Validate bike reservation for ride start
    public function validateBikeReservation(string bikeId) returns error? {
        repository:Bike|persist:Error bike = self.dbClient->/bikes/[bikeId]();
        
        if bike is repository:Bike {
            if !bike.isReserved {
                log:printWarn("RideEventHandler: Bike " + bikeId + " is not reserved but ride started");
                // Auto-reserve the bike
                repository:Bike _ = check self.dbClient->/bikes/[bikeId].put({
                    isReserved: true
                });
                log:printInfo("RideEventHandler: Auto-reserved bike " + bikeId + " for active ride");
            }
        } else {
            log:printError("RideEventHandler: Bike " + bikeId + " not found during ride start validation");
            return error("Bike not found");
        }
    }

    // Release bike after ride ends
    public function releaseBikeAfterRide(common:RideEvent rideEvent) returns error? {
        string bikeId = rideEvent.bikeId;
        string? endStation = rideEvent.endStation;
        
        // Prepare update data
        repository:BikeUpdate updateData = {
            isReserved: false
        };
        
        // If end station is provided, update the bike's station
        if endStation is string && endStation.trim() != "" {
            updateData.stationId = endStation;
            log:printInfo("RideEventHandler: Releasing bike " + bikeId + " at station " + endStation);
        } else {
            log:printInfo("RideEventHandler: Releasing bike " + bikeId + " (station unchanged)");
        }
        
        // Update the bike in the database
        repository:Bike|persist:Error result = self.dbClient->/bikes/[bikeId].put(updateData);
        
        if result is repository:Bike {
            log:printInfo("RideEventHandler: Successfully released bike " + bikeId + " after ride completion");
            
            // Log ride details if available
            if rideEvent.duration is int && rideEvent.fare is decimal {
                log:printInfo("RideEventHandler: Ride details - Duration: " + 
                            rideEvent.duration.toString() + " minutes, Fare: $" + 
                            rideEvent.fare.toString());
            }
        } else {
            log:printError("RideEventHandler: Failed to release bike " + bikeId + ": " + result.message());
            return error("Failed to release bike: " + result.message());
        }
    }
}
