#!/bin/bash
# Used for adding dotfiles in home directory to git bare repo

DOTFILES_TRACKED_FOLDERS=("$HOME/.local/bin" "$HOME/.config/nvim")
if [[ "$PWD" == "$HOME" ]]; then
  if [[ "$1" == "status" ]]; then
    if [[ "$2" == "--porcelain" ]]; then
      /opt/homebrew/bin/git --git-dir="$HOME/.git" --work-tree="$HOME" status --porcelain
      /opt/homebrew/bin/git --git-dir="$HOME/.git" --work-tree="$HOME" ls-files --others --exclude-standard "${DOTFILES_TRACKED_FOLDERS[@]}" | sed 's/^/?? /'
    else
      /opt/homebrew/bin/git --git-dir="$HOME/.git" --work-tree="$HOME" "$@"
      printf "\n%s\n%s" "Untracked files in tracked folders:" '(use "git add <file>..." to include in what will be committed)'
      echo -e "\033[31m"
      /opt/homebrew/bin/git --git-dir="$HOME/.git" --work-tree="$HOME" ls-files --others --exclude-standard "${DOTFILES_TRACKED_FOLDERS[@]}" | sed 's/^/\t/'
      echo -e "\033[0m"
    fi
  else
    /opt/homebrew/bin/git --git-dir="$HOME/.git" --work-tree="$HOME" "$@"
  fi
else
  /opt/homebrew/bin/git "$@"
fi
