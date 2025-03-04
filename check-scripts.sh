#!/bin/bash
# Runs shellcheck on all .sh scripts in a specified directory (default ~/.local/bin) to identify issues

# Help function
usage() {
	echo "Usage: $(basename "$0") [-h] [-v] [directory]"
	echo "Options:"
	echo "  -h    Display this help message"
	echo "  -v    Verbose mode, show full shellcheck output"
	echo "Arguments:"
	echo "  directory  Directory to search for .sh scripts (default: ~/.local/bin)"
	exit 0
}

# Default values
DIR=~/.local/bin
VERBOSE=false

# Parse options with getopts
while getopts "hv" opt; do
	case "$opt" in
		h) usage ;;
		v) VERBOSE=true ;;
		?) usage ;;
	esac
done

# Shift past the options
shift $((OPTIND-1))

# If a directory is provided as an argument, use it
if [ $# -gt 0 ]; then
	DIR="$1"
fi

# Check if the directory exists
if [ ! -d "$DIR" ]; then
	echo "Error: Directory '$DIR' does not exist."
	exit 1
fi

# Check if shellcheck is installed
if ! command -v shellcheck >/dev/null 2>&1; then
	echo "Error: shellcheck is not installed. Please install it first."
	exit 1
fi

# Initialize counters
total_files=0
files_with_issues=0
files_without_issues=0

# Collect files into an array
# An explanation: 
# find ... -print0 outputs filenames separated by null bytes, which handles spaces, newlines, etc., safely.
# while IFS= read -r -d '' file reads null-delimited input into the files array.
# < <(...) (process substitution) avoids a subshell, so the array is populated in the main shell.
files=()
max_basename_length=0
while IFS= read -r -d '' file; do
	files+=("$file")
	basename=$(basename "$file")
	basename_length=${#basename}
	if [ "$basename_length" -gt "$max_basename_length" ]; then
		max_basename_length=$basename_length
	fi
done < <(find "$DIR" -type f -name "*.sh" -print0)

# Add some padding for safety (e.g., +2 for extra space)
pad=$((max_basename_length + 2))

dashed_line=$(printf "%-*s" "$(tput cols)" "" | tr ' ' '-')

printf "Running ShellCheck on scripts in %s\n\n" "$DIR"

# Iterate over the array
for script in "${files[@]}"; do
	total_files=$((total_files + 1))
	output=$(shellcheck "$script" 2>/dev/null)
	if [ -n "$output" ]; then
		files_with_issues=$((files_with_issues + 1))
		printf "%s\n%-${pad}s" "$dashed_line" "$(basename "$script")"
		if [ "$VERBOSE" = "true" ]; then
			printf "\n%s\n%s\n" "$dashed_line" "$output" 
		else
			printf "\033[31m Issues Found\033[0m\n"
		fi
	else
		files_without_issues=$((files_without_issues + 1))
		if [ "$VERBOSE" = "false" ]; then
			printf "%-${pad}s No issue found\n" "$(basename "$script")"
		fi
	fi
done

# Display summary
printf "\nSummary:\n"
printf "Total files checked: %d\n" "$total_files"
printf "Files with issues: %d\n" "$files_with_issues"
printf "Files without issues: %d\n" "$files_without_issues"
