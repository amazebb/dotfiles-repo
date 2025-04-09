#!/bin/bash

# Backs up folders to SPARSE image bundle in iCloud

# Version
VERSION="1.0.0"

# Help function
usage() {
  echo "Usage: data-backup folder1 [folder2 ...] [options]"
  echo "Options:"
  echo "  -h    Display this help message"
  echo "  -v    Display version information"
  echo "  -s    Sparse bundle folder (default: $HOME/Library/Mobile Documents/com~apple~CloudDocs/SPARSE.sparsebundle)"
  echo "  -m    Mount point (default: /Volumes/SPARSE)"
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

SPARSE_BUNDLE="$HOME/Library/Mobile Documents/com~apple~CloudDocs/SPARSE.sparsebundle"
MOUNT_POINT="/Volumes/SPARSE"
FOLDERS=()

# Parse options with getopts
while getopts "hvs:m:" opt; do
  case "$opt" in
    h) usage ;;
    v) version ;;
    s) SPARSE_BUNDLE="$OPTARG" ;;
    m) MOUNT_POINT="$OPTARG" ;;
    ?) usage ;;
  esac
done

# Shift past the options
shift $((OPTIND-1))

# Collect remaining arguments as folder names
while [[ $# -gt 0 ]]; do
  FOLDERS+=("$1")
  shift
done

# Ensure at least one folder is provided
if [[ ${#FOLDERS[@]} -eq 0 ]]; then
  echo "Error: At least one folder name is required"
  usage
fi

# Example: Print what we got (replace with your backup logic)
printf "Folders to backup: %s\n" "${FOLDERS[*]}"
echo "Sparse bundle: $SPARSE_BUNDLE"
echo "Mount point: $MOUNT_POINT"
# 7z a -t7z -m0=lzma2 -mx=9 -mmt=on "$TEMP_FILE" "$GITEA_DATA"
#
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

SPARSE_BUNDLE="$HOME/Library/Mobile Documents/com~apple~CloudDocs/SPARSE.sparsebundle"
MOUNT_POINT="/Volumes/SPARSE"
BACKUP_NAME="gitea-backup-$(date +%Y%m%d_%H%M%S).7z"
TEMP_FILE="/tmp/$BACKUP_NAME"
DEST_FILE="$MOUNT_POINT/$BACKUP_NAME"

read -r -s -p "Enter sparse bundle password: " PASSWORD
echo

echo "Debug: Checking sparse bundle at $SPARSE_BUNDLE"
if [ ! -f "$SPARSE_BUNDLE" ]; then
  echo "Error: Sparse bundle file not found"
  exit 1
fi
if [ ! -r "$SPARSE_BUNDLE" ]; then
  echo "Error: No read permission for sparse bundle"
  exit 1
fi

if [ -d "$MOUNT_POINT" ]; then
  if ! diskutil info "$MOUNT_POINT" | grep -q "$SPARSE_BUNDLE"; then
    echo "Error: $MOUNT_POINT exists but isn’t our sparse bundle"
    exit 1
  fi
else
  if ! echo "$PASSWORD" | hdiutil attach "$SPARSE_BUNDLE" -mountpoint "$MOUNT_POINT" -stdinpass -verbose 2> mount_error.log; then
    echo "Error: Failed to mount sparse bundle"
    cat mount_error.log
    rm mount_error.log
    exit 1
  fi
fi

if ! gitea-cli stop; then 
  echo "Error: Failed to stop Gitea"
  hdiutil detach "$MOUNT_POINT"
  exit 1
fi

for FOLDER in "${FOLDERS[@]}"; do
    FULL_PATH=$(realpath "$FOLDER")
    BASE_NAME=$(echo "$FULL_PATH" | tr '/' '_')
    TEMP_FILE="/tmp/$BASE_NAME-$(date +%Y%m%d_%H%M%S).7z"
    DEST_FILE="$MOUNT_POINT/$BASE_NAME-$(date +%Y%m%d_%H%M%S).7z"
    META_FILE="$MOUNT_POINT/$BASE_NAME-$(date +%Y%m%d_%H%M%S).txt"

    if ! /opt/homebrew/bin/7z a -t7z -m0=lzma2 -mx=9 -mmt=on "$TEMP_FILE" "$FOLDER"; then
        echo "Error: Failed to compress $FOLDER, skipping"
        continue
    fi

    echo "$FULL_PATH" > "$TEMP_FILE.meta"

    if ! rsync --archive --xattrs --acls --hard-links --progress "$TEMP_FILE" "$DEST_FILE" "$TEMP_FILE.meta" "$META_FILE"; then
        echo "Error: rsync failed for $TEMP_FILE, skipping"
        rm "$TEMP_FILE" "$TEMP_FILE.meta"
        continue
    fi

    rm "$TEMP_FILE" "$TEMP_FILE.meta"
done

if ! hdiutil detach "$MOUNT_POINT"; then
    echo "Warning: Failed to unmount sparse bundle"
fi
