import ballerina/http;

service /api on new http:Listener(9000){
    resource function get bikes() returns string {
        return "Welcome to the bike service";
    }
}