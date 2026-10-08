# scanservjs-hplip: cups-web 里 scanservjs 容器用的镜像。
# 把原 postStart hook（apt-get update && apt-get install hplip sane-utils）烤进镜像，
# 启动时不再联网装包。基础镜像 sbs20/scanservjs 自带 amd64 + arm64。
# 由 .github/workflows/build-images.yml 构建并推送到 ghcr.io/<owner>/scanservjs-hplip。
ARG SCANSERVJS_VERSION=latest
FROM sbs20/scanservjs:${SCANSERVJS_VERSION}

RUN set -eux; \
    apt-get update -qq; \
    apt-get install -y -qq --no-install-recommends hplip sane-utils; \
    rm -rf /var/lib/apt/lists/*
