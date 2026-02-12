## Setup the history
# shellcheck disable=SC2034
HISTFILE=$HOME/.zsh_history # Configure history storage and size parameters
HISTSIZE=200000             # Set maximum number of commands stored in memory for current session
SAVEHIST=200000             # Set maximum number of commands saved to history file on disk
export LESSHISTFILE=-       # Prevent 'less' from saving command history (e.g., when viewing man pages)

# Configure history behavior options
setopt EXTENDED_HISTORY       # Log with Unix timestamps
setopt HIST_EXPIRE_DUPS_FIRST # Remove duplicates from history first when trimming
setopt HIST_IGNORE_DUPS       # Don't add duplicate commands to history
setopt INC_APPEND_HISTORY     # Write to history after each command
setopt SHARE_HISTORY          # Share history across sessions

# Bind Up/Down arrow key to search backward/forward through history for commands starting with current line prefix
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

## Prompt indentation right hand side for RPS1
export ZLE_RPROMPT_INDENT=0

# Configure PATH environment variable
# Add Homebrew, GNU make, gawk, coreutils, Node.js, local bin, and Julia to PATH
export PATH="/opt/local/bin:/opt/homebrew/opt/make/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/node@16/bin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export PATH="$PATH:$HOME/.juliaup/bin:$HOME/.julia/bin"
export PATH="$HOME/.local/bin:$PATH"

## Environment variables
# Tell MATLAB to use the macOS Accelerate framework
export BLAS_VERSION=libmwAF_BLAS_ilp64.dylib
export MATLAB_JAVA=$HOME/.sdkman/candidates/java/21.0.8-tem
# MATLAB JRE Setup
# 1. Update the MATLAB_JAVA version
# 2. source ~/.zshrc
# 3. /Applications/MATLAB_R2024b.app/bin/matlab -batch "jenv(getenv('MATLAB_JAVA'))"
# After this step MATLAB can be started as a regular application

export GITEA_WORK_DIR="$HOME/.gitea-data"
export EDITOR="$HOME/.local/bin/nvim"
export CHPL_HOME=/opt/homebrew/Cellar/chapel/2.5.0_1

## Aliases
# Homebrew
if command -v brew &>/dev/null; then
    alias brewup="brew update && brew upgrade && brew outdated --cask --greedy --verbose"
    alias brewlist="{brew leaves -r | xargs brew desc 2>/dev/null | sed 's/:/\t/1;s/^/brew /'; brew list --cask | xargs brew desc 2>/dev/null | sed 's/:/\t/1;s/^/cask /'; brew tap| sed 's/^/tap  /;s/$/\t/'} | column -t -s $'\t'"
else
    printf "Install homebrew ? (y/N) " && read -r && [[ $REPLY =~ ^[Yy]$ ]] && /bin/bash -c\
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Copies Apple Notes while retaining newline which would otherwise be copied
# over as <2028>, (U+2028) is the Unicode Line Separator
# To use copy selection in Apple Notes, then run "cpnotes" in the terminal
[[ $OSTYPE == *darwin* ]] && alias cpnotes='pbpaste | sed "s/\xe2\x80\xa8/\n/g" | pbcopy'

# Eza
if command -v eza &>/dev/null; then
    alias l="eza -1lh -s=name --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always"
    # Show only dot files and folders, add -D for folders only, and -f for files only
    alias ll="eza -1alh -s=name --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always -I=\"[!.]*\""
    alias llp="eza -D -1alh -s=name --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always -I=\"[!.]*\""
    alias llf="eza -f -1alh -s=name --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always -I=\"[!.]*\""
else
    printf "Install eza ? (y/N) " && read -r && [[ $REPLY =~ ^[Yy]$ ]] && brew install eza
fi

# Nvim 
if command -v nvim &>/dev/null; then
    alias nn='$HOME/.local/bin/nvim'
else
    printf "Install nvim ? (y/N) " && read -r && [[ $REPLY =~ ^[Yy]$ ]] && brew install neovim
fi

# Zoxide
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
else
    printf "Install zoxide ? (y/N) " && read -r && [[ $REPLY =~ ^[Yy]$ ]] && brew install zoxide
fi


# Fzf key bindings and completion
# shellcheck disable=SC1090
if command -v fzf &>/dev/null; then
    # Bind ? Key for toggling the fzf preview window, useful for long commands that don't fit on screen
    # CTRL-T - Paste the selected files and directories onto the command-line
    # CTRL-R - Paste the selected command from history onto the command-line
    # ALT-C  - cd into the selected directory
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview' --no-mouse"
    source <(fzf --zsh)
else
    printf "Install fzf ? (y/N) " && read -r && [[ $REPLY =~ ^[Yy]$ ]] && brew install fzf
fi

# Fzf-man ^h binding for man pages
[[ -s "$HOME/.local/bin/fzf-man" ]] && source "$HOME/.local/bin/fzf-man"

# Nnn
[[ -s $HOME/.local/bin/nnn-split ]] && alias n='source $HOME/.local/bin/nnn-split'

# Dotfiles
(( ${+functions[dotfiles]} )) && alias dg=dotfiles

# Prompt
[[ -s $HOME/.local/share/zsh-prompt/zsh_prompt ]] && source "$HOME/.local/share/zsh-prompt/zsh_prompt"

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# Initialize SDKMAN for Java version management
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
