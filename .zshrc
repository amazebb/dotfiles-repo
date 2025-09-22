## Setup the history
# Configure history storage and size parameters
HISTFILE=~/.zsh_history
# Set maximum number of commands stored in memory for current session
HISTSIZE=100000
# Set maximum number of commands saved to history file on disk
# shellcheck disable=SC2034
SAVEHIST=100000

# Configure history behavior options
setopt APPEND_HISTORY         # Append history to file instead of overwriting
setopt HIST_EXPIRE_DUPS_FIRST # Remove duplicates from history first when trimming
setopt HIST_IGNORE_DUPS       # Don't add duplicate commands to history
setopt INC_APPEND_HISTORY     # Write to history after each command
setopt SHARE_HISTORY          # Share history across sessions
unsetopt HIST_IGNORE_ALL_DUPS # Allow consecutive duplicates in history
unsetopt HIST_IGNORE_SPACE    # Add commands starting with space to history

# Prevent 'less' from saving command history
# no trace of less interactions (e.g., when viewing man pages)
export LESSHISTFILE=-

# Setup history search using the up/down keys
# Matches the characters from the beginning of the line
# Bind Up arrow key (ANSI escape sequence) to search history backward for commands starting with current line prefix
bindkey "^[[A" history-beginning-search-backward
# Bind Down arrow key (ANSI escape sequence) to search history forward for commands starting with current line prefix
bindkey "^[[B" history-beginning-search-forward

## Aliases
# Define file listing aliases using eza
alias ls="eza -1lh -s=name --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always"
# Show only dot files and folders, add -D for folders only and -f for files only
alias ls-dot="eza -1alh -s=name --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always -I=\"[!.]*\""

# Define Homebrew management aliases
alias brewup="brew update && brew upgrade && brew outdated --cask --greedy --verbose"

# Define git wrapper aliases
alias dg='git-wrapper'
alias gcv="git-wrapper commit -va"

# Define editor and tool aliases
alias nn="~/.nvim-nightly/nvim-macos-arm64/bin/nvim"
alias brewlist="brew leaves -r | xargs brew desc | sed 's/^\([^:]*\):/\1\t/' | column -t -s $'\t' | fzf"

# Set zsh prompt
# Source and initialize custom prompt configuration
source "$HOME"/.zsh_prompt.zsh
setup_prompt

## Environment variables
# Tell MATLAB to use the MacOS Accelerate framework
export BLAS_VERSION=libmwAF_BLAS_ilp64.dylib
# MATLAB JRE Setup
# 1. Update the MATLAB_JAVA version below
# 2. source ~/.zshrc
# 3. Start MATLAB from terminal: /Applications/MATLAB_R2024b.app/bin/matlab
# 4. Run jenv(getenv('MATLAB_JAVA')), close MATLAB and now can restart normally without terminal
export MATLAB_JAVA=$HOME/.sdkman/candidates/java/21.0.8-tem
export GITEA_WORK_DIR="$HOME/.gitea-data"
export EDITOR="/opt/homebrew/bin/nvim"
export CHPL_HOME=/opt/homebrew/Cellar/chapel/2.5.0_1

# Configure PATH environment variable
# Add Homebrew, GNU make, gawk, coreutils, Node.js, local bin, and Julia to PATH
export PATH="/opt/local/bin:/opt/homebrew/opt/make/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/node@16/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.juliaup/bin"

# Setup for zoxide smarter 'cd'
# Initialize zoxide directory navigation tool for zsh
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
# CTRL-T - Paste the selected files and directories onto the command-line
# CTRL-R - Paste the selected command from history onto the command-line
# ALT-C  - cd into the selected directory

# Create aliases without .sh for ~/.local/scripts/*.sh files
# TODO Create alias free version in the future so it can be used in non-interactive shells, but this will do for now
# Define function to automatically create aliases for scripts in ~/.local/scripts/
create_aliases() {
  for script in ~/.local/scripts/*.sh; do
    base_name=$(basename "$script" .sh)
    # shellcheck disable=SC2139
    alias "$base_name"="$script"
  done
}
create_aliases

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# Initialize SDKMAN for Java version management
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
