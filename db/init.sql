-- -- Enable pgcrypto for UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =======================
-- Create station table
-- =======================
CREATE TABLE IF NOT EXISTS station (
    "stationId" TEXT PRIMARY KEY,
    "name" VARCHAR(100) NOT NULL,
    "address" TEXT NOT NULL,
    "description" TEXT,
    "imageUrl" TEXT,
    "phone" VARCHAR(50),
    "latitude" VARCHAR(50),
    "longitude" VARCHAR(50),
    "operatingHours" VARCHAR(100),
    "createdAt" TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP NOT NULL
);

-- =======================
-- Create bike table with foreign key to station
-- =======================
CREATE TABLE IF NOT EXISTS bike (
    "bikeId" TEXT PRIMARY KEY,
    "addedById" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL,
    "isFlaggedForMaintenance" BOOLEAN NOT NULL,
    "modelName" VARCHAR(100),
    "brand" VARCHAR(100),
    "maxSpeed" INTEGER,
    "rangeKm" INTEGER,
    "weightKg" INTEGER,
    "imageUrl" TEXT,
    "description" TEXT,
    "isReserved" BOOLEAN NOT NULL,
    "createdAt" TIMESTAMP,
    "updatedAt" TIMESTAMP,
    "batteryLevel" INTEGER NOT NULL,
    "stationId" TEXT NOT NULL,
    CONSTRAINT fk_station FOREIGN KEY ("stationId") REFERENCES station("stationId") ON DELETE CASCADE
);

-- =======================
-- Insert station data
-- =======================
INSERT INTO station (
    "stationId", "name", "address", "description", "imageUrl", "phone", "latitude", "longitude", "operatingHours", "createdAt", "updatedAt"
) VALUES
('station-1', 'Central Station', '123 Main St', 'Main hub for bikes', 'https://example.com/images/station1.png', '+1234567890', '40.7128N', '74.0060W', '06:00-22:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('station-2', 'East Side Station', '456 East Ave', 'Located in the east district', 'https://example.com/images/station2.png', '+1234567891', '40.7138N', '74.0050W', '06:00-22:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('station-3', 'West End Station', '789 West Rd', 'West side service point', 'https://example.com/images/station3.png', '+1234567892', '40.7148N', '74.0040W', '06:00-22:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =======================
-- Insert bike data
-- =======================
INSERT INTO bike (
    "bikeId",
    "addedById",
    "isActive",
    "isFlaggedForMaintenance",
    "modelName",
    "brand",
    "maxSpeed",
    "rangeKm",
    "weightKg",
    "imageUrl",
    "description",
    "isReserved",
    "createdAt",
    "updatedAt",
    "batteryLevel",
    "stationId"
) VALUES
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'Volt X1', 'VoltCycles', 25, 40, 15, 'https://example.com/images/volt-x1.png', 'Lightweight urban eBike with good range', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 60, 'station-1'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'SwiftRide 3000', 'Swift Bikes', 30, 50, 18, 'https://example.com/images/swiftride-3000.png', 'High speed model designed for city commutes', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 80, 'station-2'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Eco friendly cruiser with solid battery life', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 70, 'station-3'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'Volt X1', 'VoltCycles', 25, 40, 15, 'https://example.com/images/volt-x1.png', 'Lightweight urban eBike', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 90, 'station-1'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'SwiftRide 3000', 'Swift Bikes', 30, 48, 18, 'https://example.com/images/swiftride-3000.png', 'Fast and comfortable', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 40, 'station-2'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Great for short city rides', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 80, 'station-3'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'Volt X2', 'VoltCycles', 27, 42, 16, 'https://example.com/images/volt-x2.png', 'Improved range and speed', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 60, 'station-1'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'SwiftRide 3500', 'Swift Bikes', 32, 52, 19, 'https://example.com/images/swiftride-3500.png', 'Sporty model for commuters', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 90, 'station-2'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser Plus', 'Green Wheels', 22, 38, 21, 'https://example.com/images/ecocruiser-plus.png', 'Enhanced comfort and battery', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 70, 'station-3'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, true, 'SwiftRide 3000', 'Swift Bikes', 30, 50, 18, 'https://example.com/images/swiftride-3000.png', 'Needs maintenance: battery issue', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 80, 'station-2'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Eco friendly cruiser', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 60, 'station-3'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'Volt X2', 'VoltCycles', 27, 42, 16, 'https://example.com/images/volt-x2.png', 'Improved version', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 90, 'station-1'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'SwiftRide 3500', 'Swift Bikes', 32, 52, 19, 'https://example.com/images/swiftride-3500.png', 'Sporty commuter bike', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 40, 'station-2'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser Plus', 'Green Wheels', 22, 38, 21, 'https://example.com/images/ecocruiser-plus.png', 'Comfort and range upgrade', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 80, 'station-3'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, false, true, 'Volt X1', 'VoltCycles', 25, 40, 15, 'https://example.com/images/volt-x1.png', 'Flagged for maintenance', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 60, 'station-1'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'SwiftRide 3000', 'Swift Bikes', 30, 50, 18, 'https://example.com/images/swiftride-3000.png', 'Popular city bike', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 90, 'station-2'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Green mobility choice', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 70, 'station-3'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'Volt X2', 'VoltCycles', 27, 42, 16, 'https://example.com/images/volt-x2.png', 'Enhanced speed', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 40, 'station-1'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'SwiftRide 3500', 'Swift Bikes', 32, 52, 19, 'https://example.com/images/swiftride-3500.png', 'For sporty riders', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 80, 'station-2'),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser Plus', 'Green Wheels', 22, 38, 21, 'https://example.com/images/ecocruiser-plus.png', 'Comfort bike with range boost', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 60, 'station-3');
