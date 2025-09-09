#!/usr/bin/env bash
# Manage dotfiles with Git bare repo.

GIT_BINARY=$(command -v git) || {
  echo "Error: Git not found" >&2
  exit 1
}

DOTFILES_GIT="$GIT_BINARY --git-dir=$HOME/.git --work-tree=$HOME"

tracked_folders=$("$GIT_BINARY" config --global --get dotfiles.tracked-folders)
if [[ -z $tracked_folders ]]; then
  DOTFILES_TRACKED_FOLDERS=()
else
  # <<< is a here-string in Bash
  # Feeds a string directly to a command's stdin
  # Equivalent to: echo "$(git config ...)" | IFS=',' read -r -a tracked_files
  # More efficient, avoids pipe/subshell
  IFS=',' read -r -a DOTFILES_TRACKED_FOLDERS <<<"$tracked_folders"
fi

# Check if PWD is HOME or within DOTFILES_TRACKED_FOLDERS
if [[ $PWD == "$HOME" ]]; then
  is_tracked=1
else
  is_tracked=0
  for folder in "${DOTFILES_TRACKED_FOLDERS[@]}"; do
    folder=${folder/#\~/$HOME}
    if [[ $(realpath "$PWD") == $(realpath "$folder")* ]]; then
      is_tracked=1
      break
    fi
  done
fi

# Return whether git-wrapper or git binary is being used
if [[ $1 == "git-cmd" ]]; then
  if [[ $is_tracked -eq 1 ]]; then
    echo "$HOME/.local/scripts/git-wrapper.sh"
  elif [[ $("$GIT_BINARY" rev-parse --is-inside-work-tree 2>/dev/null) == "true" ]]; then
    echo "$GIT_BINARY"
  else
    echo ""
  fi
  exit 0
fi

if [[ $is_tracked -eq 1 ]]; then
  if [[ $1 == "status" ]]; then
    if [[ $2 == "--porcelain" ]]; then
      $DOTFILES_GIT status --porcelain
      $DOTFILES_GIT ls-files --others --exclude-standard "${DOTFILES_TRACKED_FOLDERS[@]}" | sed 's/^/?? /'
    else
      $DOTFILES_GIT "$@"
      untracked=$($DOTFILES_GIT ls-files --others --exclude-standard "${DOTFILES_TRACKED_FOLDERS[@]}")
      if [[ -n $untracked ]]; then
        printf "\n%s\n%s\n" "Untracked files in tracked folders:" '(use "git add <file>..." to include in what will be committed)'
        echo -e "\033[31m"
        # shellcheck disable=SC2001
        echo "$untracked" | sed 's/^/\t/'
        echo -e "\033[0m"
      fi
    fi
  elif [[ $1 == "clean" ]]; then
    exec $DOTFILES_GIT clean "$@" "${DOTFILES_TRACKED_FOLDERS[@]}"
  else
    exec $DOTFILES_GIT "$@"
  fi
else
  exec "$GIT_BINARY" "$@"
fi
