# How to get Kernel Config
```
[root@bcmt-worker-06 /boot]# getconf -a
LINK_MAX                           65000
_POSIX_LINK_MAX                    65000
MAX_CANON                          255
_POSIX_MAX_CANON                   255
MAX_INPUT                          255
_POSIX_MAX_INPUT                   255
NAME_MAX                           255
_POSIX_NAME_MAX                    255
PATH_MAX                           4096
_POSIX_PATH_MAX                    4096
PIPE_BUF                           4096
_POSIX_PIPE_BUF                    4096
SOCK_MAXBUF
_POSIX_ASYNC_IO
_POSIX_CHOWN_RESTRICTED            1
...
```

# CPU Utilization
```
      User time, Nice time, System time, Idle time， Waiting time，Hard Irq time，SoftIRQ time，Steal time
cpu  755578848     2371503    653684756   12051234354 407392      106649190      114764309       0 0 0
%Cpu(s): 10.3 us,  7.3 sy,  0.0 ni, 80.5 id,  0.0 wa,  0.9 hi,  1.0 si,  0.0 st

CPU时间=user+system+nice+idle+iowait+irq+softirq+Stl = 13,684,690,352
%us=(User time + Nice time)/CPU时间*100%

%sy=(System time + Hard Irq time +SoftIRQ time)/CPU时间*100%
%id=(Idle time)/CPU时间*100%
%ni=(Nice time)/CPU时间*100%
%wa=(Waiting time)/CPU时间*100%
%hi=(Hard Irq time)/CPU时间*100%
%si=(SoftIRQ time)/CPU时间*100%
%st=(Steal time)/CPU时间*100%

[root@bcmt-worker-06 ~]# cat /proc/stat | grep "cpu "; sleep 3; cat /proc/stat | grep "cpu "; top -b -n 1 | grep Cpu
cpu  756193784 2372642 654066020 12056094990 407688 106703737 114825998 0 0 0 == 13,690,664,859
cpu  756195002 2372646 654066824 12056104586 407688 106703848 114826122 0 0 0 == 13,690,676,716‬
%Cpu(s):  6.7 us,  5.4 sy,  0.0 ni, 86.2 id,  0.0 wa,  0.8 hi,  1.0 si,  0.0 st

DIFF(total CPU) = 11857
DIFF(User+Nice) == 758,567,648 - 758,566,426‬ = 1222



```
