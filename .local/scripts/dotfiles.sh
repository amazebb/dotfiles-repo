#!/bin/bash
# Used for adding dotfiles in home directory to git bare repo

DOTFILES_TRACKED_FOLDERS=("$HOME/.local/scripts" "$HOME/.config/nvim")
if [[ "$PWD" == "$HOME" ]]; then
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
