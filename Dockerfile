# Build Stage
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY . .
RUN mvn clean package -DskipTests

# Runtime Stage (minimal image, optimized layers)
FROM eclipse-temurin:17-jre-alpine

ENV APP_HOME=/app
WORKDIR ${APP_HOME}

# Copy only layers and launcher
COPY --from=build /workspace/target/test-9-*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

# Default command (override via CMD or ENTRYPOINT)
ENTRYPOINT ["java", "-cp", "BOOT-INF/classes:BOOT-INF/lib/*", "org.springframework.boot.loader.JarLauncher"]