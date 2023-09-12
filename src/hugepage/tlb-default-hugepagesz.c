#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>


int main(int argc, char** argv)
{
    int ms = atoi(argv[1]);
    const long long memorySize = ms * 1024ULL * 1024ULL;

    void* data = mmap(
        /* "If addr is NULL, then the kernel chooses the (page-aligned) address at which to create the mapping" */
        NULL,
        memorySize,
        /* memory protection / permissions */ PROT_READ | PROT_WRITE,
        MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB,
        /* fd should for compatibility be -1 even though it is ignored for MAP_ANONYMOUS */ -1,
        /* "The offset argument should be zero [when using MAP_ANONYMOUS]." */ 0
    );

    if ( data == MAP_FAILED ) {
        printf("Failed to allocate memory: %s\nb",  strerror( errno )); 
    } else {
        printf("Allocated pointer at: %p/n", data) ;
    }

    while ( 1 )
    {
	    sleep(1000);
    }
    munmap( data, memorySize );

    return 0;
}
