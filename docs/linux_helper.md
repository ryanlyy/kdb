Linux Development Tips 
---

- [OS Signal Handler](#os-signal-handler)
- [How to us objdump](#how-to-us-objdump)
- [How to format Json String](#how-to-format-json-string)
- [How to get linux system startup time:](#how-to-get-linux-system-startup-time)
- [How to change timezone](#how-to-change-timezone)
- [How to log all bash cmd to syslog](#how-to-log-all-bash-cmd-to-syslog)

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
https://codywu2010.wordpress.com/2015/09/27/cpuset-by-example/
https://www.redhat.com/en/blog/world-domination-cgroups-part-6-cpuset
