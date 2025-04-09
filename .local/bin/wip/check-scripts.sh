#!/bin/dash
# Runs shellcheck on all .sh scripts in ~/.local/bin to identify issues

# Directory to check (fixed to ~/.local/bin)
DIR=~/.local/bin

# Check if shellcheck is installed
if ! command -v shellcheck >/dev/null 2>&1; then
	echo "Error: shellcheck is not installed. Please install it first."
	exit 1
fi

# Find all .sh files and process them
find "$DIR" -type f -name "*.sh" | while read -r script; do
	printf "Checking: %20s" "$(basename "$script")"
	# Run shellcheck and capture output
	output=$(shellcheck "$script" 2>/dev/null)
	if [ -n "$output" ]; then
		echo "$output"
	else
		echo " No issues found"
	fi
done
