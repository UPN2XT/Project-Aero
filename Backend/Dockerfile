# Use Java 17 as the base (matches your README)
FROM eclipse-temurin:17-jdk-jammy

# Set work directory
WORKDIR /app

# Copy Maven wrapper and Project file
COPY .mvn/ .mvn
COPY mvnw pom.xml ./

# Fix permission for the Maven wrapper
RUN chmod +x mvnw

# Download dependencies (this layer will be cached)
RUN ./mvnw dependency:go-offline

# Copy the source code
COPY src ./src

# Start the app using the "docker" profile mentioned in your README
CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.profiles=docker"]
