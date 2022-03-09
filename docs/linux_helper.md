Linux Development Tips 
---

- [OS Signal Handler](#os-signal-handler)
- [How to us objdump](#how-to-us-objdump)
- [How to format Json String](#how-to-format-json-string)
- [How to get linux system startup time:](#how-to-get-linux-system-startup-time)
- [How to change timezone](#how-to-change-timezone)
- [How to log all bash cmd to syslog](#how-to-log-all-bash-cmd-to-syslog)
- [How to check cpuset for cgroup](#how-to-check-cpuset-for-cgroup)
- [How to disas class function](#how-to-disas-class-function)
- [How to jump in code using assemble](#how-to-jump-in-code-using-assemble)
- [RPM dependencies](#rpm-dependencies)
- [Replace multiple spaces with single comma](#replace-multiple-spaces-with-single-comma)


# OS Signal Handler
http://man7.org/linux/man-pages/man2/sigaction.2.html

```
       #include <signal.h>

       int sigaction(int signum, const struct sigaction *act,
                     struct sigaction *oldact);
           struct sigaction {
               void     (*sa_handler)(int);
               void     (*sa_sigaction)(int, siginfo_t *, void *);
               sigset_t   sa_mask;
               int        sa_flags;
               void     (*sa_restorer)(void);
           };     
      sa_flags specifies a set of flags which modify the behavior of the
       signal.  It is formed by the bitwise OR of zero or more of the fol‐
       lowing: 
           SA_SIGINFO (since Linux 2.2)
                  The signal handler takes three arguments, not one.  In
                  this case, sa_sigaction should be set instead of sa_han‐
                  dler.  This flag is meaningful only when establishing a
                  signal handler.       
   The siginfo_t argument to a SA_SIGINFO handler
       When the SA_SIGINFO flag is specified in act.sa_flags, the signal
       handler address is passed via the act.sa_sigaction field.  This han‐
       dler takes three arguments, as follows:

           void
           handler(int sig, siginfo_t *info, void *ucontext)
           {
               ...
           }

       These three arguments are as follows

       sig    The number of the signal that caused invocation of the han‐
              dler.

       info   A pointer to a siginfo_t, which is a structure containing fur‐
              ther information about the signal, as described below.

       ucontext
              This is a pointer to a ucontext_t structure, cast to void *.
              The structure pointed to by this field contains signal context
              information that was saved on the user-space stack by the ker‐
              nel; for details, see sigreturn(2).  Further information about
              the ucontext_t structure can be found in getcontext(3).  Com‐
              monly, the handler function doesn't make any use of the third
              argument.   
              
```
https://stackoverflow.com/questions/8400530/how-can-i-tell-in-linux-which-process-sent-my-process-a-signal
```


Two Linux-specific methods are SA_SIGINFO and signalfd(), which allows programs to receive very detailed information about signals sent, including the sender's PID.

    Call sigaction() and pass to it a struct sigaction which has the desired signal handler in sa_sigaction and the SA_SIGINFO flag in sa_flags set. With this flag, your signal handler will receive three arguments, one of which is a siginfo_t structure containing the sender's PID and UID.

    Call signalfd() and read signalfd_siginfo structures from it (usually in some kind of a select/poll loop). The contents will be similar to siginfo_t.

Which one to use depends on how your application is written; they probably won't work well outside plain C, and I wouldn't have any hope of getting them work in Java. They are also unportable outside Linux. They also likely are the Very Wrong Way of doing what you are trying to achieve.

```
# How to us objdump
```
 objdump -xDsgeGtT  /opt/LU3P/lib64//libgrpcwrapper.so.2.0.0 > a.objdump
 cat /proc/pid/maps to find starting address
 7f3976d7a000-7f3976d7b000 r--p 00003000 fd:02 9807543                    /usr/lib/python2.7/lib-dynload/zlib.so
 /opt\/LU3P\/lib\/libgrpcwrapper.so.2.0.0: f6604000-f6d7e000
 offset address = f6a008f7 - f6604000 == 3fc8f7
 check a.objdump for that offset address
 00000000003fc860 g    DF .text  000000000000015a  Base        envoy::api::v2::ratelimit::RateLimitDescriptor_Entry::_InternalSerialize(unsigned char*, google::protobuf::io::EpsCopyOutputStream*) const

NTAStrace -l addr.json -p /utas/bin/:/opt/LU3P/lib64:/usr/lib64 -e sbl.elf -a f5837429

```

# How to format Json String
```
cat hostconfig.json | python -m json.tool
```

# How to get linux system startup time:
```
date -d "$(awk -F. '{print $1}' /proc/uptime) second ago" +"%Y-%m-%d %H:%M:%S"
```

# How to change timezone

* Inside of localtime()
```
- localtime
  - __tz_convert(t, 1, &_tmbuf);
    - tzset_internal (tp == &_tmbuf && use_localtime, 1);
      - tz = getenv ("TZ");
      - if tz == NULL then tz = TZDEFAULT(localtime);
      - if tz == "\0" then tz = "Universal(UTC)"
      - __tzfile_read (tz, 0, NULL);
    - if __use_tzfile then __tzfile_compute (*timer, use_localtime, &leap_correction, &leap_extra_secs, tp);
    - else __tz_compute (*timer, tp, use_localtime);
```
* OP1: change this link to any zone

/etc/localtime is system wide default timezone
```
[root@fp56sepvm70-tas-node-1 zoneinfo]# ls -l /etc/localtime
lrwxrwxrwx. 1 root root 39 Feb 23 22:58 /etc/localtime -> ../usr/share/zoneinfo/America/Sao_Paulo
[root@fp56sepvm70-tas-node-1 zoneinfo]#
```

* OP2: using timedatectl

```
[root@fp56sepvm70-tas-node-1 zoneinfo]# timedatectl -h
timedatectl [OPTIONS...] COMMAND ...

Query or change system time and date settings.

  -h --help                Show this help message
     --version             Show package version
     --no-pager            Do not pipe output into a pager
     --no-ask-password     Do not prompt for password
  -H --host=[USER@]HOST    Operate on remote host
  -M --machine=CONTAINER   Operate on local container
     --adjust-system-clock Adjust system clock when changing local RTC mode

Commands:
  status                   Show current time settings
  set-time TIME            Set system time
  set-timezone ZONE        Set system time zone
  list-timezones           Show known time zones
  set-local-rtc BOOL       Control whether RTC is in local time
  set-ntp BOOL             Control whether NTP is enabled
[root@fp56sepvm70-tas-node-1 zoneinfo]#
```

* OP3: Environment Variable TZ

TZ is user level timezone instead of default /etc/localtime

```
[root@fp56sepvm70-tas-node-1 zoneinfo]# export TZ=UTC
[root@fp56sepvm70-tas-node-1 zoneinfo]# date
Tue Mar  2 08:19:59 UTC 2021
[[root@fp56sepvm70-tas-node-1 zoneinfo]# unset TZ
[root@fp56sepvm70-tas-node-1 zoneinfo]# date
Tue Mar  2 05:20:21 -03 2021
[root@fp56sepvm70-tas-node-1 zoneinfo]#
```
NOTE: TZ is high priority than /etc/localtime

https://www.cyberciti.biz/faq/centos-linux-6-7-changing-timezone-command-line/

# How to log all bash cmd to syslog

echo "local6.*    /var/log/commands.log" >> /etc/rsyslog.conf

Add the following to /etc/bashrc
```
export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug "$(whoami) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]"'
```

systemctl restart rsyslog

# How to check cpuset for cgroup
```
cd /sys/fs/cgroup
```
to check cpuset on each cgroup cmd:
```
for cpus in $(find . -name cpuset.cpus); do cat $cpus; done
```
to check affinity of process in each cgroup:
```
for task in $(find . -name tasks); do echo $task; for pid in $(cat $task); do taskset -p $pid; done; done
```
to list cpu information:
```
[root@fi-706-cluster1-workerbm-6 docker-74e38c408e06b0b8714e64e4d9ebedbaa07af44835477338943b9e3c6f6d4bf8.scope]# lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                80
On-line CPU(s) list:   0-79
Thread(s) per core:    2
Core(s) per socket:    20
Socket(s):             2
NUMA node(s):          2
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 85
Model name:            Intel(R) Xeon(R) Gold 5218R CPU @ 2.10GHz
Stepping:              7
CPU MHz:               2900.011
CPU max MHz:           4000.0000
CPU min MHz:           800.0000
BogoMIPS:              4200.00
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              1024K
L3 cache:              28160K
NUMA node0 CPU(s):     0-19,40-59
NUMA node1 CPU(s):     20-39,60-79
Flags:                 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid dca sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb cat_l3 cdp_l3 invpcid_single intel_ppin ssbd mba ibrs ibpb stibp ibrs_enhanced tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm cqm mpx rdt_a avx512f avx512dq rdseed adx smap clflushopt clwb intel_pt avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 xsaves cqm_llc cqm_occup_llc cqm_mbm_total cqm_mbm_local dtherm ida arat pln pts hwp hwp_act_window hwp_pkg_req pku ospke avx512_vnni md_clear flush_l1d arch_capabilities
[root@fi-706-cluster1-workerbm-6 docker-74e38c408e06b0b8714e64e4d9ebedbaa07af44835477338943b9e3c6f6d4bf8.scope]#
```

to check kubelet CPU managmer policy
```
/etc/kubernetes/kubelet-config.yml
evictionHard:
  memory.available: 11593Mi
  nodefs.available: 10%
  nodefs.inodesFree: 5%
  imagefs.available: 15%
systemReserved:
  memory: 11593Mi
cpuManagerPolicy: static
reservedSystemCPUs: "0,40,20,60"

static 策略
static 策略针对具有整数型 CPU requests 的 Guaranteed Pod ，它允许该类 Pod 中的容器访问节点上的独占 CPU 资源。这种独占性是使用 cpuset cgroup 控制器 来实现的。
```
https://codywu2010.wordpress.com/2015/09/27/cpuset-by-example/
https://www.redhat.com/en/blog/world-domination-cgroups-part-6-cpuset

# How to disas class function
```
(gdb) disas /r &A::foo(int)
Dump of assembler code for function A::foo(int):
   0x000000000040132e <+0>:     55      push   %rbp
   0x000000000040132f <+1>:     48 89 e5        mov    %rsp,%rbp
   0x0000000000401332 <+4>:     48 83 ec 10     sub    $0x10,%rsp
   0x0000000000401336 <+8>:     48 89 7d f8     mov    %rdi,-0x8(%rbp)
   0x000000000040133a <+12>:    89 75 f4        mov    %esi,-0xc(%rbp)
   0x000000000040133d <+15>:    be 63 25 40 00  mov    $0x402563,%esi
   0x0000000000401342 <+20>:    bf 00 41 60 00  mov    $0x604100,%edi
```

# How to jump in code using assemble
1. Near jmp
* SHORT jmp: particular offset
* LONG jmp: larger offset
Both of these jump types are usually relative
```
0x0000000000401534 <+0>:     e9 29 00 00 00  jmpq   0x401562 <foo_stub(int)>
0x000000000040132e <+0>:     e9 5a fb ff ff  jmpq   0x400e8d <foo_stub_int(void*, int)>

```
2. Far jmp
specifies both a segment and offset, which are both absolute in the sense that they specify the required code segment and instruction pointer, rather than an offset relative to the current code segment / instruction pointer.

```
    #define CODESIZE 13U
    #define CODESIZE_MIN 5U
    #define CODESIZE_MAX CODESIZE
    //13 byte(jmp m16:64)
    //movabs $0x102030405060708,%r11
    //jmpq   *%r11
    #define REPLACE_FAR(t, fn, fn_stub)\
        *fn = 0x49;\
        *(fn + 1) = 0xbb;\
        *(long long *)(fn + 2) = (long long)fn_stub;\
        *(fn + 10) = 0x41;\
        *(fn + 11) = 0xff;\
```
```
        if (pstub->far_jmp)
        {
            //13 byte
            *(unsigned char*)fn = 0x49;
            *((unsigned char*)fn + 1) = 0xbb;
            *(unsigned long long *)((unsigned char *)fn + 2) = (unsigned long long)fn_stub;
            *(unsigned char *)((unsigned char *)fn + 10) = 0x41;
            *(unsigned char *)((unsigned char *)fn + 11) = 0x53;
            *(unsigned char *)((unsigned char *)fn + 12) = 0xc3;
        }
        else
        {
            //5 byte
            *(unsigned char *)fn = (unsigned char)0xE9; // asm jmp
            *(unsigned int *)((unsigned char *)fn + 1) = (unsigned char *)fn_stub - (unsigned char *)fn - CODESIZE_MIN;
        }
```

# RPM dependencies

```
$ rpm -qp mypackage.rpm --provides
$ rpm -qp mypackage.rpm --requires
```

# Replace multiple spaces with single comma
```
top -d 0.5 -b -p 939 | tee a.out
```
```
$ echo "PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND" | sed "s/^ *//;s/ *$//;s/[[:space:]]\{1,\}/,/g"
PID,USER,PR,NI,VIRT,RES,SHR,S,%CPU,%MEM,TIME+,COMMAND
[envoy@udm-udmtrigger-7d7d55895c-x79vp ~]$ 
```
```
[envoy@udm-udmtrigger-7d7d55895c-x79vp ~]$ cat a.out | grep bin |  a
939,envoy,20,0,1710408,39712,30288,S,0.0,0.0,26:54.57,bin.catrunnerf
939,envoy,20,0,1710408,39712,30288,S,0.0,0.0,26:54.57,bin.catrunnerf
939,envoy,20,0,1710408,39712,30288,S,0.0,0.0,26:54.57,bin.catrunnerf
939,envoy,20,0,1710408,39712,30288,S,0.0,0.0,26:54.57,bin.catrunnerf
939,envoy,20,0,1710408,39712,30288,S,0.0,0.0,26:54.57,bin.catrunnerf
```

# How to get all netns of Linux
```
pid=$(docker inspect -f '{{.State.Pid}}' ${container_id})
mkdir -p /var/run/netns/
ln -sfT /proc/$pid/ns/net /var/run/netns/$container_id
```

# How to get all ns using ns
```
root@panda-01-edge-05 eth4]# lsns -n -l -t net
4026531992 net     244     1 root /usr/lib/systemd/systemd --switched-root --system --deserialize 21
4026532379 net       2  8599 root /pause
4026532482 net      68  8895 2006 sleep 1d
4026532613 net      92  4451 2000 postgres: adv caf_db ::1(47320) idle        
4026532675 net      68  9163 2006 sleep 15m
4026533419 net      82  5052 2006 sleep 1d

```

# How to disable sudo w/ passwd
```bash
At the end of the /etc/sudoers file add this line:
	
username     ALL=(ALL) NOPASSWD:ALL
```

# How to automatically load SCTP kernel module
## When SCTP socket, SCTP kernel module will be automatically loadded but it need NET_ADMIN permission

## Openshift
https://docs.openshift.com/container-platform/4.8/networking/using-sctp.html

## Redhat
https://access.redhat.com/solutions/6625041

```
The overall workflow requires installing kernel-modules-extra, adding the appropriate modules to /etc/modules-load.d/* to load before sysctls are set during boot, then rebooting to ensure the module and sysctls load appropriately. From there, ss and netstat along with some tool such as nc can be used to ensure the sizes are set.

    Install kernel-modules-extra for the currently installed kernel;
    Raw

    # dnf install kernel-modules-extra-`uname -r`

        The latest kernel and kernel-modules-extra packages will be installed if the uname -r section is left out of the above command.

    Add sctp to /etc/modules-load.d/* to load sctp before systemd-sysctl.service during boot. Loading sctp before systemd-sysctl.service allows the sctp sysctl.conf settings to be effective;
    Raw

    # cat /etc/modules-load.d/sctp.conf
    sctp

    sctp is blacklisted by default on installation. Comment out the blacklisting to enable sctp to be loaded.
    Raw

     r8 # grep sctp /etc/modprobe.d/*
    /etc/modprobe.d/sctp-blacklist.conf:#blacklist sctp
    /etc/modprobe.d/sctp_diag-blacklist.conf:#blacklist sctp_diag

    Reboot (or simply manually load the module, modprobe sctp)

    Check some command such as ncat provided from the nmap-ncat package to ensure sctp sockets can be created
    Raw

     r8 # lsmod | grep sctp  # checking the module is loaded
    sctp                  409600  4
    ip6_udp_tunnel         16384  1 sctp
    udp_tunnel             20480  1 sctp
    libcrc32c              16384  5 nf_conntrack,nf_nat,nf_tables,xfs,sctp

     r8 # ncat --sctp -k -l 127.0.0.1 8192  # creates an sctp socket on the local host at socket number 8192

    # In another terminal, check ss
     r8 # ss -pneomSa | grep -A 1 8192
    LISTEN 0      10         127.0.0.1:8192      0.0.0.0:*    users:(("ncat",pid=1912,fd=3)) ino:34833 sk:1 <->
         skmem:(r0,rb212992,t0,tb212992,f0,w0,o0,bl0,d0) locals:127.0.0.1

```


