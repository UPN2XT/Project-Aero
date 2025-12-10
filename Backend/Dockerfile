FROM eclipse-temurin:25-jdk

WORKDIR /app

# Copy Maven wrapper AND its config (this must be atomic)
COPY mvnw ./
COPY .mvn .mvn
COPY pom.xml ./

# Fix permissions
RUN chmod +x mvnw

# Verify Java & Maven early (optional but great for debugging)
RUN java -version
RUN ./mvnw -v

# Force TLS 1.2+ and download dependencies
RUN ./mvnw -Dhttps.protocols=TLSv1.2 dependency:go-offline

# Copy the rest of the project
COPY src src

# Run the app
CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.profiles=docker"]
