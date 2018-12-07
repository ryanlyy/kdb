#include <sys/syscall.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <signal.h>

int main(int argc, char** argv)
{
        int tg_id = atoi(argv[1]);
        int t_id = atoi(argv[2]);
        int sig = atoi(argv[3]);
        int ret;

        printf("sending signal:%d to thread:%d of process:%d...\n", t_id, tg_id);
        return syscall(SYS_tgkill, tg_id, t_id, sig);
}
