#!/bin/bash
# Used for adding dotfiles in home directory to git bare repo
# File: /Users/x626f/.local/scripts/dotfiles.sh

DOTFILES_TRACKED_FOLDERS=("$HOME/.local/scripts" "$HOME/.config/nvim")

# Check if PWD is HOME or within DOTFILES_TRACKED_FOLDERS
if [[ "$PWD" == "$HOME" ]]; then
  is_tracked=1
else
  is_tracked=0
  for folder in "${DOTFILES_TRACKED_FOLDERS[@]}"; do
    if [[ "$PWD" == "$folder" || "$PWD" == "$folder"/* ]]; then
      is_tracked=1
      break
    fi
  done
fi

if [[ "$1" == "git-cmd" ]]; then
  # is_git_repo=$(git rev-parse --is-inside-work-tree 2>/dev/null && echo "true" || echo "false")
  if [[ $is_tracked -eq 1 ]]; then
    echo "/Users/x626f/.local/scripts/dotfiles.sh"
  elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "/opt/homebrew/bin/git"
  else
    echo ""
  fi
  exit 0
fi

if [[ $is_tracked -eq 1 ]]; then
  if [[ "$1" == "status" ]]; then
    if [[ "$2" == "--porcelain" ]]; then
      git --git-dir="$HOME/.git" --work-tree="$HOME" status --porcelain
      git --git-dir="$HOME/.git" --work-tree="$HOME" ls-files --others --exclude-standard "${DOTFILES_TRACKED_FOLDERS[@]}" | sed 's/^/?? /'
    else
      git --git-dir="$HOME/.git" --work-tree="$HOME" "$@"
      untracked=$(git --git-dir="$HOME/.git" --work-tree="$HOME" ls-files --others --exclude-standard "${DOTFILES_TRACKED_FOLDERS[@]}")
      if [[ -n "$untracked" ]]; then
        printf "\n%s\n%s\n" "Untracked files in tracked folders:" '(use "git add <file>..." to include in what will be committed)'
        echo -e "\033[31m"
        # shellcheck disable=SC2001
        echo "$untracked" | sed 's/^/\t/'
        echo -e "\033[0m"
      fi
    fi
  elif [[ "$1" == "clean" ]]; then
    git --git-dir="$HOME/.git" --work-tree="$HOME" clean "$@" "${DOTFILES_TRACKED_FOLDERS[@]}"
  else
    git --git-dir="$HOME/.git" --work-tree="$HOME" "$@"
  fi
else
  git "$@"
fi
