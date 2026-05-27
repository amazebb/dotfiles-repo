# shellcheck disable=SC2034

## Setup the history
HISTFILE=$HOME/.zsh_history # Configure history storage and size parameters
HISTSIZE=250000             # Set maximum number of commands stored in memory for current session
SAVEHIST=200000             # Set maximum number of commands saved to history file on disk
export LESSHISTFILE=-       # Prevent 'less' from saving command history (e.g., when viewing man pages)

# Configure history behavior options
setopt EXTENDED_HISTORY       # Log with Unix timestamps
setopt HIST_EXPIRE_DUPS_FIRST # Remove duplicates first when trimming
setopt HIST_FIND_NO_DUPS      # Hide dupes in search, but still SAVE them all
setopt HIST_VERIFY            # Expand history substitutions before executing
setopt SHARE_HISTORY          # Share history across sessions (implies INC_APPEND_HISTORY)

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
export CHPL_HOME=/opt/homebrew/Cellar/chapel/2.5.0_1
export SDL_FRAMEBUFFER_ACCELERATION=opengl

## Aliases
# Homebrew
if command -v brew &>/dev/null; then
    alias brewup="brew update && brew upgrade && brew outdated --cask --greedy --verbose"
else
    printf "Install homebrew ? (y/N) " && read -r && [[ $REPLY =~ ^[Yy]$ ]] && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Copies Apple Notes while retaining newline which would otherwise be copied
# over as <2028>, (U+2028) is the Unicode Line Separator
# To use copy selection in Apple Notes, then run "cpnotes" in the terminal
[[ $OSTYPE == *darwin* ]] && alias cpnotes='pbpaste | sed "s/\xe2\x80\xa8/\n/g" | pbcopy'

# Eza
if command -v eza &>/dev/null; then
    alias l="eza -1lh -s=name --no-quotes --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always"
    # Show only dot files and folders, add -D for folders only, and -f for files only
    alias ll="eza -1alh -s=name --no-quotes --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always -I=\"[!.]*\""
    alias llp="eza -D -1alh -s=name --no-quotes --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always -I=\"[!.]*\""
    alias llf="eza -f -1alh -s=name --no-quotes --no-user --group-directories-first --git --git-repos-no-status --icons=always --color=always -I=\"[!.]*\""
else
    printf "Install eza ? (y/N) " && read -r && [[ $REPLY =~ ^[Yy]$ ]] && brew install eza
fi

# Nvim
if command -v nvim &>/dev/null; then
    alias nn='$HOME/.local/bin/nvim'
    export EDITOR="$HOME/.local/bin/nvim"
    export MANPAGER='nvim +Man!'
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
    # CTRL-T - Paste the selected files and directories onto the command-line
    # CTRL-R - Paste the selected command from history onto the command-line (custom widget below)
    # ALT-C  - cd into the selected directory
    source <(fzf --zsh)
    # Override CTRL-R to show timestamps (yyyymmdd HH:MM) and command duration
    # Bind ? key to toggle preview window for long commands
    fzf-history-widget() {
        local selected
        selected=$(awk '!/:0;\\$/ ' "$HISTFILE" |
            LC_ALL=C awk '!NF{if(cont){printf "\n";cont=0};next} /\\$/{gsub(/\\+$/,"");printf "%s ",$0;cont=1;next} {print;cont=0}' | tr ';' ' ' | cut -d: -f 2- | uniq -f 1 |
            awk -F':0' '{printf("%s %s\n",strftime("%Y-%m-%d %H:%M", $1), substr($0,index($0,$2)))}' |
            fzf --tac --no-sort \
                --preview 'printf "%s\n" {3..}' --preview-window down:3:hidden:wrap \
                --bind '?:toggle-preview' --no-mouse \
                --header='History (?:Toggle preview)' \
                --query="${LBUFFER}")
        if [[ -n "$selected" ]]; then
            LBUFFER=$(echo "$selected" | tr -s '[:space:]' ' ' | cut -d ' ' -f 3-)
        fi
        zle reset-prompt
    }
    zle -N fzf-history-widget
else
    printf "Install fzf ? (y/N) " && read -r && [[ $REPLY =~ ^[Yy]$ ]] && brew install fzf
fi

# Fzf-man ^h binding for man pages
[[ -s "$HOME/.local/bin/fzf-man" ]] && source "$HOME/.local/bin/fzf-man"

# Nnn
if [[ -s $HOME/.local/bin/n3 ]]; then
    alias n='source $HOME/.local/bin/n3'
fi

uvcachelist() {
    find "$(uv cache dir)/archive-v0" -name "METADATA" -path "*.dist-info/*" |
        awk -F/ '{split($(NF-1),a,"-");gsub(/\.dist.*/,"",a[2]); print a[1], a[2]}' |
        sort -f | column -t
}

git-dirty() {
    fd -Htd '^\.git$' "${1:-.}" | sed 's/\.git\/$//' | while read -r dir; do
        [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ] && echo "${dir#./}"
    done
}

# Dotfiles
((${+functions[dotfiles]})) && alias dg=dotfiles

# Prompt
[[ -s $HOME/.local/share/zsh/prompt/zsh-prompt ]] && source "$HOME/.local/share/zsh/prompt/zsh-prompt"

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# Initialize SDKMAN for Java version management
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# macOS fix for manpath/makewhatis due to APFS by default being
# case-insensitive. manpath auto-infers paths from $PATH, which produces
# entries like gnubin/man, as well as gnubin/MAN. The below resolves symlinks,
# deduplicates and moves homebrews versions upfront to keep makewhatis happy

resolved=$(manpath | tr ':' '\n' |
    while read -r p; do
        r=$(realpath "$p" 2>/dev/null) && [ -d "$r" ] && echo "$r"
    done)

r="$({
    echo "$resolved" | grep '/opt/homebrew'
    echo "$resolved" | grep -v '/opt/homebrew'
} | paste -sd ':' -)"
export MANPATH="$r"

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<
