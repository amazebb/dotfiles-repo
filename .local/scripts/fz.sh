#!/opt/homebrew/bin/bash

# Search for text in files interactively using ripgrep and fzf
VERSION="1.0.0"

# Help function
usage() {
  echo "Usage: fz"
  echo "Required inputs:"
  echo "  pattern    Search pattern"
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

# Parse optional arguments with getopts
while getopts "hv" opt; do
  case "$opt" in
    h) usage ;;
    v) version ;;
    ?) usage ;;
  esac
done

# Shift past the options
shift $((OPTIND - 1))

# Check required positional inputs
if [[ $# -lt 1 ]]; then
  echo "Error: Missing required positional inputs"
  usage
fi

PATTERN=$1

# This is taken from https://junegunn.github.io/fzf/tips/ripgrep-integration/
RELOAD="reload:rg --column --line-number --no-heading --color=always --smart-case {q} || :"

# shellcheck disable=SC2016
OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            nvim {1} +{2}     # No selection. Open the current line in Vim.
          else
            nvim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'

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
  --preview 'bat --theme=auto:system --style=full --wrap=character --color=always --highlight-line {2} {1}' \
  --preview-window '~4,+{2}+4/3,<80(up)' \
  --query "$PATTERN"
