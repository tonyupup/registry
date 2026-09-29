# CI 交叉编译镜像：armhf/armel 工具链 + patchelf 预装好，Drone pipeline 直接拉这个镜像用，
# 不在每次构建时现场 apt install（那样每次构建都要重新下载工具链，慢）。
#
# apt 源固定用 snapshot.debian.org 的日期快照：bullseye LTS 已于 2026-08 结束，
# deb.debian.org/security.debian.org 上 bullseye-security 的索引还在、但 pool 里的 deb11 包
# 已被清空（装包全 404），main 里的点版本又比 debian:bullseye 基础镜像自带的安全更新旧，
# 所以 main/updates/security 必须从同一个时间点取才能对上版本。
# 快照日期必须落在 bullseye-security 最后一次正常发布（2026-08-31）之后、pool 被清空（约
# 2026-09-02）之前：之后的快照拍到的是"索引还在、deb 已删"的坏状态，同样 404。
#
# 由 .github/workflows/build-images.yml 构建并推送到 ghcr.io/<owner>/dnake-ci-armhf（amd64 + arm64）。
# 本地构建: docker buildx build --platform linux/arm64 -t dnake-ci-armhf images/dnake-ci-armhf
# 换快照日期: --build-arg DEBIAN_SNAPSHOT=20260901T000000Z
#
# 注意区分："镜像自身的架构"（amd64/arm64，决定能跑在哪种 CI 节点上）和"它编译出的目标
# 架构"（armhf/armel，dnake 设备的架构）是两回事。
FROM debian:bullseye

ARG DEBIAN_SNAPSHOT=20260901T000000Z

RUN set -eux; \
    printf '%s\n' \
      "deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/${DEBIAN_SNAPSHOT} bullseye main contrib non-free" \
      "deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/${DEBIAN_SNAPSHOT} bullseye-updates main contrib non-free" \
      "deb [check-valid-until=no] http://snapshot.debian.org/archive/debian-security/${DEBIAN_SNAPSHOT} bullseye-security main contrib non-free" \
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
