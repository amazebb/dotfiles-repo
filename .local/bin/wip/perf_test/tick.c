// tick.c
#include <stdio.h>
#include <time.h>
int main() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    printf("%ld.%09ld\n", ts.tv_sec, ts.tv_nsec);
    return 0;
}
