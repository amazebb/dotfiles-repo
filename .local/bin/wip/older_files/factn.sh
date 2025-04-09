#!/bin/bash

bc <<< "result=1; for(i=1; i<=$1; i++) result *= i; result"

# The exponenet is given by piping the above result
# factn | sed 's/[^0-9]//g' | tr -d '\n' | wc -c
