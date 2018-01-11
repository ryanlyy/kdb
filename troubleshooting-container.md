Maybe we sometime complain there is no debugging tool available in container when we debug some issues. Now we should not complain it :)

Here is the procedure how to implement it:

## 1.	Requirement ##
Docker is installed
 
## 2.	Download troubleshooting container image: ##
* docker pull ryanlyy/container-troubleshooting:20180111

## 3.	Debugging on Host layer ##
* docker run --privileged -dt --network=host --ipc=host --pid=host --name tstc ryanlyy/container-troubleshooting:20180111 bash
* docker exec –ti tstc bash
 
Then you can use a lot of tools to debug your issues.

Note: in this case, your container has same network, ipc, pid namespace with host 
 
## 4.	Debugging in Container layer ##
https://github.com/ryanlyy/toolsets/blob/master/get_container_rootfs.sh

* Get Container Rootfs: ./get_container_rootfs.sh 1df11e5e1068
* docker run --privileged -dt -v /var/lib/docker/aufs/mnt/container-rootfs:/1df11e5e1068 --network=container:1df11e5e1068 --ipc=container:1df11e5e1068 --pid=container:1df11e5e1068 --name tstc ryanlyy/container-troubleshooting:20180111 bash
* docker exec –ti tstc bash

Then you can debug your issue within this container.
 
note: 
*	d108297af3e7 is the ID of container that you want to debug (docker ps)
*	in this case, your container has same network, ipc, pid namespace and rootfs of the container that you want to debug
 
## 5.	Tools supported so far ##
Tcpdump, gdb, ip, ethtool, netstat, arping, strace, iptraf-ng, jnettop, iftop, iotop, bmon, traceroute, vmstat, vnstat, openssh, htop, sctp_darn, lsof, iostat, collectl, mpstat, socat, mytop, apachetop, iperf, dig, qperf, etc.
 
With those tools, you can check your networking, cpu, disk, memory, process etc. issues.
 
The following is packages installed:

iproute iputils net-tools jnettop iftop tcpdump ethtool nethogs
iptraf-ng ngrep mrtg bmon traceroute iptstate  vnstat nmap ngios
nmon smokeping openssh nmap-ncat strace wget unzip python-pip
htop gdb openssh-server lksctp-tools yajl-devel libcurl-devel
which socat sysstat vnstat htop atop apachetop mytop iotop dstat 
mpstat pmap collectl iostat lsof, iperf, bind-utils, qperf
 
## 6.	You can check the latest version from: ##
https://hub.docker.com/r/ryanlyy/container-troubleshooting/tags/
