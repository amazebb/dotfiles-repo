#!/bin/dash
# List all scripts in ~/.local/bin with a description

# Directory to search for scripts (default is ~/.local/bin)
DIR=${1:-~/.local/bin}

# Find all .sh files and process them
find "$DIR" -type f -depth 1 -name "*.sh" | sort -k1 | while read -r script; do
	# Get the script name (basename removes the path)
	name=$(basename "$script")

	# Determine script type from shebang (first line)
	shebang=$(head -n 1 "$script")
	case "$shebang" in
	*bash) type="bash" ;;
	*zsh) type="zsh" ;;
	*dash) type="dash" ;;
	*sh) type="sh" ;;
	*) type="unknown" ;;
	esac

	# Extract the first comment line that starts with # (ignoring shebang)
	desc=$(grep "^#[^!]" "$script" | head -n 1 | sed 's/^# *//')

	# If no description found, use a placeholder
	desc=${desc:-"No description available"}

	# Print formatted output: name, type, and description
	printf "%-20s %-8s %s\n" "$name" "$type" "$desc"
done
