# Setup the history
HISTFILE=~/.zsh_history
HISTSIZE=100000
# shellcheck disable=SC2034
SAVEHIST=100000
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

# Aliases
alias ls="eza -1lh -s=name --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always"
# Show only dot files and folders, add -D for folders only and -f for files only
alias ls-dot="eza -1alh -s=name --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always -I=\"[!.]*\""
alias brewup="brew update && brew upgrade && brew outdated --cask --greedy --verbose"
alias git='git-wrapper'
alias gcv="git-wrapper commit -va"
alias nn="~/.nvim-nightly/nvim-macos-arm64/bin/nvim"

autoload -Uz compinit
compinit
compdef git-wrapper.sh=git

# Prevent 'less' from saving command history
# no trace of less interactions (e.g., when viewing man pages)
export LESSHISTFILE=-

# Set zsh prompt
source "$HOME"/.zsh_prompt.zsh
setup_prompt

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
# shellcheck disable=SC2155
export GEMINI_API_KEY=$(security find-generic-password -s gemini-api-key -w 2>/dev/null)

# PATH
export PATH="/opt/local/bin:/opt/homebrew/opt/make/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/node@16/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.juliaup/bin"

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
# CTRL-T - Paste the selected files and directories onto the command-line
# CTRL-R - Paste the selected command from history onto the command-line
# ALT-C  - cd into the selected directory

# Create aliases without .sh for ~/.local/scripts/*.sh files
create_aliases() {
  for script in ~/.local/scripts/*.sh; do
    base_name=$(basename "$script" .sh)
    # shellcheck disable=SC2139
    alias "$base_name"="$script"
  done
}
create_aliases

# In the Kitty terminal we can plot using iplot: iplot 'sin(x*3)*exp(x*.2)'
function iplot {
  cat <<EOF | gnuplot
    set terminal pngcairo enhanced font 'Fira Sans,10'
    set autoscale
    set samples 1000
    set output '|kitten icat --stdin yes'
    set object 1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb"#fdf6e3" behind
    plot $@
    set output '/dev/null'
EOF
}

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
