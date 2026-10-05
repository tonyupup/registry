# rouman-executor: vdown/rouman 下载器的运行环境。只烤"系统层"：ffmpeg + chromium 运行所需的
# 系统库（原 init.sh 里每次启动现场 apt-get / playwright install-deps 的部分）。
# Python venv（/venv）、uv 缓存、playwright 浏览器（/data/.playwright）、项目代码都在 PVC 上，
# 不进镜像；init.sh 里仍然负责 uv sync 和拷代码。
#
# pyproject.toml / uv.lock 只用来让 install-deps 用上与项目一致的 playwright 版本（装完即删），
# 依赖里 playwright 版本变了要同步更新这两个文件。
# 由 .github/workflows/build-images.yml 构建并推送到 ghcr.io/<owner>/rouman-executor（amd64 + arm64）。
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ffmpeg; \
    rm -rf /var/lib/apt/lists/*

# 临时 venv 里装 playwright 跑 install-deps（只装系统库，不下载浏览器），完事整个删掉
RUN --mount=type=bind,source=pyproject.toml,target=/tmp/p/pyproject.toml \
    --mount=type=bind,source=uv.lock,target=/tmp/p/uv.lock \
    --mount=type=bind,source=README.md,target=/tmp/p/README.md \
    set -eux; \
    cd /tmp/p; \
    UV_PROJECT_ENVIRONMENT=/tmp/venv uv sync --frozen --no-dev --no-install-project; \
    /tmp/venv/bin/playwright install-deps chromium; \
    rm -rf /tmp/venv /var/lib/apt/lists/* /root/.cache
