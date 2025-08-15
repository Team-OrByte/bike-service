// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/jballerina.java;
import ballerina/persist;
import ballerina/sql;
import ballerinax/persist.sql as psql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

const BIKE = "bikes";
const STATION = "stations";

public isolated client class Client {
    *persist:AbstractPersistClient;

    private final postgresql:Client dbClient;

    private final map<psql:SQLClient> persistClients;

    private final record {|psql:SQLMetadata...;|} metadata = {
        [BIKE]: {
            entityName: "Bike",
            tableName: "bike",
            fieldMetadata: {
                bikeId: {columnName: "bikeId"},
                stationId: {columnName: "stationId"},
                addedById: {columnName: "addedById"},
                isActive: {columnName: "isActive"},
                isFlaggedForMaintenance: {columnName: "isFlaggedForMaintenance"},
                modelName: {columnName: "modelName"},
                brand: {columnName: "brand"},
                maxSpeed: {columnName: "maxSpeed"},
                rangeKm: {columnName: "rangeKm"},
                weightKg: {columnName: "weightKg"},
                imageUrl: {columnName: "imageUrl"},
                description: {columnName: "description"},
                createdAt: {columnName: "createdAt"},
                updatedAt: {columnName: "updatedAt"},
                isReserved: {columnName: "isReserved"},
                batteryLevel: {columnName: "batteryLevel"}
            },
            keyFields: ["bikeId"]
        },
        [STATION]: {
            entityName: "Station",
            tableName: "station",
            fieldMetadata: {
                stationId: {columnName: "stationId"},
                name: {columnName: "name"},
                address: {columnName: "address"},
                description: {columnName: "description"},
                imageUrl: {columnName: "imageUrl"},
                phone: {columnName: "phone"},
                latitude: {columnName: "latitude"},
                longitude: {columnName: "longitude"},
                operatingHours: {columnName: "operatingHours"},
                createdAt: {columnName: "createdAt"},
                updatedAt: {columnName: "updatedAt"}
            },
            keyFields: ["stationId"]
        }
    };

    public isolated function init() returns persist:Error? {
        postgresql:Client|error dbClient = new (host = host, username = user, password = password, database = database, port = port, options = connectionOptions);
        if dbClient is error {
            return <persist:Error>error(dbClient.message());
        }
        self.dbClient = dbClient;
        if defaultSchema != () {
            lock {
                foreach string key in self.metadata.keys() {
                    psql:SQLMetadata metadata = self.metadata.get(key);
                    if metadata.schemaName == () {
                        metadata.schemaName = defaultSchema;
                    }
                    map<psql:JoinMetadata>? joinMetadataMap = metadata.joinMetadata;
                    if joinMetadataMap == () {
                        continue;
                    }
                    foreach [string, psql:JoinMetadata] [_, joinMetadata] in joinMetadataMap.entries() {
                        if joinMetadata.refSchema == () {
                            joinMetadata.refSchema = defaultSchema;
                        }
                    }
                }
            }
        }
        self.persistClients = {
            [BIKE]: check new (dbClient, self.metadata.get(BIKE).cloneReadOnly(), psql:POSTGRESQL_SPECIFICS),
            [STATION]: check new (dbClient, self.metadata.get(STATION).cloneReadOnly(), psql:POSTGRESQL_SPECIFICS)
        };
    }

    isolated resource function get bikes(BikeTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get bikes/[string bikeId](BikeTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post bikes(BikeInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(BIKE);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from BikeInsert inserted in data
            select inserted.bikeId;
    }

    isolated resource function put bikes/[string bikeId](BikeUpdate value) returns Bike|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(BIKE);
        }
        _ = check sqlClient.runUpdateQuery(bikeId, value);
        return self->/bikes/[bikeId].get();
    }

    isolated resource function delete bikes/[string bikeId]() returns Bike|persist:Error {
        Bike result = check self->/bikes/[bikeId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(BIKE);
        }
        _ = check sqlClient.runDeleteQuery(bikeId);
        return result;
    }

    isolated resource function get stations(StationTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get stations/[string stationId](StationTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post stations(StationInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(STATION);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from StationInsert inserted in data
            select inserted.stationId;
    }

    isolated resource function put stations/[string stationId](StationUpdate value) returns Station|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(STATION);
        }
        _ = check sqlClient.runUpdateQuery(stationId, value);
        return self->/stations/[stationId].get();
    }

    isolated resource function delete stations/[string stationId]() returns Station|persist:Error {
        Station result = check self->/stations/[stationId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(STATION);
        }
        _ = check sqlClient.runDeleteQuery(stationId);
        return result;
    }

    remote isolated function queryNativeSQL(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>) returns stream<rowType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor"
    } external;

    remote isolated function executeNativeSQL(sql:ParameterizedQuery sqlQuery) returns psql:ExecutionResult|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor"
    } external;

    public isolated function close() returns persist:Error? {
        error? result = self.dbClient.close();
        if result is error {
            return <persist:Error>error(result.message());
        }
        return result;
    }
}

