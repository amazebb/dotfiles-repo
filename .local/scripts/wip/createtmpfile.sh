#!/bin/bash

# Check if a number is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <number_of_files>"
  exit 1
fi

# Create files
for i in $(seq 1 $1); do
  touch "tmp_${i}.txt"
done
