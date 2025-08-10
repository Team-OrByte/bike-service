import ballerina/persist as _;
import ballerina/time;
import ballerinax/persist.sql;

@sql:Name {value:"'bike"}
type Bike record {|
readonly string bikeId;
string addedById;
boolean isActive;
boolean isFlaggedForMaintenance;
string modelName;
string brand;
int maxSpeed;
int rangeKm;
int weightKg;
string imageUrl;
string description;
time:Civil createdAt;
time:Civil updatedAt;
boolean isReserved;
|};
