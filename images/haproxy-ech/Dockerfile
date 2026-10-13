# haproxy-ech: HAProxy + OpenSSL 4.0（带 ECH / Encrypted Client Hello），官方 haproxy 镜像用 Debian 的 OpenSSL 3.5，没有 ECH。
# 用法见 haproxy 文档 `bind ... ech <dir>`（EXPERIMENTAL，shared-mode）。
ARG OPENSSL_VERSION=4.0.0
ARG OPENSSL_SHA256=c32cf49a959c4f345f9606982dd36e7d28f7c58b19c2e25d75624d2b3d2f79ac
ARG HAPROXY_VERSION=3.4.6
ARG HAPROXY_SHA256=791e1815f8af6e8b850a227a9a0a190f3d3478c9e8d38a0f51c98b7f4bfe368b

FROM debian:trixie-slim AS build
ARG OPENSSL_VERSION
ARG OPENSSL_SHA256
ARG HAPROXY_VERSION
ARG HAPROXY_SHA256
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl build-essential perl libpcre2-dev; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN set -eux; \
    curl -fsSL -o openssl.tar.gz "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz"; \
    echo "${OPENSSL_SHA256} *openssl.tar.gz" | sha256sum -c -; \
    mkdir openssl; tar -xzf openssl.tar.gz -C openssl --strip-components=1; \
    cd openssl; \
    ./Configure --prefix=/opt/openssl --libdir=lib; \
    make -j"$(nproc)"; \
    make install_sw

RUN set -eux; \
    curl -fsSL -o haproxy.tar.gz "https://www.haproxy.org/download/${HAPROXY_VERSION%.*}/src/haproxy-${HAPROXY_VERSION}.tar.gz"; \
    echo "${HAPROXY_SHA256} *haproxy.tar.gz" | sha256sum -c -; \
    mkdir haproxy; tar -xzf haproxy.tar.gz -C haproxy --strip-components=1; \
    cd haproxy; \
    make -j"$(nproc)" TARGET=linux-glibc \
        USE_GETADDRINFO=1 USE_PCRE2=1 USE_PCRE2_JIT=1 USE_PROMEX=1 USE_OPENSSL=1 USE_ECH=1 \
        SSL_INC=/opt/openssl/include SSL_LIB=/opt/openssl/lib \
        LDFLAGS="-Wl,-rpath,/opt/openssl/lib"; \
    make install-bin PREFIX=/usr/local; \
    # 构建期自检：没有 ECH 或不是 OpenSSL 4 就直接失败，避免推出一个"假 ECH"镜像
    /usr/local/sbin/haproxy -vv | tee /tmp/vv; \
    grep -q 'OpenSSL 4' /tmp/vv; \
    grep -Eq '\+ECH|USE_ECH=1' /tmp/vv

FROM debian:trixie-slim
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates libpcre2-8-0 socat; \
    rm -rf /var/lib/apt/lists/*; \
    groupadd --gid 99 --system haproxy; \
    useradd --gid haproxy --home-dir /var/lib/haproxy --no-create-home --system --uid 99 haproxy; \
    mkdir -p /var/lib/haproxy /usr/local/etc/haproxy; \
    chown haproxy:haproxy /var/lib/haproxy

COPY --from=build /opt/openssl/lib /opt/openssl/lib
# openssl 命令行用来生成 ECH 密钥: openssl ech -public_name <公共名> -out <dir>/<名>.ech
COPY --from=build /opt/openssl/bin/openssl /usr/local/bin/openssl
COPY --from=build /usr/local/sbin/haproxy /usr/local/sbin/haproxy
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

STOPSIGNAL SIGUSR1
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
