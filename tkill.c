#define _GNU_SOURCE

#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <sys/syscall.h>

#define TGKILL 270


int main(int argc, char *argv[])
{
    long ret;
    int tgid, tid;
    int sig;

    tgid = atoi(argv[1]);
    tid = atoi(argv[2]);
    sig = atoi(argv[3]);


    //tid = syscall(SYS_gettid);
    //ret = syscall(SYS_tgkill, tgid, tid, SIGTERM);
    ret = syscall(SYS_tgkill, tgid, tid, sig);

    if (ret != 0)
        perror("tgkill");

    return 0;
}
