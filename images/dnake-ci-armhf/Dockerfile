# CI 交叉编译镜像：armhf/armel 工具链 + patchelf 预装好，Drone pipeline 直接拉这个镜像用，
# 不在每次构建时现场 apt install（那样每次构建都要重新下载工具链，慢）。
#
# apt 源默认用 Debian 官方源（GitHub runner 在海外，直连即可）。bullseye 的 LTS 已于
# 2026-08 结束，一旦被挪到归档站点，构建时 apt 会报 404，届时改成
# DEBIAN_MIRROR=http://archive.debian.org（images/dnake-ci-armhf/build.env 里的 BUILD_ARGS）。
#
# 由 .github/workflows/build-images.yml 构建并推送到 ghcr.io/<owner>/dnake-ci-armhf（amd64 + arm64）。
# 本地构建: docker buildx build --platform linux/arm64 -t dnake-ci-armhf images/dnake-ci-armhf
# 换 apt 源: --build-arg DEBIAN_MIRROR=http://archive.debian.org
#
# 注意区分："镜像自身的架构"（amd64/arm64，决定能跑在哪种 CI 节点上）和"它编译出的目标
# 架构"（armhf/armel，dnake 设备的架构）是两回事。
FROM debian:bullseye

ARG DEBIAN_MIRROR=http://deb.debian.org

RUN set -eux; \
    printf '%s\n' \
      "deb ${DEBIAN_MIRROR}/debian bullseye main contrib non-free" \
      "deb ${DEBIAN_MIRROR}/debian bullseye-updates main contrib non-free" \
      "deb ${DEBIAN_MIRROR}/debian-security bullseye-security main contrib non-free" \
      > /etc/apt/sources.list; \
    printf 'Acquire::Retries "8";\nAcquire::http::Timeout "60";\n' > /etc/apt/apt.conf.d/99retry; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        crossbuild-essential-armhf \
        crossbuild-essential-armel \
        patchelf make autoconf automake libtool git file ca-certificates; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
