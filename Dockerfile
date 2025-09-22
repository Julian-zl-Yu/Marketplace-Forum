FROM eclipse-temurin:21-jre

# 下载 Cloud SQL Proxy v2（Linux amd64）
ADD https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.12.0/cloud-sql-proxy.linux.amd64 /usr/local/bin/cloud-sql-proxy
RUN chmod +x /usr/local/bin/cloud-sql-proxy

WORKDIR /app
# 这里的 app.jar 替换成你构建出来的 jar 名称
COPY target/app.jar /app/app.jar

# 启动命令交给 Render 的 Start Command 覆盖
CMD ["sh", "-c", "java -jar /app/app.jar"]
