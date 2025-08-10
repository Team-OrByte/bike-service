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
                isReserved: {columnName: "isReserved"}
            },
            keyFields: ["bikeId"]
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
        self.persistClients = {[BIKE]: check new (dbClient, self.metadata.get(BIKE).cloneReadOnly(), psql:POSTGRESQL_SPECIFICS)};
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

