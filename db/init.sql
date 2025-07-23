-- init.sql

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS bikes (
    bike_id UUID PRIMARY KEY,
    added_by_id UUID NOT NULL,
    is_active BOOLEAN NOT NULL,
    is_flagged_for_maintenance BOOLEAN NOT NULL,
    model_name VARCHAR(100),
    brand VARCHAR(100),
    max_speed_kmh INTEGER,
    range_km INTEGER,
    weight_kg INTEGER,
    image_url TEXT,
    description TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

INSERT INTO bikes (
    bike_id,
    added_by_id,
    is_active,
    is_flagged_for_maintenance,
    model_name,
    brand,
    max_speed_kmh,
    range_km,
    weight_kg,
    image_url,
    description,
    created_at,
    updated_at
) VALUES
-- 25 bike records with varied details

(gen_random_uuid(), gen_random_uuid(), true, false, 'Volt X1', 'VoltCycles', 25, 40, 15, 'https://example.com/images/volt-x1.png', 'Lightweight urban eBike with good range', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'SwiftRide 3000', 'Swift Bikes', 30, 50, 18, 'https://example.com/images/swiftride-3000.png', 'High speed model designed for city commutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Eco friendly cruiser with solid battery life', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'Volt X1', 'VoltCycles', 25, 40, 15, 'https://example.com/images/volt-x1.png', 'Lightweight urban eBike', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'SwiftRide 3000', 'Swift Bikes', 30, 48, 18, 'https://example.com/images/swiftride-3000.png', 'Fast and comfortable', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Great for short city rides', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'Volt X2', 'VoltCycles', 27, 42, 16, 'https://example.com/images/volt-x2.png', 'Improved range and speed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'SwiftRide 3500', 'Swift Bikes', 32, 52, 19, 'https://example.com/images/swiftride-3500.png', 'Sporty model for commuters', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'EcoCruiser Plus', 'Green Wheels', 22, 38, 21, 'https://example.com/images/ecocruiser-plus.png', 'Enhanced comfort and battery', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'Volt X1', 'VoltCycles', 25, 40, 15, 'https://example.com/images/volt-x1.png', 'Lightweight urban eBike', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

(gen_random_uuid(), gen_random_uuid(), true, true, 'SwiftRide 3000', 'Swift Bikes', 30, 50, 18, 'https://example.com/images/swiftride-3000.png', 'Needs maintenance: battery issue', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Eco friendly cruiser', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'Volt X2', 'VoltCycles', 27, 42, 16, 'https://example.com/images/volt-x2.png', 'Improved version', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'SwiftRide 3500', 'Swift Bikes', 32, 52, 19, 'https://example.com/images/swiftride-3500.png', 'Sporty commuter bike', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'EcoCruiser Plus', 'Green Wheels', 22, 38, 21, 'https://example.com/images/ecocruiser-plus.png', 'Comfort and range upgrade', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), false, true, 'Volt X1', 'VoltCycles', 25, 40, 15, 'https://example.com/images/volt-x1.png', 'Flagged for maintenance', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'SwiftRide 3000', 'Swift Bikes', 30, 50, 18, 'https://example.com/images/swiftride-3000.png', 'Popular city bike', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Green mobility choice', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'Volt X2', 'VoltCycles', 27, 42, 16, 'https://example.com/images/volt-x2.png', 'Enhanced speed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'SwiftRide 3500', 'Swift Bikes', 32, 52, 19, 'https://example.com/images/swiftride-3500.png', 'For sporty riders', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

(gen_random_uuid(), gen_random_uuid(), true, false, 'EcoCruiser Plus', 'Green Wheels', 22, 38, 21, 'https://example.com/images/ecocruiser-plus.png', 'Comfort bike with range boost', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'Volt X1', 'VoltCycles', 25, 40, 15, 'https://example.com/images/volt-x1.png', 'Light and fast', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'SwiftRide 3000', 'Swift Bikes', 30, 50, 18, 'https://example.com/images/swiftride-3000.png', 'Ideal for city travel', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'EcoCruiser', 'Green Wheels', 20, 35, 20, 'https://example.com/images/ecocruiser.png', 'Sustainable choice', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(gen_random_uuid(), gen_random_uuid(), true, false, 'Volt X2', 'VoltCycles', 27, 42, 16, 'https://example.com/images/volt-x2.png', 'Latest model', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
