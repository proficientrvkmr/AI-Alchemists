# Dockerfile
FROM openjdk:17-jdk-alpine

# Set environment variables
ENV SERVER_PORT=8080
ENV SPRING_PROFILES_ACTIVE=prod

# Copy the application jar to the container
COPY build/libs/PSCircleCore.jar /app.jar

# Expose the port the application will be listening on
EXPOSE $SERVER_PORT

# Run the application
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-Dspring.profiles.active=$SPRING_PROFILES_ACTIVE", "-jar", "/app.jar"]