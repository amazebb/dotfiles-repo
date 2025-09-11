#!/usr/bin/env bash
# Search text interactively with ripgrep, fzf.
VERSION="1.0.0"

# Help function
usage() {
  echo "Usage: fz [OPTIONAL] pattern"
  echo "Arguments:"
  echo "  pattern   Search pattern"
  echo "Optional:"
  echo "  -r        ripgrep option (e.g., \"-g '*.{pdf,zsd}'\")"
  echo "  -h        Help"
  echo "  -v        Version"
  echo "Examples:"
  echo "  fz \"-g '*.pdf'\" pattern   Search for 'pattern' in PDF files"
  echo "  fz -- -g                    Search for literal '-g'"
  exit 0
}

# Version function
version() {
  echo "$VERSION"
  exit 0
}

PRE_RG="--pre ~/.local/scripts/pre-rg.sh --pre-glob '*.{pdf}'"

# Parse optional arguments with getopts
while getopts "hvr:" opt; do
  case "$opt" in
    h) usage ;;
    v) version ;;
    r) PRE_RG="$PRE_RG $OPTARG" ;;
    ?) usage ;;
  esac
done
# Shift past the options
shift $((OPTIND - 1))

# Check required positional inputs
[[ $# -lt 1 ]] && {
  echo "Error: Missing pattern" >&2
  usage
}

PATTERN=$1

RELOAD="reload:rg $PRE_RG --column --line-number --no-heading --color=always --smart-case {q} || :"
# dotgit="$HOME/.local/scripts/git-wrapper.sh"
#
# # Check if in dotfiles bare repo by inspecting git git-cmd output
# if "$dotgit" git-cmd 2>/dev/null | grep -q "bin/git$"; then
#   # Not in dotfiles repo, use standard ripgrep behavior
#   RELOAD="reload:rg $PRE_RG --hidden --column --line-number --no-heading --color=always --smart-case {q} || :"
# else
#   # Temporary file for storing file list
#   TMP_FILE=$(mktemp)
#
#   # In dotfiles repo, use git ls-files with absolute paths
#   "$dotgit" ls-files --cached --others --exclude-standard | while IFS= read -r line; do
#     realpath "$HOME/$line"
#   done >"$TMP_FILE"
#
#   # Modified reload command to use pre-generated file list
#   RELOAD="reload:rg \$PRE_RG --column --line-number --no-heading --color=always --smart-case {q} \$(cat \$TMP_FILE) || :"
# fi
#
# shellcheck disable=SC2016
OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            nvim {1} +{2}     # No selection. Open the current line in Vim.
          else
            nvim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'

# shellcheck disable=SC2034
BAT_OPTS="--theme=TwoDark --style=full --wrap=character --color=always --highlight-line {2}"
# shellcheck disable=SC2016
PREVIEW='case {1} in *.pdf) ~/.local/scripts/pre-rg.sh {1} | nl -ba -w1 -s" " | bat $BAT_OPTS ;; *) bat $BAT_OPTS {1} ;; esac'

# shellcheck disable=SC2016
fzf --disabled --ansi --multi \
  --bind "start:$RELOAD" --bind "change:$RELOAD" \
  --bind "enter:become:$OPENER" \
  --bind "ctrl-o:execute:$OPENER" \
  --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-p:toggle-preview' \
  --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
      echo "rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
      echo "unbind(change)+change-prompt(2. fzf> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
  --prompt '1. ripgrep> ' \
  --delimiter : \
  --header 'CTRL-T: Switch between ripgrep/fzf 
ALT-A: Select-all, ALT-D: Deselect-all, CTRL-P: Toggle-preview' \
  --style full \
  --layout=reverse-list \
  --preview "$PREVIEW" \
  --preview-window '~4,+{2}+4/3,<80(up)' \
  --query "$PATTERN"
