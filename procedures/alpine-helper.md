# 1. Alpine Linux: Small Simple Secure 
* Alpine Linux is a security-oriented, lightweight Linux distribution based on **musl libc and busybox**
* Alpine Linux is an __independent__, __non-commercial__, __general purpose__ Linux distribution designed for power users who appreciate security, simplicity and resource efficiency
* The latest version: **3.7.0** (cat /etc/alpine-release)

```
Secure

Alpine Linux was designed with security in mind. The kernel is patched with an unofficial port of grsecurity/PaX, 
and all userland binaries are compiled as Position Independent Executables (PIE) with stack smashing protection. 
These proactive security features prevent exploitation of entire classes of zero-day and other vulnerabilities.
```
https://wiki.alpinelinux.org/wiki/Tutorials_and_Howtos

# 2. Alpine Linux Package management: 
* Installing/Upgrading/Deleting --- apk
* Restoring a system  --- lbu
## 2.1. Packages and Repositories

```
Contents of /etc/apk/repositories

http://nl.alpinelinux.org/alpine/v3.7/main
http://nl.alpinelinux.org/alpine/v3.7/community
@edge http://nl.alpinelinux.org/alpine/edge/main
@edgecommunity http://nl.alpinelinux.org/alpine/edge/community
@testing http://nl.alpinelinux.org/alpine/edge/testing
```
https://git.alpinelinux.org/cgit/aports/tree/main/alpine-mirrors/mirrors.yaml

## 2.2. Apk actions
* apk update
* apk upgrade
* apk add/del xxx
* apk search 
* apk info [-a] [xxx]

https://pkgs.alpinelinux.org/packages

## 2.3. Example using apk to build networking container image based on alpine
```
[root@ntas-cd-demo-fedora alpine]# cat Dockerfile.networking
FROM alpine:latest
LABEL maintainer="ryan.liu@nokia-sbell.com"

ENV http_proxy http://172.17.0.1:8989
ENV https_proxy https://172.17.0.1:8989

RUN apk update
RUN apk upgrade

RUN apk add iproute2 iputils net-tools iftop tcpdump ethtool nethogs iptraf-ng bmon iptstate  vnstat nmap nmap-ncat wget lksctp-tools socat vnstat iperf bind-tools

CMD [ "top" ]
[root@ntas-cd-demo-fedora alpine]#
```

