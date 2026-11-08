FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /src
COPY pom.xml .
COPY src ./src
RUN mvn -q -DskipTests package

FROM eclipse-temurin:17-jre
WORKDIR /app
EXPOSE 8761
COPY --from=build /src/target/eureka-server.jar /app/eureka-server.jar
ENTRYPOINT ["java","-jar","/app/eureka-server.jar","--server.port=8761"]
