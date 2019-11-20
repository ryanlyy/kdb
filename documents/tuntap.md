# find you tap device
tap mac address is same with VM dev mac in later 5 bytes

# to find pid of your VM
ps -ef |grep [later 5 byte of mac]

# to find tun fd

```
<gen9-node3:root>/proc/5907/fd:
> ls -l | grep tun
lrwx------ 1 qemu qemu 64 Nov 20 16:15 34 -> /dev/net/tun
lrwx------ 1 qemu qemu 64 Nov 20 16:15 36 -> /dev/net/tun
lrwx------ 1 qemu qemu 64 Nov 20 16:15 38 -> /dev/net/tun
lrwx------ 1 qemu qemu 64 Nov 20 16:15 40 -> /dev/net/tun
```

# to get tapdev flag
```
gdb </path/to/executable> -batch-silent --pid=<executable_pid> -ex 'set $fd'=<tapdev fd> -x "./tungetiff.gdb"
```


# tungetiff.gdb
```
[root@foss-ssc-7 scripts]# cat tungetiff.gdb
set $malloc=(void *(*)(long long)) malloc
p $malloc(64)
p memset($1, 0, 64)
p ioctl($fd, 0x800454d2, $1)
set *((char *)($1+15))=0
set logging file /dev/stdout
set logging on
printf "devname=%s\n",$1
printf "devflag(short)_lowbyte=%x\n",*((char *)($1+16))
printf "devflag(short)_highbyte=%x\n",*((char *)($1+17))
set logging off
call free($1)
quit
[root@foss-ssc-7 scripts]#
```
```
/* TUNSETIFF ifr flags */
#define IFF_TUN         0x0001
#define IFF_TAP         0x0002
#define IFF_NO_PI       0x1000
/* This flag has no real effect */
#define IFF_ONE_QUEUE   0x2000
#define IFF_VNET_HDR    0x4000
#define IFF_TUN_EXCL    0x8000
#define IFF_MULTI_QUEUE 0x0100
#define IFF_ATTACH_QUEUE 0x0200
#define IFF_DETACH_QUEUE 0x0400
/* read-only flag */
#define IFF_PERSIST     0x0800
#define IFF_NOFILTER    0x1000
```
# example:
```
[root@foss-ssc-7 scripts]# gdb /home/ryliu/kdb/scripts/mytun -batch-silent --pid=7502 -ex 'set $fd'=3 -x "./tungetiff.gdb"
devname=tap123
devflag(short)_lowbyte=2
devflag(short)_highbyte=11
```
the ifr_flag is 1102 based on above defintion, there is no sk_filter configured
```
        switch (cmd) {
        case TUNGETIFF:
                tun_get_iff(current->nsproxy->net_ns, tun, &ifr);

                if (tfile->detached)
                        ifr.ifr_flags |= IFF_DETACH_QUEUE;
                if (!tfile->socket.sk->sk_filter)
                        ifr.ifr_flags |= IFF_NOFILTER; //we can get ifr_flags to check if there is sk_filter configured

                if (copy_to_user(argp, &ifr, ifreq_len))
                        ret = -EFAULT;
                break;
```
https://unix.stackexchange.com/questions/462171/how-to-find-the-connection-between-tap-interface-and-its-file-descriptor
