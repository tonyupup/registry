#!/usr/bin/env bash
# 新建一个镜像目录：images/<name>/Dockerfile，可选把项目代码以 submodule 挂到 images/<name>/src
#
# 用法: scripts/new-image.sh <name> [git-url] [branch]
set -euo pipefail

name=${1:?用法: $0 <name> [git-url] [branch]}
url=${2:-}
branch=${3:-}
dir="images/$name"

cd "$(git rev-parse --show-toplevel)"
[[ "$name" =~ ^[a-z0-9][a-z0-9._-]*$ ]] || { echo "镜像名只能用小写字母/数字/._-" >&2; exit 1; }
[[ -e "$dir" ]] && { echo "$dir 已存在" >&2; exit 1; }
mkdir -p "$dir"

if [[ -n "$url" ]]; then
  git submodule add ${branch:+-b "$branch"} "$url" "$dir/src"
  copy='COPY src/ /src/'
else
  copy='# COPY . /src/'
fi

cat > "$dir/Dockerfile" <<DOCKERFILE
# $name: TODO 说明这个镜像给哪个项目的 CI 用、装了什么
FROM debian:bookworm-slim

RUN set -eux; \\
    apt-get update; \\
    apt-get install -y --no-install-recommends ca-certificates git; \\
    rm -rf /var/lib/apt/lists/*

$copy
WORKDIR /build
DOCKERFILE

cat > "$dir/build.env" <<'ENV'
# 可选配置，删掉这个文件则使用默认值
# PLATFORMS=linux/amd64,linux/arm64
# BUILD_ARGS=FOO=1;BAR=2
ENV

git add "$dir"
echo "已创建 $dir，编辑 Dockerfile 后提交即可；README.md 的镜像列表记得补一行"
