VNC Server Helper
---

# VNC Server Installation

* GUI Installation for VNC for non-GUI CentOS Server
  ```
  dnf groupinstall "Server with GUI"
  ```
  NOTE: if CentOS Server is GUI, this step can be skipped

* Permanently switch to GUI mode (runlevel 5)
  ```
  systemctl set-default graphical
  ```

* reboot
* VNC Server Installation
  ```
  dnf install tigervnc-server
  ```
* VNC Passwd Creation
  ```
  vncpasswd
  ```
* Enable VNC Server Service
  ```
  cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
  ```
* Add VNC Server User
  ```
    [root@foss-ssc-6 ~]# cat /etc/tigervnc/vncserver.users
    # TigerVNC User assignment
    #
    # This file assigns users to specific VNC display numbers.
    # The syntax is <display>=<username>. E.g.:
    #
    # :2=andrew
    # :3=lisa
    :1=root
  ```
* Disable firewalld service 
  ```
  systemctl stop firewalld
  ```
* Disable SELinux
  ```
  setenforce 0
  sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
  ```
* Empty /tmp/.X11-unix
  ```
  rm -rf /tmp/.X11-unix/*
  ```

* xstartup
  ```
  [root@foss-ssc-6 .vnc]# cat xstartup
    #!/bin/sh

    unset SESSION_MANAGER
    unset DBUS_SESSION_BUS_ADDRESS
    exec /etc/X11/xinit/xinitrc
  ```

  * Disable localhost only access
    ```
    [root@foss-ssc-6 .vnc]# cat config
    session=gnome
    securitytypes=vncauth,tlsvnc
    desktop=sandbox
    geometry=2000x1200
    #localhost
    alwaysshared
    ```

# Troubleshooting
* TCP SYN received by no ACK sent out
  ```
    [root@foss-ssc-6 ~]# tcpdump -nni any tcp port 5901
    dropped privs to tcpdump
    tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
    listening on any, link-type LINUX_SLL (Linux cooked v1), capture size 262144 bytes
    09:15:21.427490 IP 10.243.83.15.52843 > 135.252.135.246.5901: Flags [S], seq 3442958811, win 64240, options [mss 1386,nop,wscale 8,nop,nop,sackOK], length 0
    09:15:22.352379 IP 10.243.83.15.52843 > 135.252.135.246.5901: Flags [S], seq 3442958811, win 64240, options [mss 1386,nop,wscale 8,nop,nop,sackOK], length 0
    09:15:24.357851 IP 10.243.83.15.52843 > 135.252.135.246.5901: Flags [S], seq 3442958811, win 64240, options [mss 1386,nop,wscale 8,nop,nop,sackOK], length 0
    09:15:28.372290 IP 10.243.83.15.52843 > 135.252.135.246.5901: Flags [S], seq 3442958811, win 64240, options [mss 1386,nop,wscale 8,nop,nop,sackOK], length 0
    09:15:36.387191 IP 10.243.83.15.52843 > 135.252.135.246.5901: Flags [S], seq 3442958811, win 64240, options [mss 1386,nop,wscale 8,nop,nop,sackOK], length 0
  ```
  iptables show REJECT is increasing when vncviewer connecting and the number is same with TCP SYN
  ```
  [root@foss-ssc-6 ~]# iptables -vnL INPUT
    Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination
    217K   44M LIBVIRT_INP  all  --  *      *       0.0.0.0/0            0.0.0.0/0
    209K   43M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
        1    28 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0
    7893  474K ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
        4   208 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
    445 44515 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited
  ```
  Remove that rule from INPUT chain
  ```
   iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
  ```