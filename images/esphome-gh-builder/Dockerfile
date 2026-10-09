# esphome-gh-builder: ESPHome 远程构建服务器（把编译转发给 GitHub Actions）。
# 项目代码来自 submodule src/（tonyupup/esphome-gh-builder），依赖按 src/requirements.txt 安装。
# 以 sidecar 形式跑在 k8s 的 esphome Deployment 里，peer-link 监听 6055；身份/配对数据放 /data（PVC）。
FROM python:3.13-slim

# git: device-builder 用它记录配置目录的版本历史
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git ca-certificates; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ghbuilder ghbuilder

ENV PYTHONUNBUFFERED=1
VOLUME /data
EXPOSE 6055
ENTRYPOINT ["python", "-m", "ghbuilder.server", "--remote-build-only", "--remote-build-port", "6055", "/data"]
