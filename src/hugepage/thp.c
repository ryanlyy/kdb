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
    const auto memalignError = posix_memalign(
        &data, /* alignment equal or higher to huge page size */ 2ULL * 1024ULL * 1024ULL, memorySize );
    if ( memalignError != 0 ) {
        std::cout << "Failed to allocate memory: " << strerror( memalignError ) << "\n";
        return 1;
    }

    std::cout << "Allocated pointer at: " << data << "\n";

    if ( madvise( data, memorySize, MADV_HUGEPAGE ) != 0 ) {
        std::cerr << "Error on madvise: " << strerror( errno ) << "\n";
        return 2;
    }

    const auto intData = reinterpret_cast<int*>( data );
    intData[0] = 3;
    /* This access is at offset 3000 * 8 = 24 kB, i.e.,
     * still in the same 2 MiB page as the access above */
    intData[3000] = 3;
    intData[memorySize / sizeof( int ) / 2] = 3;

    while ( 1 ) 
    {
	    sleep(1000);
    }
}
