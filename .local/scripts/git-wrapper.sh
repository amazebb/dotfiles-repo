#!/usr/bin/env bash
# Manage dotfiles with Git bare repo.

# <<< is a here-string in Bash
# Feeds a string directly to a command's stdin
# Equivalent to: echo "$(git config ...)" | IFS=',' read -r -a tracked_files
# More efficient, avoids pipe/subshell
GIT_BINARY="$(brew --prefix)/bin/git"
IFS=',' read -r -a DOTFILES_TRACKED_FOLDERS <<<"$("$GIT_BINARY" config --global --get dotfiles.tracked-folders)"

# Check if PWD is HOME or within DOTFILES_TRACKED_FOLDERS
if [[ $PWD == "$HOME" ]]; then
  is_tracked=1
else
  is_tracked=0
  for folder in "${DOTFILES_TRACKED_FOLDERS[@]}"; do
    folder=${folder/#\~/$HOME}
    if [[ $PWD == "$folder" || $PWD == "$folder"/* ]]; then
      is_tracked=1
      break
    fi
  done
fi

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
      "$GIT_BINARY" --git-dir="$HOME/.git" --work-tree="$HOME" status --porcelain
      "$GIT_BINARY" --git-dir="$HOME/.git" --work-tree="$HOME" ls-files --others --exclude-standard "${DOTFILES_TRACKED_FOLDERS[@]}" | sed 's/^/?? /'
    else
      "$GIT_BINARY" --git-dir="$HOME/.git" --work-tree="$HOME" "$@"
      untracked=$("$GIT_BINARY" --git-dir="$HOME/.git" --work-tree="$HOME" ls-files --others --exclude-standard "${DOTFILES_TRACKED_FOLDERS[@]}")
      if [[ -n $untracked ]]; then
        printf "\n%s\n%s\n" "Untracked files in tracked folders:" '(use "git add <file>..." to include in what will be committed)'
        echo -e "\033[31m"
        # shellcheck disable=SC2001
        echo "$untracked" | sed 's/^/\t/'
        echo -e "\033[0m"
      fi
    fi
  elif [[ $1 == "clean" ]]; then
    exec "$GIT_BINARY" --git-dir="$HOME/.git" --work-tree="$HOME" clean "$@" "${DOTFILES_TRACKED_FOLDERS[@]}"
  else
    exec "$GIT_BINARY" --git-dir="$HOME/.git" --work-tree="$HOME" "$@"
  fi
else
  exec "$GIT_BINARY" "$@"
fi
