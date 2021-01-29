## kube-apiserver-proxy-pack

> 本仓库为 kube-apiserver-proxy 生安装包，方便在宿主机安装以及配置。

### 一、使用

可直接从 [release](https://github.com/mritd/kube-apiserver-proxy-pack/releases) 页面下载对应版本安装包，然后执行 `kube-apiserver-proxy_*.run install` 既可安装。

```sh
➜ ./kube-apiserver-proxy_v1.19.6.run
Verifying archive integrity...  100%   MD5 checksums are OK. All good.
Uncompressing kube-apiserver-proxy  100%

NAME:
    kube-apiserver-proxy_v1.19.6.run - Kubernetes Api Server Proxy Tool

USAGE:
    kube-apiserver-proxy_v1.19.6.run command

AUTHOR:
    mritd <mritd@linux.com>

COMMANDS:
    install      Install kube-apiserver-proxy
    uninstall    Uninstall kube-apiserver-proxy

COPYRIGHT:
    Copyright (c) 2021 mritd, All rights reserved.
```

### 二、配置

默认情况下，**安装包会释放 `/etc/kubernetes/apiserver-proxy.conf` 文件，该文件为 nginx 配置文件，
请自行调整 server 配置:**

```sh
stream {
    upstream kube_apiserver {
        least_conn;
        server 10.0.0.11:5443;
        server 10.0.0.12:5443;
        server 10.0.0.13:5443;
    }

    server {
        listen        0.0.0.0:6443;
        proxy_pass    kube_apiserver;
        proxy_timeout 10m;
        proxy_connect_timeout 1s;
    }
}
```
