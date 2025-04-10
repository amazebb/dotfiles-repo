#!/bin/bash
# Print the ASCII codes given a range of numbers

a=0
b=255
code=WINDOWS-1252
echo "Codes for $code from $a to $b"
for ((i = a; i <= b; i++)); do
	octal=$(printf '\\%03o' "$i")
	char=$(printf %s "$octal" | iconv -f "$code" -t UTF-8 2>/dev/null)
	hex=$(printf "%s" "$char" | od -An -tx1 | tr -d '[:space:]' | sed 's/0a$//')
	printf "%d: %s " $i "$hex"
	printf "%s\n" "$char"
done | column
