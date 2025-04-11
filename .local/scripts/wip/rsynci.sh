#!/bin/bash

# Function to display help
display_help() {
	echo "Usage: $0 [source_path] [destination_path]"
	echo
	echo "Options:"
	echo "  -h      Display this help message."
	echo
	echo "This script will first run rsync in "dry-run" (-n) and "itemize-changes" (-i) modes to list the changes."
	echo "It then loops through each change, prompting the user for confirmation."
	echo "If the user confirms, only that specific file will be synced."
	echo "Replace /path/to/source/ and /path/to/destination/ with your actual paths."

	exit 0
}

# Check for -h option for help
if [[ "$1" == "-h" ]]; then
	display_help
fi

# Check for sufficient number of arguments
if [[ "$#" -ne 2 ]]; then
	echo "Error: Missing source and/or destination path."
	display_help
fi

# Run rsync in dry-run and itemize-changes mode
changes=$(rsync -ain "$1/" "$2/")

# Check if there are changes
if [ -z "$changes" ]; then
	echo "No changes."
	exit 0
fi

# Loop through each line of changes
echo "$changes" | while read -r line; do
	if [ ! -z "$line" ]; then
		echo "Detected change: $line"
		read -p "Proceed with this change? (y/n) " -n 1 -r
		echo

		if [[ $REPLY =~ ^[Yy]$ ]]; then
			file=$(echo $line | awk '{print $2}')
			rsync -a "$1/$file" "$2/$file"
		fi
	fi
done
