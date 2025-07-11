#!/usr/bin/env bash

# Check Git respository status

# Version
VERSION="1.0.0"

# Help function
usage() {
  echo "Usage: git-check [options] [path...]"
  echo "Options:"
  echo "  -h, --help    Show this help message"
  echo "  --version     Show version information"
  echo "Arguments:"
  echo "  path...   Path to check"
  exit 0
}

# Version function
version() {
  echo "$VERSION"
  exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h | --help) usage ;;
    --version) version ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *) break ;; # Non-option args (positionals)
  esac
  shift
done

# Main script logic here
echo "Script running with the following inputs:"
echo "path: $*"

max_len=0
declare -a repos=()
while IFS= read -r repodir; do
  if [ -z "$repodir" ]; then continue; fi
  len=${#repodir}
  if ((len > max_len)); then max_len=$len; fi
  repos+=("$repodir")
done < <(fd -H -t d '^\.git$' "$@" | while IFS= read -r gitdir; do dirname "$gitdir"; done | sort -u)
for repodir in "${repos[@]}"; do
  if [ -n "$(git -C "$repodir" status --porcelain)" ]; then
    status=$'\033[31mX\033[0m'
  else
    status="OK"
  fi
  printf "%-${max_len}s  %s\n" "$repodir" "$status"
done
