These scripts have been used to measure the performance of various shells and the cost of system calls

# Profiling Summary: Shell Script Performance on macOS 15.3.1

## Objective
Profile a `dash` script (`i=0; while [ "$i" -lt N ]; do i=$((i + 1)); echo "result_$i" > /dev/null; done`) to identify bottlenecks, focusing on `dash`’s execution speed vs. `bash`, `sh`, and `zsh`.

## Initial Approach: `time` Command
- **Method**: Used `time /bin/dash ./script.sh` for 100K loops.
- **Results**:
  - No I/O: 0.186s total (0.16s user, 0.03s system) → ~1.86µs/loop.
  - With `echo`: 1.123s total (0.31s user, 0.81s system) → ~11.23µs/loop.
  - `echo` cost: ~9.37µs (~80% system time).
- **Finding**: Coarse whole-script timing—`echo` dominates, but no line-by-line detail.

## PS4 Tracing with Timestamps
- **Method**: `set -x` with `PS4='+$(<clock>) '`, redirecting to `trace.log`, analyzed with `awk` for per-line diffs.
- **Attempts**:
  1. **BSD `date`**:
     - `PS4='+$(/bin/date "+%s.%N") '`
     - Issue: No `%N` support—stuck at seconds (e.g., `1740075324.N`).
  2. **`gdate`** (GNU `date`):
     - `PS4='+$(/opt/homebrew/bin/gdate "+%s.%N") '`
     - 1000 loops: ~2.5-4ms/line (e.g., `0.00247884s` for `echo`).
     - Overhead: ~3ms/call—masks ~10µs/loop.
  3. **`perl` with `clock_gettime`**:
     - `PS4='+$(/usr/bin/perl -MTime::HiRes=clock_gettime,CLOCK_MONOTONIC -e "printf \"%.9f\\n\", clock_gettime(CLOCK_MONOTONIC)") '`
     - ~5-8ms/line (e.g., `0.005847s` for `echo`).
     - Overhead: ~5ms—worse than `gdate`.
  4. **Custom `tick.c`**:
     - Compiled C binary for `clock_gettime`: `./tick`
     - `PS4='+$(./tick) '`
     - ~2-4ms/line (e.g., `0.00271s` for `echo`).
     - Overhead: ~2ms—best yet, but still swamps script.
- **Challenges**:
  - Quoting hell: `PS4` expansion varied (`dash` vs. `zsh` quirks).
  - Fork overhead: External calls (e.g., 2-5ms) dwarf native ops (~10µs).
- **Finding**: `echo "result_$i" > /dev/null` hinted as slowest, but clock noise obscured true diffs.

## Hyperfine: Chunked Benchmarking
- **Method**: `hyperfine --runs 10` on script variants (1000 loops):
  - No I/O: `"i=0; while [ \$i -lt 1000 ]; do i=\$((i + 1)); done"`
  - With `echo`: `"i=0; while [ \$i -lt 1000 ]; do i=\$((i + 1)); echo result_\$i > /dev/null; done"`
- **Results**:
  - No I/O: 2.5ms ± 0.3ms (~2.5µs/loop; 1.7ms user, 0.6ms system).
  - With `echo`: 12.2ms ± 0.3ms (~12.2µs/loop; 3.4ms user, 8.6ms system).
  - `echo` cost: ~9.7µs (~80% of added time).
- **Finding**: Cleanly isolates `echo` as bottleneck—matches `time` data, no per-line noise.

## Lessons Learned
- **Clock Overhead**: `PS4` with `gdate` (~3ms), `perl` (~5ms), or `tick` (~2ms) overwhelms script runtime (~10µs/loop)—useless for fine profiling.
- **Best Tool**: `hyperfine`—sparse, accurate, no fork bloat.
- **dash Speed**: ~4.8x faster without I/O (~2µs vs. ~12µs with `echo`)—ideal for compute, not I/O-heavy tasks.
- **Bottleneck**: `echo "result_$i" > /dev/null` (~9µs, 80% system)—I/O’s the killer, not `dash` logic.

## Recommendation
- Use `hyperfine` for shell profiling—`PS4` tracing’s too coarse. For `dash` speed, minimize I/O (e.g., buffer outputs).
