-- init.sql

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

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
    "updatedAt" TIMESTAMP
);

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
    "updatedAt"
) VALUES
-- 25 bike records with varied details

((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'Volt X1', 'VoltCycles', 25, 40, 15, 'https://example.com/images/volt-x1.png', 'Lightweight urban eBike with good range',false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'SwiftRide 3000', 'Swift Bikes', 30, 50, 18, 'https://example.com/images/swiftride-3000.png', 'High speed model designed for city commutes', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Eco friendly cruiser with solid battery life', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'Volt X1', 'VoltCycles', 25, 40, 15, 'https://example.com/images/volt-x1.png', 'Lightweight urban eBike',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'SwiftRide 3000', 'Swift Bikes', 30, 48, 18, 'https://example.com/images/swiftride-3000.png', 'Fast and comfortable',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Great for short city rides',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'Volt X2', 'VoltCycles', 27, 42, 16, 'https://example.com/images/volt-x2.png', 'Improved range and speed', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'SwiftRide 3500', 'Swift Bikes', 32, 52, 19, 'https://example.com/images/swiftride-3500.png', 'Sporty model for commuters', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser Plus', 'Green Wheels', 22, 38, 21, 'https://example.com/images/ecocruiser-plus.png', 'Enhanced comfort and battery', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'Volt X1', 'VoltCycles', 25, 40, 15, 'https://example.com/images/volt-x1.png', 'Lightweight urban eBike',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, true, 'SwiftRide 3000', 'Swift Bikes', 30, 50, 18, 'https://example.com/images/swiftride-3000.png', 'Needs maintenance: battery issue', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Eco friendly cruiser',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'Volt X2', 'VoltCycles', 27, 42, 16, 'https://example.com/images/volt-x2.png', 'Improved version',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'SwiftRide 3500', 'Swift Bikes', 32, 52, 19, 'https://example.com/images/swiftride-3500.png', 'Sporty commuter bike',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser Plus', 'Green Wheels', 22, 38, 21, 'https://example.com/images/ecocruiser-plus.png', 'Comfort and range upgrade',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, false, true, 'Volt X1', 'VoltCycles', 25, 40, 15, 'https://example.com/images/volt-x1.png', 'Flagged for maintenance',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'SwiftRide 3000', 'Swift Bikes', 30, 50, 18, 'https://example.com/images/swiftride-3000.png', 'Popular city bike', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Green mobility choice', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'Volt X2', 'VoltCycles', 27, 42, 16, 'https://example.com/images/volt-x2.png', 'Enhanced speed',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'SwiftRide 3500', 'Swift Bikes', 32, 52, 19, 'https://example.com/images/swiftride-3500.png', 'For sporty riders', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser Plus', 'Green Wheels', 22, 38, 21, 'https://example.com/images/ecocruiser-plus.png', 'Comfort bike with range boost',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'Volt X1', 'VoltCycles', 25, 40, 15, 'https://example.com/images/volt-x1.png', 'Light and fast', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'SwiftRide 3000', 'Swift Bikes', 30, 50, 18, 'https://example.com/images/swiftride-3000.png', 'Ideal for city travel',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Sustainable choice',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
((gen_random_uuid())::TEXT, (gen_random_uuid())::TEXT, true, false, 'Volt X2', 'VoltCycles', 27, 42, 16, 'https://example.com/images/volt-x2.png', 'Latest model',false,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
