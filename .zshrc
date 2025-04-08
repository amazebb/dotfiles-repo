# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

## Setup the hsitory
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory
setopt HIST_IGNORE_ALL_DUPS

# Setup history search using the up/down keys
# Matches the characters from the beginning of the line
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# Prevent 'less' from saving command history
export LESSHISTFILE=-

## Terminal 
export PS1="%m:%n:%~ $ "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export TERM="xterm-256color"

## Set preview for nnn 
export NNN_FIFO=/tmp/nnn.fifo

## Environment Variables
# MATLAB
# Tell MATLAB to use the MacOS Accelerate framework
export BLAS_VERSION=libmwAF_BLAS_ilp64.dylib
# MATLAB >= 23b If we switch to JRE 8 we need to append the /jre folder
export MATLAB_JAVA=/Users/x626f/.sdkman/candidates/java/21.0.6-tem

# If you ever reinstall Gitea and want it to default to ~/.gitea-data without extra flags
export GITEA_WORK_DIR="$HOME/.gitea-data"

# PATH
export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/node@16/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/Users/x626f/.lmstudio/bin"

# Aliases
alias ls="ls -GFh"
alias brewup="brew update && brew upgrade"
alias dotfiles="/opt/homebrew/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Setup for zoxide smarter 'cd'
eval "$(zoxide init zsh)"

# Setup for fzf
eval "$(fzf --zsh)"

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

create_aliases() {
    for script in ~/.local/bin/*.sh; do
        base_name=$(basename "$script" .sh)
        alias "$base_name"="\"$script\""
    done
}

# Call the function to create aliases when zsh starts
create_aliases

source ~/Code/GitHub/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export POWERLEVEL9K_DISABLE_GITSTATUS=true
