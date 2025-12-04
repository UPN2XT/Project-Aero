# USE THIS IMAGE: Eclipse Temurin is the standard replacement for OpenJDK
FROM eclipse-temurin:25-jdk

# Set work directory
WORKDIR /app

# Copy Maven wrapper and Project file
COPY .mvn/ .mvn
COPY mvnw pom.xml ./

# Fix permission for the Maven wrapper
RUN chmod +x mvnw

# Download dependencies
RUN ./mvnw dependency:go-offline

# Copy the source code
COPY src ./src

# Start the app
CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.profiles=docker"]
