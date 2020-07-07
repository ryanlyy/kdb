/* gcc -rdynamic -g -o bt bt.c */

#include <execinfo.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static void printf_fbt()
{
    int j, nptrs;
#define SIZE 100
    void *buffer[100];
    char **strings;

   nptrs = backtrace(buffer, SIZE);

   strings = backtrace_symbols(buffer, nptrs);
    if (strings == NULL) {
        perror("backtrace_symbols");
        exit(EXIT_FAILURE);
    }

   for (j = 1; j < nptrs; j++)
        printf("%s\n", strings[j]);

   free(strings);
}

void
myfunc3(void)
{
        printf_fbt();
}

void myfunc2(void)
{
    myfunc3();
}

void
myfunc1()
{
        myfunc2();
}

int
main(int argc, char *argv[])
{

   myfunc1();
    exit(EXIT_SUCCESS);
}
