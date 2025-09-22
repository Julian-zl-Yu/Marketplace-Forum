# 用更省内存的 JRE 基础镜像（你如果是 Java 17 就改成 temurin:17-jre）
FROM eclipse-temurin:17-jre

# 安装 curl（用于下载 cloud-sql-proxy），并创建工作目录
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 复制构建出来的 jar（通配符，无需改名）
# 先本地 mvn package 或 gradle build，让 target/*.jar 存在
COPY target/*.jar /app/app.jar

# 下载 Cloud SQL Auth Proxy v2 并赋执行权限
RUN curl -sfL https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.12.0/cloud-sql-proxy.linux.amd64 -o /usr/local/bin/cloud-sql-proxy \
 && chmod +x /usr/local/bin/cloud-sql-proxy

# 写入启动脚本并赋执行权限
# 该脚本会：1)把 SA JSON 写到临时文件 2)启动 proxy 3)启动 Spring Boot
RUN printf '%s\n' \
'#!/usr/bin/env bash' \
'set -euo pipefail' \
'' \
'echo "$GCP_SA_KEY_JSON" > /tmp/gcp-key.json' \
'' \
'/usr/local/bin/cloud-sql-proxy \\' \
'  "$INSTANCE_CONNECTION_NAME"=tcp:127.0.0.1:3306 \\' \
'  --credentials-file=/tmp/gcp-key.json \\' \
'  --health-check \\' \
'  --telemetry-project="$GOOGLE_CLOUD_PROJECT" &' \
'' \
'# 简单等待代理就绪' \
'sleep 2' \
'' \
'echo "Starting Spring Boot..."' \
'exec java ${JAVA_OPTS:-} -jar /app/app.jar' \
> /app/entrypoint.sh \
 && chmod +x /app/entrypoint.sh

# 暴露端口（按你应用对外端口；常见8080）
EXPOSE 8080

# 默认入口
ENTRYPOINT ["/app/entrypoint.sh"]
