import ballerina/http;
import ballerinax/postgresql;
import ballerina/sql;

configurable int db_port = ?;
configurable string db_host = ?;
configurable string db_pass = ?;
configurable string db_user = ?;
configurable string db_name = ?;

postgresql:Options postgresqlOptions = {
  connectTimeout: 10
};
postgresql:Client dbClient = check new (username = db_user, password = db_pass, database = db_name,host=db_host,port=db_port, options = postgresqlOptions);

service /bike\-service on new http:Listener(8090) {

    resource function get bikes() returns Bike[] {
        sql:ParameterizedQuery query = `SELECT * FROM bikes`;
        
        stream<Bike, sql:Error?> result = dbClient->query(query, Bike);

        Bike[] bikes = [];

        // Consume the stream and build the array
        error? e = result.forEach(function(Bike bike) {
            bikes.push(bike);
        });

        return bikes;
        
    }
}
