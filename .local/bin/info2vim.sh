#!/bin/dash
# Launch GNU info for a coreutils command and pipe to Neovim
# Usage: info2vim <command> (e.g., info2vim uniq)

help() {
	echo "info2vim - View coreutils info pages in Neovim"
	echo "Usage: info2vim <command>"
	echo "  <command>    Coreutils command (e.g., uniq, sort)"
	echo "  --help       Show this help message"
	echo "Example: info2vim uniq"
}

# Check no arg or --help
[ -z "$1" ] || [ "$1" = "--help" ] && {
	help
	exit 0
}

# Run info, pipe to nvim, hide stderr
info coreutils "$1" invocation 2>/dev/null | nvim -
