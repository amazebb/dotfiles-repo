#!/bin/dash
set -x
# PS4='+$(gdate "+%s.%N")	'
# PS4='+$(/usr/bin/perl -MTime::HiRes=clock_gettime,CLOCK_MONOTONIC -e "printf \"%.9f\\n\", clock_gettime(CLOCK_MONOTONIC)")	'
# PS4='+$(/usr/bin/python3 -c "from ctypes import CDLL; print(CDLL(\"libc.dylib\").mach_absolute_time() / 1e9)")	'
PS4='+$(./tick)	'
i=0
while [ "$i" -lt 1000 ]; do
    i=$((i + 1))
    echo "result_$i" > /dev/null
done
