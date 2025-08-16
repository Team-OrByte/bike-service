# Bike Service API Documentation

A comprehensive bike sharing service API built with Ballerina that provides endpoints for managing bikes, stations, and reservations.

## Base URL

```
http://localhost:8090/bike-service
```

## Authentication

All endpoints require JWT authentication with the following configuration:

- **Issuer**: Orbyte
- **Audience**: vEwzbcasJVQm1jVYHUHCjhxZ4tYa
- **Scope**: user

Include the JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## API Endpoints

### 1. Get All Bikes

Retrieve all bikes in the system.

**Endpoint:** `GET /bikes`

**Response:**

```json
{
  "statusCode": 200,
  "message": "Bikes retrieved successfully",
  "data": [
    {
      "bikeId": "123e4567-e89b-12d3-a456-426614174000",
      "addedById": "7f34d7a7-c249-44c9-add1-50e79dda8703",
      "modelName": "City Cruiser",
      "brand": "EcoBike",
      "maxSpeed": 25,
      "rangeKm": 50,
      "weightKg": 20,
      "imageUrl": "https://example.com/bike.jpg",
      "description": "Comfortable city bike",
      "createdAt": "2025-08-16T10:30:00Z",
      "updatedAt": "2025-08-16T10:30:00Z",
      "isActive": true,
      "isFlaggedForMaintenance": false,
      "isReserved": false,
      "batteryLevel": 85,
      "stationId": "station-001"
    }
  ]
}
```

### 2. Get Single Bike Details

Retrieve details for a specific bike by ID.

**Endpoint:** `GET /bike/{bikeId}`

**Parameters:**

- `bikeId` (path): UUID of the bike

**Response (Success):**

```json
{
  "statusCode": 200,
  "message": "Bike details retrieved successfully",
  "data": {
    "bikeId": "123e4567-e89b-12d3-a456-426614174000",
    "addedById": "7f34d7a7-c249-44c9-add1-50e79dda8703",
    "modelName": "City Cruiser",
    "brand": "EcoBike",
    "maxSpeed": 25,
    "rangeKm": 50,
    "weightKg": 20,
    "imageUrl": "https://example.com/bike.jpg",
    "description": "Comfortable city bike",
    "createdAt": "2025-08-16T10:30:00Z",
    "updatedAt": "2025-08-16T10:30:00Z",
    "isActive": true,
    "isFlaggedForMaintenance": false,
    "isReserved": false,
    "batteryLevel": 85,
    "stationId": "station-001"
  }
}
```

**Response (Not Found):**

```json
{
  "statusCode": 404,
  "message": "Bike not found"
}
```

### 3. Create New Bike

Add a new bike to the system.

**Endpoint:** `POST /create-bike`

**Request Body:**

```json
{
  "modelName": "City Cruiser",
  "brand": "EcoBike",
  "maxSpeed": 25,
  "rangeKm": 50,
  "weightKg": 20,
  "imageUrl": "https://example.com/bike.jpg",
  "description": "Comfortable city bike",
  "batteryLevel": 100,
  "stationId": "station-001"
}
```

**Required Fields:**

- `modelName` (string)
- `brand` (string)
- `maxSpeed` (integer)
- `rangeKm` (integer)
- `weightKg` (integer)

**Optional Fields:**

- `imageUrl` (string)
- `description` (string)
- `batteryLevel` (integer)
- `stationId` (string)

**Response (Success):**

```json
{
  "statusCode": 200,
  "message": "Bike created successfully",
  "data": ["123e4567-e89b-12d3-a456-426614174000"]
}
```

**Response (Bad Request):**

```json
{
  "statusCode": 400,
  "message": "Missing required fields for bike creation"
}
```

### 4. Update Bike

Update an existing bike's information.

**Endpoint:** `PUT /update-bike/{bikeId}`

**Parameters:**

- `bikeId` (path): UUID of the bike

**Request Body (all fields optional):**

```json
{
  "modelName": "Updated Model",
  "brand": "Updated Brand",
  "maxSpeed": 30,
  "rangeKm": 60,
  "weightKg": 22,
  "imageUrl": "https://example.com/updated-bike.jpg",
  "description": "Updated description",
  "isActive": true,
  "isFlaggedForMaintenance": false,
  "isReserved": false,
  "batteryLevel": 90,
  "stationId": "station-002"
}
```

**Response:**

```json
{
  "statusCode": 200,
  "message": "Bike updated successfully",
  "data": {
    "bikeId": "123e4567-e89b-12d3-a456-426614174000",
    "addedById": "7f34d7a7-c249-44c9-add1-50e79dda8703",
    "modelName": "Updated Model",
    "brand": "Updated Brand",
    "maxSpeed": 30,
    "rangeKm": 60,
    "weightKg": 22,
    "imageUrl": "https://example.com/updated-bike.jpg",
    "description": "Updated description",
    "createdAt": "2025-08-16T10:30:00Z",
    "updatedAt": "2025-08-16T11:45:00Z",
    "isActive": true,
    "isFlaggedForMaintenance": false,
    "isReserved": false,
    "batteryLevel": 90,
    "stationId": "station-002"
  }
}
```

### 5. Delete Bike (Hard Delete)

Permanently delete a bike from the system.

**Endpoint:** `DELETE /delete-bike/{bikeId}`

**Parameters:**

- `bikeId` (path): UUID of the bike

**Response:**

```json
{
  "statusCode": 200,
  "message": "Bike deleted successfully",
  "data": {
    "bikeId": "123e4567-e89b-12d3-a456-426614174000",
    "addedById": "7f34d7a7-c249-44c9-add1-50e79dda8703",
    "modelName": "City Cruiser",
    "brand": "EcoBike",
    "maxSpeed": 25,
    "rangeKm": 50,
    "weightKg": 20,
    "imageUrl": "https://example.com/bike.jpg",
    "description": "Comfortable city bike",
    "createdAt": "2025-08-16T10:30:00Z",
    "updatedAt": "2025-08-16T10:30:00Z",
    "isActive": true,
    "isFlaggedForMaintenance": false,
    "isReserved": false,
    "batteryLevel": 85,
    "stationId": "station-001"
  }
}
```

### 6. Soft Delete Bike

Mark a bike as inactive without permanently deleting it.

**Endpoint:** `PUT /soft-delete-bike/{bikeId}`

**Parameters:**

- `bikeId` (path): UUID of the bike

**Response:**

```json
{
  "statusCode": 200,
  "message": "Bike soft deleted successfully",
  "data": {
    "bikeId": "123e4567-e89b-12d3-a456-426614174000",
    "isActive": false,
    "updatedAt": "2025-08-16T11:45:00Z"
  }
}
```

### 7. Restore Bike

Restore a soft-deleted bike by marking it as active.

**Endpoint:** `PUT /restore-bike/{bikeId}`

**Parameters:**

- `bikeId` (path): UUID of the bike

**Response:**

```json
{
  "statusCode": 200,
  "message": "Bike restored successfully",
  "data": {
    "bikeId": "123e4567-e89b-12d3-a456-426614174000",
    "isActive": true,
    "updatedAt": "2025-08-16T11:50:00Z"
  }
}
```

### 8. Get Active Bikes

Retrieve all active bikes with pagination.

**Endpoint:** `GET /active-bikes`

**Query Parameters:**

- `pageSize` (optional, default: 50): Number of bikes per page
- `pageOffset` (optional, default: 0): Number of bikes to skip

**Example:** `GET /active-bikes?pageSize=20&pageOffset=40`

**Response:**

```json
{
  "statusCode": 200,
  "message": "Successfully retrieved bike details",
  "data": [
    {
      "bikeId": "123e4567-e89b-12d3-a456-426614174000",
      "addedById": "7f34d7a7-c249-44c9-add1-50e79dda8703",
      "modelName": "City Cruiser",
      "brand": "EcoBike",
      "maxSpeed": 25,
      "rangeKm": 50,
      "weightKg": 20,
      "imageUrl": "https://example.com/bike.jpg",
      "description": "Comfortable city bike",
      "createdAt": "2025-08-16T10:30:00Z",
      "updatedAt": "2025-08-16T10:30:00Z",
      "isActive": true,
      "isFlaggedForMaintenance": false,
      "isReserved": false,
      "batteryLevel": 85,
      "stationId": "station-001"
    }
  ]
}
```

### 9. Reserve Bike

Reserve a bike for use.

**Endpoint:** `PUT /reserve-bike/{bikeId}`

**Parameters:**

- `bikeId` (path): UUID of the bike

**Response (Success):**

```json
{
  "statusCode": 200,
  "message": "Bike reserved successfully",
  "data": {
    "bikeId": "123e4567-e89b-12d3-a456-426614174000",
    "isReserved": true,
    "updatedAt": "2025-08-16T12:00:00Z"
  }
}
```

**Response (Already Reserved):**

```json
{
  "statusCode": 400,
  "message": "Bike is already reserved"
}
```

**Response (Bike Unavailable):**

```json
{
  "statusCode": 400,
  "message": "Bike is deleted or under maintenance"
}
```

### 10. Release Bike

Release a reserved bike.

**Endpoint:** `PUT /release-bike/{bikeId}`

**Parameters:**

- `bikeId` (path): UUID of the bike

**Response:**

```json
{
  "statusCode": 200,
  "message": "Bike released successfully",
  "data": {
    "bikeId": "123e4567-e89b-12d3-a456-426614174000",
    "isReserved": false,
    "updatedAt": "2025-08-16T12:30:00Z"
  }
}
```

### 11. Get Unreserved Bikes

Retrieve all unreserved bikes with pagination.

**Endpoint:** `GET /unreserved-bikes`

**Query Parameters:**

- `pageSize` (optional, default: 50): Number of bikes per page
- `pageOffset` (optional, default: 0): Number of bikes to skip

**Response:**

```json
{
  "statusCode": 200,
  "message": "Successfully retrieved bike details",
  "data": [
    {
      "bikeId": "123e4567-e89b-12d3-a456-426614174000",
      "addedById": "7f34d7a7-c249-44c9-add1-50e79dda8703",
      "modelName": "City Cruiser",
      "brand": "EcoBike",
      "maxSpeed": 25,
      "rangeKm": 50,
      "weightKg": 20,
      "imageUrl": "https://example.com/bike.jpg",
      "description": "Comfortable city bike",
      "createdAt": "2025-08-16T10:30:00Z",
      "updatedAt": "2025-08-16T10:30:00Z",
      "isActive": true,
      "isFlaggedForMaintenance": false,
      "isReserved": false,
      "batteryLevel": 85,
      "stationId": "station-001"
    }
  ]
}
```

### 12. Get All Stations

Retrieve all bike stations.

**Endpoint:** `GET /stations`

**Response:**

```json
{
  "statusCode": 200,
  "message": "Successfully retrieved station details",
  "data": [
    {
      "stationId": "station-001",
      "name": "Central Park Station",
      "latitude": "40.7829",
      "longitude": "-73.9654",
      "address": "Central Park, New York, NY",
      "capacity": 20,
      "availableSlots": 5,
      "isActive": true
    }
  ]
}
```

### 13. Get Nearby Stations

Retrieve stations within a specified radius of given coordinates.

**Endpoint:** `GET /nearby-stations`

**Query Parameters:**

- `latitude` (required): Latitude coordinate
- `longitude` (required): Longitude coordinate
- `radius` (required): Search radius in kilometers

**Example:** `GET /nearby-stations?latitude=40.7829&longitude=-73.9654&radius=5`

**Response:**

```json
{
  "statusCode": 200,
  "message": "Successfully retrieved station details",
  "data": [
    {
      "stationId": "station-001",
      "name": "Central Park Station",
      "latitude": "40.7829",
      "longitude": "-73.9654",
      "address": "Central Park, New York, NY",
      "capacity": 20,
      "availableSlots": 5,
      "isActive": true
    }
  ]
}
```

### 14. Get Bikes by Station

Retrieve all bikes at a specific station with pagination.

**Endpoint:** `GET /bikes-by-station/{stationId}`

**Parameters:**

- `stationId` (path): ID of the station

**Query Parameters:**

- `pageSize` (optional, default: 50): Number of bikes per page
- `pageOffset` (optional, default: 0): Number of bikes to skip

**Example:** `GET /bikes-by-station/station-001?pageSize=10&pageOffset=0`

**Response:**

```json
{
  "statusCode": 200,
  "message": "Successfully retrieved bike details",
  "data": [
    {
      "bikeId": "123e4567-e89b-12d3-a456-426614174000",
      "addedById": "7f34d7a7-c249-44c9-add1-50e79dda8703",
      "modelName": "City Cruiser",
      "brand": "EcoBike",
      "maxSpeed": 25,
      "rangeKm": 50,
      "weightKg": 20,
      "imageUrl": "https://example.com/bike.jpg",
      "description": "Comfortable city bike",
      "createdAt": "2025-08-16T10:30:00Z",
      "updatedAt": "2025-08-16T10:30:00Z",
      "isActive": true,
      "isFlaggedForMaintenance": false,
      "isReserved": false,
      "batteryLevel": 85,
      "stationId": "station-001"
    }
  ]
}
```

### 15. Update Bike Station

Update the station location of a bike.

**Endpoint:** `PUT /update-bike-station/{bikeId}`

**Parameters:**

- `bikeId` (path): UUID of the bike

**Query Parameters:**

- `stationId` (required): ID of the new station

**Example:** `PUT /update-bike-station/123e4567-e89b-12d3-a456-426614174000?stationId=station-002`

**Response:**

```json
{
  "statusCode": 200,
  "message": "Successfully updated bike station",
  "data": {
    "bikeId": "123e4567-e89b-12d3-a456-426614174000",
    "stationId": "station-002",
    "updatedAt": "2025-08-16T13:00:00Z"
  }
}
```

## Error Responses

### Common Error Codes

- **400 Bad Request**: Invalid request data or business logic violation
- **401 Unauthorized**: Missing or invalid JWT token
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server-side error

### Error Response Format

```json
{
  "statusCode": 400,
  "message": "Error description"
}
```

## Data Models

### Bike Object

```json
{
  "bikeId": "string (UUID)",
  "addedById": "string (UUID)",
  "modelName": "string",
  "brand": "string",
  "maxSpeed": "integer (km/h)",
  "rangeKm": "integer (km)",
  "weightKg": "integer (kg)",
  "imageUrl": "string (optional)",
  "description": "string (optional)",
  "createdAt": "string (ISO 8601 datetime)",
  "updatedAt": "string (ISO 8601 datetime)",
  "isActive": "boolean",
  "isFlaggedForMaintenance": "boolean",
  "isReserved": "boolean",
  "batteryLevel": "integer (0-100)",
  "stationId": "string"
}
```

### Station Object

```json
{
  "stationId": "string",
  "name": "string",
  "latitude": "string",
  "longitude": "string",
  "address": "string",
  "capacity": "integer",
  "availableSlots": "integer",
  "isActive": "boolean"
}
```

## Usage Examples

### JavaScript/Fetch API

```javascript
// Get all bikes
const response = await fetch('http://localhost:8090/bike-service/bikes', {
  headers: {
    Authorization: 'Bearer YOUR_JWT_TOKEN',
  },
});
const data = await response.json();

// Create a new bike
const newBike = {
  modelName: 'City Cruiser',
  brand: 'EcoBike',
  maxSpeed: 25,
  rangeKm: 50,
  weightKg: 20,
  batteryLevel: 100,
  stationId: 'station-001',
};

const createResponse = await fetch(
  'http://localhost:8090/bike-service/create-bike',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: 'Bearer YOUR_JWT_TOKEN',
    },
    body: JSON.stringify(newBike),
  }
);
const createData = await createResponse.json();

// Reserve a bike
const reserveResponse = await fetch(
  'http://localhost:8090/bike-service/reserve-bike/123e4567-e89b-12d3-a456-426614174000',
  {
    method: 'PUT',
    headers: {
      Authorization: 'Bearer YOUR_JWT_TOKEN',
    },
  }
);
const reserveData = await reserveResponse.json();
```

### cURL Examples

```bash
# Get all bikes
curl -X GET "http://localhost:8090/bike-service/bikes" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Create a new bike
curl -X POST "http://localhost:8090/bike-service/create-bike" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "modelName": "City Cruiser",
    "brand": "EcoBike",
    "maxSpeed": 25,
    "rangeKm": 50,
    "weightKg": 20,
    "batteryLevel": 100,
    "stationId": "station-001"
  }'

# Reserve a bike
curl -X PUT "http://localhost:8090/bike-service/reserve-bike/123e4567-e89b-12d3-a456-426614174000" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Notes for Frontend Developers

1. **Authentication**: All endpoints require a valid JWT token. Make sure to include it in the Authorization header.

2. **Error Handling**: Always check the `statusCode` field in responses to handle errors appropriately.

3. **Pagination**: For endpoints that support pagination, use `pageSize` and `pageOffset` query parameters to implement pagination in your UI.

4. **UUIDs**: All bike and station IDs are UUIDs. Make sure your frontend can handle UUID strings properly.

5. **Date Handling**: All timestamps are in ISO 8601 format. Use appropriate date parsing libraries in your frontend framework.

6. **Optional Fields**: When creating or updating bikes, some fields are optional. Check the documentation for each endpoint to see which fields are required.

7. **Business Logic**:
   - Bikes cannot be reserved if they are inactive or already reserved
   - Soft-deleted bikes can be restored
   - Hard-deleted bikes are permanently removed from the system
