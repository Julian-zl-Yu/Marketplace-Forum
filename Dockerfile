# ---------- Stage 1: Build ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build

COPY pom.xml .
RUN mvn -q -B -e -DskipTests dependency:go-offline

COPY src ./src
RUN mvn -q -B -DskipTests package

# ---------- Stage 2: Runtime ----------
FROM eclipse-temurin:17-jre
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /build/target/*.jar /app/app.jar

RUN curl -sfL https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.12.0/cloud-sql-proxy.linux.amd64 -o /usr/local/bin/cloud-sql-proxy \
 && chmod +x /usr/local/bin/cloud-sql-proxy

RUN printf '%s\n' \
'#!/usr/bin/env bash' \
'set -euo pipefail' \
'echo "$GCP_SA_KEY_JSON" > /tmp/gcp-key.json' \
'/usr/local/bin/cloud-sql-proxy "$INSTANCE_CONNECTION_NAME"=tcp:127.0.0.1:3306 --credentials-file=/tmp/gcp-key.json --health-check & sleep 2' \
'echo "Starting Spring Boot..."' \
'exec java ${JAVA_OPTS:-} -jar /app/app.jar' \
> /app/entrypoint.sh \
 && chmod +x /app/entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
