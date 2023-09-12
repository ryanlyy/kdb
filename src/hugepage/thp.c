#include <array>
#include <chrono>
#include <fstream>
#include <iostream>
#include <string_view>
#include <thread>
#include <stdlib.h>
#include <string.h>     // streerror
#include <sys/mman.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>


int main(int argc, char **argv)
{
    const auto memorySize = atoi(argv[1]) * 1024ULL * 1024ULL;

    void* data{ nullptr };

    // if /sys/kernel/mm/transparent_hugepage/enabled = "always", then malloc may use hugepage if it is avaiable
    //data = malloc(memorySize);
#if 1
    const auto memalignError = posix_memalign(
        &data, /* alignment equal or higher to huge page size */ 2ULL * 1024ULL * 1024ULL, memorySize );
    if ( memalignError != 0 ) {
        std::cout << "Failed to allocate memory: " << strerror( memalignError ) << "\n";
        return 1;
    }

    std::cout << "Allocated pointer at: " << data << "\n";

    // if /sys/kernel/mm/transparent_hugepage/enabled = "madvise", then with MADV_HUGEPAAGE, hugepage will be used
    // if /sys/kernel/mm/transparent_hugepage/enabled = "never", then non hugepage will be used even if MADV_HUGEPAGE is flaged
    if ( madvise( data, memorySize, MADV_HUGEPAGE ) != 0 ) {
        std::cerr << "Error on madvise: " << strerror( errno ) << "\n";
        return 2;
    }
#endif

    memset(data, 0, memorySize);

    while ( 1 ) 
    {
	    sleep(1000);
    }
}
