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

https://unix.stackexchange.com/questions/462171/how-to-find-the-connection-between-tap-interface-and-its-file-descriptor
