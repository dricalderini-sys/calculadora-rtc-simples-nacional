FROM maven:3.9-eclipse-temurin-25 AS db
RUN apt-get update && apt-get install -y git && \
    git clone --depth 1 https://github.com/dricalderini-sys/calculadora-rtc-regime-regular /rr
WORKDIR /rr
RUN mkdir -p ./calculadora/db && \
    mvn -B flyway:migrate -Dflyway.configFiles=./flyway/flyway-pro.conf

FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .
RUN mvn -B clean package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/api-simples-nacional.jar app.jar
COPY --from=db /rr/calculadora ./calculadora
ENV JAVA_OPTS="-Xmx384m"
CMD sh -c "java $JAVA_OPTS -Dspring.profiles.active=offline -jar app.jar --server.port=${PORT:-8080}"
