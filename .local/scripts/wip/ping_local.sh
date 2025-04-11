#!/bin/bash

# Array to hold IPs that respond
declare -a responded_ips

# Function to ping an IP with extremely short timeout and add to array if it responds
ping_ip() {
  if ping -c 1 -W 0.1 "$1" >/dev/null 2>&1; then
    responded_ips+=("$1")
    echo "$1 is up"
  fi
}

export -f ping_ip # Export the function for GNU Parallel to use

# Generate IP addresses and ping them in parallel
for i in {11..254}; do
  echo "192.168.1.$i"
done | parallel -j 20 --bar ping_ip
