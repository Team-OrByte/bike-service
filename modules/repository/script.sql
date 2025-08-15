-- AUTO-GENERATED FILE.

-- This file is an auto-generated file by Ballerina persistence layer for model.
-- Please verify the generated scripts and execute them against the target DB server.

DROP TABLE IF EXISTS "station";
DROP TABLE IF EXISTS "bike";

CREATE TABLE "bike" (
	"bikeId" VARCHAR(191) NOT NULL,
	"stationId" VARCHAR(191) NOT NULL,
	"addedById" VARCHAR(191) NOT NULL,
	"isActive" BOOLEAN NOT NULL,
	"isFlaggedForMaintenance" BOOLEAN NOT NULL,
	"modelName" VARCHAR(191) NOT NULL,
	"brand" VARCHAR(191) NOT NULL,
	"maxSpeed" INT NOT NULL,
	"rangeKm" INT NOT NULL,
	"weightKg" INT NOT NULL,
	"imageUrl" VARCHAR(191) NOT NULL,
	"description" VARCHAR(191) NOT NULL,
	"createdAt" TIMESTAMP NOT NULL,
	"updatedAt" TIMESTAMP NOT NULL,
	"isReserved" BOOLEAN NOT NULL,
	"batteryLevel" INT NOT NULL,
	PRIMARY KEY("bikeId")
);

CREATE TABLE "station" (
	"stationId" VARCHAR(191) NOT NULL,
	"name" VARCHAR(191) NOT NULL,
	"address" VARCHAR(191) NOT NULL,
	"description" VARCHAR(191) NOT NULL,
	"imageUrl" VARCHAR(191) NOT NULL,
	"phone" VARCHAR(191) NOT NULL,
	"latitude" VARCHAR(191) NOT NULL,
	"longitude" VARCHAR(191) NOT NULL,
	"operatingHours" VARCHAR(191) NOT NULL,
	"createdAt" TIMESTAMP NOT NULL,
	"updatedAt" TIMESTAMP NOT NULL,
	PRIMARY KEY("stationId")
);


