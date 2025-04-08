#!/bin/bash

# gitea-backup.sh: Backs up ~/.gitea-data to SPARSE image bundle in iCloud

# Version
VERSION="1.0.0"

# Help function
usage() {
    echo "Usage: gitea-backup [options]"
    echo "Options:"
    echo "  -h    Display this help message"
    echo "  -v    Display version information"
    echo "  -s    Sparse bundle folder (default: $HOME/Library/Mobile Documents/com~apple~CloudDocs/SPARSE.sparsebundle)"
    echo "  -m    Mount point (default: /Volumes/SPARSE)"
    echo "  -d    Gitea data folder (default: $HOME/.gitea-data)"
    exit 0
}

# Version function
version() {
    echo "$VERSION"
    exit 0
}

# Check if no arguments are provided
if [[ $# -eq 0 ]]; then
    usage
fi

s="$HOME/Library/Mobile Documents/com~apple~CloudDocs/SPARSE.sparsebundle"
m="/Volumes/SPARSE"
d="$HOME/.gitea-data"

# Parse options with getopts
while getopts "hvs:m:d:" opt; do
    case "$opt" in
        h) usage ;;
        v) version ;;
        s) s="$OPTARG" ;;
        m) m="$OPTARG" ;;
        d) d="$OPTARG" ;;
        ?) usage ;;
    esac
done

# Shift past the options
shift $((OPTIND-1))


# Main script logic here
echo "Script running with the following arguments:"
echo "-s: $s"
echo "-m: $m"
echo "-d: $d"

# Add your script logic below
#
# 7z a -t7z -m0=lzma2 -mx=9 -mmt=on "$TEMP_FILE" "$GITEA_DATA"
