# Use the official Ballerina runtime image
FROM ballerina/ballerina:2201.12.7 AS builder

# Set working directory
WORKDIR /app

# Copy the Ballerina project files (excluding configs and logs)
COPY Ballerina.toml .
COPY Dependencies.toml .
COPY *.bal .
COPY persist/ persist/
COPY modules/ modules/

# Build the Ballerina project
RUN bal build

# Use a smaller runtime image for the final stage
FROM eclipse-temurin:21-jre-alpine

# Set working directory
WORKDIR /app

# Copy the built jar from the builder stage
COPY --from=builder /app/target/bin/bike_service.jar .

# Create logs directory
RUN mkdir -p logs

# Expose the port the service runs on
EXPOSE 8090

# Run the application
CMD ["java", "-jar", "bike_service.jar"]
