#!/bin/sh
# 与官方 haproxy 镜像一致：参数以 - 开头则补上 haproxy；是 haproxy 时用 -W 起 master-worker
set -e
if [ "${1#-}" != "$1" ]; then set -- haproxy "$@"; fi
if [ "$1" = 'haproxy' ]; then
    shift
    set -- haproxy -W -db "$@"
fi
exec "$@"
