#!/bin/bash
# Calculate n-choose-k with option parsing

# Extract script name without path or extension
SCRIPT_NAME=$(basename "$0" .sh)

usage() { 
    echo "Usage: $SCRIPT_NAME [-p] [-h] [-v] -n <number> -k <number>"
    echo "Options:"
    echo "  -p        Pretty print with thousands separator"
    echo "  -h        Show this help message"
    echo "  -v        Show version"
    echo "  -n <num>  Total number of items"
    echo "  -k <num>  Number of items to choose"
    exit 1
}

version() { 
    echo "$SCRIPT_NAME version 0.1"
    exit 0
}

# Validate that the input is a positive integer or report if missing
is_positive_integer() {
    local arg_name="$1"  # Name of the argument (e.g., "n" or "k")
    local value="$2"     # Value to validate

    if [ -z "$value" ]; then
        echo "Error: -$arg_name is required" >&2
        exit 1
    fi

    if [[ ! $value =~ ^[0-9]+$ ]]; then
        echo "Error: -$arg_name '$value' is not a positive integer" >&2
        exit 1
    fi
}

PRETTY=false
N=""
K=""

# Parse options with getopts
while getopts "phvn:k:" opt; do
    case "$opt" in
        p) PRETTY=true ;;
        h) usage ;;
        v) version ;;
        n) N="$OPTARG" ;;
        k) K="$OPTARG" ;;
        ?) usage ;;
    esac
done

# Validate n and k using the updated function
is_positive_integer "n" "$N"
is_positive_integer "k" "$K"

n=$(gseq -s "*" $N -1 `echo "$N-$K+1"|bc` | bc)
d=$(factn $K)
v=$(echo $n/`factn $K` | bc) 

if [ ${PRETTY} ]; then
    printf "%'i\n" $v
else
    echo $v
fi

