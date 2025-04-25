# Setup the hsitory
HISTFILE=~/.zsh_history
HISTSIZE=10000
# To disbale shelcheck SAVEHIST warning:
# shellcheck disable=SC2034
SAVEHIST=10000
setopt appendhistory
setopt HIST_IGNORE_ALL_DUPS

# Setup history search using the up/down keys
# Matches the characters from the beginning of the line
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# Prevent 'less' from saving command history
export LESSHISTFILE=-

# shellcheck source-path=SCRIPTDIR
source "$HOME"/.local/scripts/zsh_prompt_setup.zsh
setup_prompt
export TERM="xterm-256color"

## Set preview for nnn
export NNN_FIFO=/tmp/nnn.fifo

# Tell MATLAB to use the MacOS Accelerate framework
export BLAS_VERSION=libmwAF_BLAS_ilp64.dylib
export MATLAB_JAVA=/Users/x626f/.sdkman/candidates/java/21.0.6-tem

# If you ever reinstall Gitea and want it to default to ~/.gitea-data without extra flags
export GITEA_WORK_DIR="$HOME/.gitea-data"

# Remove blinking text in the date column
export EZA_COLORS="da=90"

# PATH
export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/node@16/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/Users/x626f/.lmstudio/bin"

# Aliases
alias ls="eza -1 -l -s=name --no-user --no-permissions --group-directories-first --git --git-repos --header --icons=always --color=always"
# Show only dot files and folders, add -D for folders only and -f for files only
alias ls-dot="eza -1 -al -s=name --no-user --no-permissions --group-directories-first --git --git-repos --header --icons=always --color=always --ignore-glob=\"[!.]*\""
alias brewup="brew update && brew upgrade && brew outdated --cask --greedy --verbose"
alias gitd="dotfiles"

# Setup for zoxide smarter 'cd'
eval "$(zoxide init zsh)"

# Setup for fzf
eval "$(fzf --zsh)"

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

create_aliases() {
  for script in ~/.local/scripts/*.sh; do
    base_name=$(basename "$script" .sh)
    # shellcheck disable=SC2139
    alias "$base_name"="$script"
  done
}

# Call the function to create aliases when zsh starts
create_aliases
