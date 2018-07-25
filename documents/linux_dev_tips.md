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
