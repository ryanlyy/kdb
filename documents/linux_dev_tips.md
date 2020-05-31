Linux Development Tips 
---

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
