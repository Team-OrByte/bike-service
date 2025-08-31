# Bike Service

A comprehensive bike-sharing service built with Ballerina that provides bike and station management functionality with real-time event processing capabilities. This service enables users to discover, reserve, and manage electric bikes across multiple stations while providing administrative controls for fleet management.

## Build & Deployment Status

[![CI](https://github.com/Team-OrByte/bike-service/actions/workflows/automation.yaml/badge.svg)](https://github.com/Team-OrByte/bike-service/actions/workflows/automation.yaml)
[![Docker Image](https://img.shields.io/badge/docker-thetharz%2Forbyte__bike__service-blue)](https://hub.docker.com/r/thetharz/orbyte_bike_service)

## How Ballerina is Used

This project leverages Ballerina's cloud-native capabilities extensively:

- **HTTP Services**: RESTful API endpoints for bike and station management using Ballerina's built-in HTTP service capabilities
- **Data Persistence**: Integration with PostgreSQL using Ballerina's `persist` library for data access layer generation
- **Event-Driven Architecture**: Apache Kafka integration for real-time ride event processing using `ballerinax/kafka`
- **JWT Authentication**: Secure API endpoints using Ballerina's built-in JWT validation with role-based access control
- **Configuration Management**: Environment-specific configurations using Ballerina's configurable variables
- **Observability**: Built-in logging, tracing, and monitoring capabilities
- **Microservices Architecture**: Modular service design with separate modules for bikes, stations, authentication, and events

## Configuration Example

Create a `Config.toml` file in the project root with the following structure:

```toml
# JWT Public Key Path
pub_key = "./public.crt"

# Kafka Configuration
kafkaBootstrapServers = "kafka:9092"

# Logging Configuration
[ballerina.log]
level = "DEBUG"
format = "json"

# Database Configuration
[bike_service.repository]
host = "bike_service_db"  # Use "localhost" for local development
port = 5432
user = "bike_service_user"
password = "your_database_password"
database = "bikes_db"
```

For local development, update the host values:

```toml
[bike_service.repository]
host = "localhost"
```

## API Endpoints

### Bike Management

#### Get All Bikes

- **Method**: `GET`
- **Path**: `/bike-service/bikes`
- **Auth**: None
- **Response**:

```json
{
  "statusCode": 200,
  "message": "Bikes retrieved successfully",
  "data": [
    {
      "bikeId": "string",
      "stationId": "string",
      "modelName": "string",
      "brand": "string",
      "maxSpeed": 25,
      "rangeKm": 50,
      "batteryLevel": 85,
      "isActive": true,
      "isFlaggedForMaintenance": false,
      "isReserved": false
    }
  ]
}
```

#### Get Bike by ID

- **Method**: `GET`
- **Path**: `/bike-service/bike/{bikeId}`
- **Auth**: None
- **Response**: Single bike object with same structure as above

#### Create Bike

- **Method**: `POST`
- **Path**: `/bike-service/create-bike`
- **Auth**: Admin JWT required
- **Request Body**:

```json
{
  "stationId": "string",
  "modelName": "string",
  "brand": "string",
  "maxSpeed": 25,
  "rangeKm": 50,
  "weightKg": 20,
  "imageUrl": "string",
  "description": "string",
  "batteryLevel": 100
}
```

#### Update Bike

- **Method**: `PUT`
- **Path**: `/bike-service/update-bike/{bikeId}`
- **Auth**: Admin JWT required
- **Request Body**: Partial bike update object

#### Delete Bike

- **Method**: `DELETE`
- **Path**: `/bike-service/delete-bike/{bikeId}`
- **Auth**: Admin JWT required

#### Soft Delete Bike

- **Method**: `PUT`
- **Path**: `/bike-service/soft-delete-bike/{bikeId}`
- **Auth**: Admin JWT required

#### Restore Bike

- **Method**: `PUT`
- **Path**: `/bike-service/restore-bike/{bikeId}`
- **Auth**: Admin JWT required

#### Get Active Bikes

- **Method**: `GET`
- **Path**: `/bike-service/active-bikes?pageSize=50&pageOffset=0`
- **Auth**: None
- **Query Parameters**:
  - `pageSize` (optional): Number of bikes per page (default: 50)
  - `pageOffset` (optional): Page offset for pagination (default: 0)

#### Reserve Bike

- **Method**: `PUT`
- **Path**: `/bike-service/reserve-bike/{bikeId}`
- **Auth**: User JWT required

#### Release Bike

- **Method**: `PUT`
- **Path**: `/bike-service/release-bike/{bikeId}?endLocation={location}`
- **Auth**: User JWT required
- **Query Parameters**:
  - `endLocation`: Location where bike is returned

#### Get Unreserved Bikes

- **Method**: `GET`
- **Path**: `/bike-service/unreserved-bikes?pageSize=50&pageOffset=0`
- **Auth**: None

#### Update Bike Station

- **Method**: `PUT`
- **Path**: `/bike-service/update-bike-station/{bikeId}?stationId={stationId}`
- **Auth**: User JWT required

### Station Management

#### Add Station

- **Method**: `POST`
- **Path**: `/bike-service/add-station`
- **Auth**: Admin JWT required
- **Request Body**:

```json
{
  "name": "string",
  "address": "string",
  "description": "string",
  "imageUrl": "string",
  "phone": "string",
  "latitude": "string",
  "longitude": "string",
  "operatingHours": "string"
}
```

#### Get All Stations

- **Method**: `GET`
- **Path**: `/bike-service/stations`
- **Auth**: None
- **Response**:

```json
{
  "statusCode": 200,
  "message": "Stations retrieved successfully",
  "data": [
    {
      "stationId": "string",
      "name": "string",
      "address": "string",
      "latitude": "string",
      "longitude": "string",
      "operatingHours": "string"
    }
  ]
}
```

#### Get Nearby Stations

- **Method**: `GET`
- **Path**: `/bike-service/nearby-stations?latitude={lat}&longitude={lng}&radius={radius}`
- **Auth**: None
- **Query Parameters**:
  - `latitude`: Latitude coordinate
  - `longitude`: Longitude coordinate
  - `radius`: Search radius in meters

#### Get Bikes by Station

- **Method**: `GET`
- **Path**: `/bike-service/bikes-by-station/{stationId}?pageSize=50&pageOffset=0`
- **Auth**: None

## Event Processing

The service integrates with Apache Kafka for processing ride events:

- **Topic**: `ride-events`
- **Event Types**: `RIDE_STARTED`, `RIDE_ENDED`
- **Consumer Group**: `ride-events`

Events are automatically processed to update bike statuses and locations in real-time.

## Authentication

The API uses JWT-based authentication with two roles:

- **admin**: Full access to bike and station management
- **user**: Access to bike reservations and basic operations

JWT tokens must include:

- `issuer`: "Orbyte"
- `audience`: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa"
- `scp` (scope): "admin" or "user"

## License

This project does not specify a license. Please contact the repository owners for licensing information.
