# ---------- Stage 1: Build ----------
# 替换 maven 基镜像：避免 Docker Hub 拉取 401 / 限流
FROM eclipse-temurin:17-jdk AS build

# 安装 maven（避免从 docker.io/library/maven 拉镜像）
RUN apt-get update \
 && apt-get install -y --no-install-recommends maven \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# 先拷 pom.xml 预拉依赖，加速后续构建
COPY pom.xml .
RUN mvn -q -B -DskipTests dependency:go-offline

# 再拷代码并打包
COPY src ./src
RUN mvn -q -B -DskipTests package

# ---------- Stage 2: Runtime ----------
FROM eclipse-temurin:17-jre

# 工具：curl + CA 证书（下载 proxy 需要）
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 拷贝可执行 JAR（按你项目实际 jar 名称通配）
COPY --from=build /build/target/*.jar /app/app.jar

# 下载 Cloud SQL Proxy（你原逻辑保持）
RUN curl -sfL https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.12.0/cloud-sql-proxy.linux.amd64 \
     -o /usr/local/bin/cloud-sql-proxy \
 && chmod +x /usr/local/bin/cloud-sql-proxy

# 入口脚本：先起 proxy，再起 Spring Boot；把端口绑定到 Render 的 ${PORT}
RUN printf '%s\n' \
'#!/usr/bin/env bash' \
'set -euo pipefail' \
'echo "$GCP_SA_KEY_JSON" > /tmp/gcp-key.json' \
'/usr/local/bin/cloud-sql-proxy --credentials-file=/tmp/gcp-key.json --address 127.0.0.1 --port 3306 "$INSTANCE_CONNECTION_NAME" & sleep 2' \
'echo "Starting Spring Boot on port ${PORT:-8080}..."' \
'exec java ${JAVA_OPTS:-} -Dserver.port=${PORT:-8080} -jar /app/app.jar' \
> /app/entrypoint.sh \
 && chmod +x /app/entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
