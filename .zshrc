# Setup the history
HISTFILE=~/.zsh_history
HISTSIZE=10000
# shellcheck disable=SC2034
SAVEHIST=10000
setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt INC_APPEND_HISTORY # Write to history after each command
setopt SHARE_HISTORY      # Share history across sessions
unsetopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE

# Setup history search using the up/down keys
# Matches the characters from the beginning of the line
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# Prevent 'less' from saving command history
# no trace of less interactions (e.g., when viewing man pages)
export LESSHISTFILE=-

# Set zsh prompt
# shellcheck source-path=SCRIPTDIR
export TERM="xterm-256color"
source "$HOME"/.local/scripts/zsh_prompt_setup.zsh
setup_prompt

# Set preview for nnn
export NNN_FIFO=/tmp/nnn.fifo

# Tell MATLAB to use the MacOS Accelerate framework
export BLAS_VERSION=libmwAF_BLAS_ilp64.dylib
export MATLAB_JAVA=$HOME/.sdkman/candidates/java/21.0.7-tem

# If we reinstall Gitea default to ~/.gitea-data
export GITEA_WORK_DIR="$HOME/.gitea-data"

# Remove blinking text in the date column
export EZA_COLORS="da=90"

# PATH
export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/node@16/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.juliaup/bin"

# Aliases
alias ls="eza -1lh -s=name --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always"
# Show only dot files and folders, add -D for folders only and -f for files only
alias ls-dot="eza -1alh -s=name --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always -I=\"[!.]*\""
alias brewup="brew update && brew upgrade && brew outdated --cask --greedy --verbose"
alias dot="dotfiles"
alias nn="~/.nvim-nightly/nvim-macos-arm64/bin/nvim"

# Setup for zoxide smarter 'cd'
eval "$(zoxide init zsh)"

# Set up fzf key bindings and fuzzy completion
# shellcheck disable=SC1090
source <(fzf --zsh)

# Source fzf-man-widget script
# shellcheck disable=SC1090
source ~/.local/scripts/fzf-man.zsh

# Bind Ctrl-H to launch the fzf-man widget
bindkey '^h' fzf-man

# Alias to run fzf-man-widget function
alias fzfman='fzf-man'

# Create aliases without .sh for ~/.local/scripts/*.sh files
create_aliases() {
  for script in ~/.local/scripts/*.sh; do
    base_name=$(basename "$script" .sh)
    # shellcheck disable=SC2139
    alias "$base_name"="$script"
  done
}
create_aliases

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
