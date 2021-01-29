#!/usr/bin/env bash

set -e

BIN="/usr/bin/kube-apiserver-proxy"
CONFIG="/etc/kubernetes/apiserver-proxy.conf"
SYSTEMD_SERVICE="/lib/systemd/system/kube-apiserver-proxy.service"

function install(){
    info "install kube-apiserver-proxy..."

    if [ ! -d "/etc/kubernetes" ]; then
        err "config dir [/etc/kubernetes] not exit! Did you forget to install kubeadm?"
        exit 1
    fi

    info "copy files..."
    cp bin/kube-apiserver-proxy ${BIN}
    cp conf/apiserver-proxy.conf ${CONFIG}
    cp kube-apiserver-proxy.service ${SYSTEMD_SERVICE}
    fix_permissions

    info "systemd reload..."
    systemctl daemon-reload
}

function uninstall(){
    info "uninstall etcd..."
    systemctl stop kube-apiserver-proxy || true

    info "remove files..."
    rm -f ${BIN} ${CONFIG} ${SYSTEMD_SERVICE}

    info "systemd reload..."
    systemctl daemon-reload
}

function fix_permissions(){
    info "fix permissions..."
    chmod 755 ${BIN}
    chmod 644 ${SYSTEMD_SERVICE}

    chown -R kube:kube ${BIN} ${CONFIG}
    chown root:root ${SYSTEMD_SERVICE}
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

case "${2}" in
    "install")
        install
        ;;
    "uninstall")
        uninstall
        ;;
    *)
        cat <<EOF

NAME:
    ${1} - Kubernetes Api Server Proxy Tool

USAGE:
    ${1} command

AUTHOR:
    mritd <mritd@linux.com>

COMMANDS:
    install      Install kube-apiserver-proxy
    uninstall    Uninstall kube-apiserver-proxy

COPYRIGHT:
    Copyright (c) $(date "+%Y") mritd, All rights reserved.
EOF
        exit 0
        ;;
esac

