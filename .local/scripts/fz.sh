#!/bin/bash

# fz.sh: Search for text in files

# Version
VERSION="1.0.0"

# Help function
usage() {
  echo "Usage: fz"
  echo "Required inputs:"
  echo "  pattern    Search pattern"
  echo "  folders    Search folders"
  echo "[OPTIONAL]"
  echo "  -r    Options for ripgrep"
  echo "  -z    fzf options"
  exit 0
}

# Version function
version() {
  echo "$VERSION"
  exit 0
}

# Check if help or version is requested
if [[ $1 == "-h" ]]; then
  usage
fi
if [[ $1 == "-v" ]]; then
  version
fi

RG_OPTIONS=
FZF_OPTIONS=
# Parse optional arguments with getopts
while getopts "hvr:z:" opt; do
  case "$opt" in
    h) usage ;;
    v) version ;;
    r) RG_OPTIONS="$OPTARG" ;;
    z) FZF_OPTIONS="$OPTARG" ;;
    ?) usage ;;
  esac
done

# Shift past the options
shift $((OPTIND - 1))

# Check required positional inputs
if [[ $# -lt 2 ]]; then
  echo "Error: Missing required positional inputs"
  usage
fi

PATTERN=$1
FOLDERS=$2

# Main script logic here
echo "Script running with the following inputs:"
echo "pattern: $PATTERN"
echo "folders: $FOLDERS"
echo "-r: $RG_OPTIONS"
echo "-z: $FZF_OPTIONS"

# Add your script logic below
rg --no-messages --files-with-matches "${PATTERN}" "${FOLDERS}" | fzf --multi --style full --preview "rg --pretty --context 5 dotfiles {}"
