#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/time.h>
#include <string.h>

int debug_flag = 0;

int SEED_prng_urandom()
{
    const size_t SEED_SIZE      = 1024;           //OpenSSL PRNG has 1023 bytes of state
    const char   ENTROPY_FILE[] = "/dev/urandom"; //provides better performance during startup
    int fd = open(ENTROPY_FILE, O_RDONLY);

    if (fd < 0)
    {
        printf("Opening entropy file /dev/urandom failed");
        return -1;
    }

    uint8_t   buffer[SEED_SIZE];
    ssize_t         res = -1;

    for (size_t read_so_far = 0; read_so_far < SEED_SIZE; read_so_far += res)
    {
        if (0 > (res = read(fd, buffer + read_so_far, SEED_SIZE - read_so_far)))
        {
            close(fd);
            printf("read(ENTROPY_FILE) failed: %s", strerror(errno));
            return -1;
        }
    }
    close(fd);
    if (debug_flag)
    {
        for (int cnt = 0; cnt < SEED_SIZE; cnt++)
        {
                printf("%x ", buffer[cnt]);
        }
        printf("\nDone\n");
    }
    return 0;
}

void SEED_prng_rand()
{
        int seed = 1000;
        int *seedp = &seed;
        const size_t SEED_SIZE      = 1024;           //OpenSSL PRNG has 1023 bytes of state
        int r_num;

        uint8_t   buffer[SEED_SIZE];
        ssize_t         res = -1;

        for (int loop = 0; loop < SEED_SIZE; loop++)
        {
                r_num = rand_r(seedp);
                buffer[loop] = r_num;
        }
    if (debug_flag)
    {
        for (int cnt = 0; cnt < SEED_SIZE; cnt++)
        {
                printf("%x ", buffer[cnt]);
        }
        printf("\nDone\n");
    }
        return;
}


int main(int argc, char** argv)
{
        long long duration;
        int repeat_cnt = atoi(argv[1]);
        int ret;

        if (argc == 3)
        {
           if (strcmp(argv[2], "debug") == 0)
                debug_flag = 1;
        }

        struct timeval start, end;
        gettimeofday(&start, 0);
        for (int i = 0; i < repeat_cnt; i++)
        {
                ret = SEED_prng_urandom();
                if (ret < 0)
                        break;
        }
        gettimeofday(&end, 0);
        duration = (end.tv_sec - start.tv_sec) * 1000 * 1000 + (end.tv_usec - start.tv_usec);
        printf("DURATION of loop %d with urandom: %d\n", repeat_cnt, duration);

        gettimeofday(&start, 0);
        for (int i = 0; i < repeat_cnt; i++)
        {
                SEED_prng_rand();
        }
        gettimeofday(&end, 0);
        duration = (end.tv_sec - start.tv_sec) * 1000 * 1000 + (end.tv_usec - start.tv_usec);
        printf("DURATION of loop %d with rand: %d\n", repeat_cnt, duration);
}
