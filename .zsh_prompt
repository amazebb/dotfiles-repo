# shellcheck disable=SC2329,SC2034
# Function to set up custom ZSH prompt with git status
typeset -gA ZZ_PROMPT
ZZ_PROMPT=(
    # Colors
    [color]='blue'          # PWD bgc
    [tc]='#eeffee'          # Text fgc
    [k]='%{\e[48;5;256m%}'  # Reset bgc for macOS Terminal
    ## PS1 
    # Home
    [u]=''                  # Display user@host ("%n@%m"), or hide ("")
    [h]='\ueb06 '           # Home glyph
    [pwd]='\uea83'          # Folder glyph
    [sa]='\ue0b0'           # PS1 right trailing glyph
    [width]='40'            # Prompt width
    # Git
    [gs]=''                 # Git status line
    [gc]=''                 # Either ZZ_PROMPT[x] or ZZ_PROMPT[ok] 
    [git]='\ue725'          # Branch glyph
    [x]='red'               # Working tree changes bgc
    [ok]='#5ca37a'          # Working tree clean bgc
    ## RPS1
    # Virtiual Environment
    [py]='\ue606'           # Python glyph
    [sb]='\ue0b2'           # RPS1 left leading glyph 
    [cv]='magenta'          # PWD outside project folder bgc
    # System
    [t]='*'                 # Date/Time format for RSP1 component 
    [er]='red'              # Last command error, RPS1 bgc
 )

setup_prompt() {
    # Enable command substitution in prompt
    setopt PROMPT_SUBST

    M(){
        print -n -- "${ZZ_PROMPT[$1]}"
    }

    F(){
        print -r -- "%{%F{$1}%}"
    }

    K(){
        print -r -- "%{%K{$1}%}"
    }
   
    R(){
       # In macOS 15.x and prior, prevent Terminal.app brightening font color with no background:
       # https://apple.stackexchange.com/questions/282911/
       # prevent-mac-terminal-brightening-font-color-with-no-background/446604#446604
       # Setting background to an out of range value works, %k and %K{256} do not work.
       # Not needed for Kitty and terminals that support truecolor
       [[ -z "$KITTY_WINDOW_ID" ]] && k="%k$(M k)" || k='%k'
       print -n -- "$k"
    }

    pwd-icon() {
        [[ $PWD = *$HOME* ]] && p=${PWD/#$HOME/$(M h)} || p=$(M pwd)" "$PWD
        print -n -- "$p"
    }

    ps1a() {
        print -n -- "$(K "$(M color)")$(F "$(M tc)")$(M u)%$(M width)<..<$(pwd-icon)"
    }

    ps1b() {
        S="$(F "$(M color)")$(M sa)"
        if [[ -n $(M gs) ]]; then
            print -n -- "$(K "$(M gc)")$S$(F "$(M tc)")$(M git) $(M gs)$(R)$(F "$(M gc)")$(M sa) %f"
        else
            print -n -- "$(R)$S %f"
        fi
    }

    # Build left prompt
    ps1() {
        PS1="$(ps1a)$(ps1b)"
    }

    # Update Git status before each prompt
    precmd() {
        ZZ_PROMPT[gs]=$(git-wrapper stline)
        [[ $(M gs) =~ [+~?] ]] && ZZ_PROMPT[gc]=$(M x) || ZZ_PROMPT[gc]=$(M ok)
    }

    venv_path() {
        # Calculate relative path from VENV to current directory as "../" notation
        # Given a base path (Python virtual environment parent), returns
        # a string of "../" repeated for each directory level between the base and PWD.
        local relative result
        depth=0

        [[ "$PWD" != "$1" ]] && relative="${PWD#"$1"/}"
        [[ -n "$relative" ]] && depth=$(( ${#${relative//[^\/]}} + 1 ))
        for ((i = 0; i < depth; i++)); do result+="../"; done

        print -n -- "$result"
    }

    rps1a(){
        if [[ -n "$VIRTUAL_ENV" ]]; then
            venv="${VIRTUAL_ENV%/*}"
            if [[ "$PWD" == "$venv"/* || "$PWD" == "$venv" ]]; then
                C="$(M color)"
                relative_path=$(venv_path "$venv")
                venv="$relative_path${VIRTUAL_ENV##*/}"
            else
                C="$(M cv)"
                venv=${venv/#$PWD/}
                venv="${venv/#$HOME/~}"
            fi
            py_venv="$(F "$C")$(M sb)"
            py_venv+="%f$(K "$C")$(M py) $venv"
        fi
        print -n -- "$(R)$py_venv"
    }
   
    rps1b(){
        R="%(?.$(F "$(M ok)").$(F "$(M er)"))$(M sb)"
        R+="$(F "$(M tc)")%(?.$(K "$(M ok)").$(K "$(M er)"))%$(M t)"
        print -n -- "$R"
    }

    rps1(){
        RPS1="$(rps1a)$(rps1b)"
    }

    # Final hook to update prompt
    precmd_functions=(ps1 rps1)
}

setup_prompt
