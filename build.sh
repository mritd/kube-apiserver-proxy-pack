#!/usr/bin/env bash

set -e

NGINX_VERSION=${1}
MAKESELF_VERSION=${MAKESELF_VERSION:-"2.4.3"}
MAKESELF_INSTALL_DIR=$(mktemp -d makeself.XXXXXX)

NGINX_CONFIG_ARGS="\
    --prefix=/opt/kube-apiserver-proxy \
    --error-log-path=/var/log/kube-apiserver-proxy.err \
    --pid-path=/var/run/kube-apiserver-proxy.pid \
    --lock-path=/var/run/kube-apiserver-proxy.lock \
    --sbin-path=/usr/bin/kube-apiserver-proxy \
    --conf-path=/etc/kubernetes/apiserver-proxy.conf \
    --user=nobody \
    --group=nobody \
    --with-debug \
    --with-file-aio \
    --with-threads \
    --without-http \
    --without-http-cache \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module \
    --without-pcre \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_ssl_preread_module \
    "

check_version(){
    if [ -z "${NGINX_VERSION}" ]; then
        warn "nginx version not specified, use default version 1.19.6."
        NGINX_VERSION="1.19.6"
    fi
}

check_makeself(){
    if ! command -v makeself.sh >/dev/null 2>&1; then
        curl -fsSL https://github.com/megastep/makeself/releases/download/release-${MAKESELF_VERSION}/makeself-${MAKESELF_VERSION}.run \
            -o makeself-${MAKESELF_VERSION}.run
        bash makeself-${MAKESELF_VERSION}.run --target ${MAKESELF_INSTALL_DIR}
        export PATH=${MAKESELF_INSTALL_DIR}:${PATH}
    fi
}

download(){
    info "downloading nginx source code..."
    curl -fsSL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx-${NGINX_VERSION}.tar.gz

    info "extract the files."
    tar -zxC /usr/src -f nginx-${NGINX_VERSION}.tar.gz
}


pre_build(){
    info "install build dependencies..."
    apt install build-essential -y
    apt build-dep nginx -y
}

build(){
    info "building..."
    (cd /usr/src/nginx-${NGINX_VERSION} \
        && ./configure ${NGINX_CONFIG_ARGS} \
        && make -j$(getconf _NPROCESSORS_ONLN))

    info "copy bin file..."
    cp /usr/src/nginx-${NGINX_VERSION}/objs/nginx pack/bin/kube-apiserver-proxy

    makeself.sh pack kube-apiserver-proxy_v${NGINX_VERSION}.run "kube-apiserver-proxy" ./helper.sh kube-apiserver-proxy_v${NGINX_VERSION}.run
}

clean(){
    info "clean files."
    rm -rf pack/bin/* nginx-${NGINX_VERSION}.tar.gz /usr/src/nginx* makeself*
}

function info(){
    echo -e "\033[1;32mINFO: $@\033[0m"
}

function warn(){
    echo -e "\033[1;33mWARN: $@\033[0m"
}

function err(){
    echo -e "\033[1;31mERROR: $@\033[0m"
}

check_version
check_makeself
download
pre_build
build
clean

