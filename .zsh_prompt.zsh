# Function to set up custom zsh prompt with p10k-like style and git status
setup_prompt() {
  # Enable command substitution in prompt
  setopt PROMPT_SUBST
  betz_content_vcs=""

  prompt_segment() {
    # We need to wrap in %{ %} to ensure the %K{blue} is not interpreted as spaces
    # If we don't it will counted towards the character length of the prompt,
    # thus messing up the internal logic of zsh and not padding the RPS1 flush
    # to the right hand side of the terminal
    k='%{%K{blue}%}'
    echo -n "$k%60<..<%~"
  }

  prompt_segment_tail() {
    ra='\uE0B0' # 
    g='\uE0A0'  # 
    s='%{%F{blue}%}'$ra'%f'
    # Prevent Mac Terminal.app brightening font color with no background
    # https://apple.stackexchange.com/questions/282911/
    # prevent-mac-terminal-brightening-font-color-with-no-background/446604#446604
    # Setting background to an out of range value works, %k and %K{256} do not work
    # Not needed for Kitty
    if [[ -z "$KITTY_WINDOW_ID" ]]; then
      n='%{\e[48;5;256m%}'
    else
      n='%k'
    fi
    if [[ -n ${betz_content_vcs} ]]; then
      local branch="${betz_content_vcs%% *}"
      local modifiers="${betz_content_vcs#$branch}"
      if [[ ${modifiers} =~ "[+~?]" ]]; then
        b='%{%K{yellow}%}'
        f='%{%F{yellow}%}'
      else
        b='%{%K{green}%}'
        f='%{%F{green}%}'
      fi
      echo -n "$b$s $g ${betz_content_vcs}$f $n$ra%f%k"
    else
      echo -n "$n$s%f%k"
    fi
  }

  # Prompt segment for user@host without triangle
  user_host_segment() {
    echo -n "%n@%m"
  }

  # Update Git status before each prompt
  precmd() {
    # Reset VCS content
    betz_content_vcs=""

    # Get git command using git-wrapper
    local git_cmd=$($HOME/.local/scripts/git-wrapper git-cmd)
    if [[ -z $git_cmd ]]; then
      return
    fi

    # Get branch name
    local branch=$($git_cmd rev-parse --abbrev-ref HEAD 2>/dev/null)
    # Check git status for changes
    local porcelain=$($git_cmd status --porcelain 2>/dev/null)

    local staged=0
    local untracked=0
    local unstaged=0
    if [[ -n $porcelain ]]; then
      staged=$(echo "$porcelain" | grep -c "^[MTADRC]")
      unstaged=$(echo "$porcelain" | grep -c "^.[MTDRC]")
      untracked=$(echo "$porcelain" | grep -c "^??")
    fi
    local dirty=$((unstaged + staged + untracked))

    # Build VCS string similar to p10k
    local seg="$branch"
    if [[ $dirty -gt 0 ]]; then
      [[ $staged -gt 0 ]] && seg="${seg} +$staged"
      [[ $unstaged -gt 0 ]] && seg="${seg} ~$unstaged"
      [[ $untracked -gt 0 ]] && seg="${seg} ?$untracked"
    fi
    betz_content_vcs="$seg"
  }

  # Build left prompt dynamically to include git status
  precmd_prompt() {
    ENABLE_USER_HOST=0
    local left_prompt=""
    if [[ ${ENABLE_USER_HOST} -eq 1 ]]; then
      left_prompt+=$(user_host_segment)
    fi
    left_prompt+=$(prompt_segment)
    left_prompt+=$(prompt_segment_tail)
    left_prompt+="%f "
    PS1="${left_prompt}"
  }

  # Update right prompt dynamically
  rprompt_segment_dynamic() {
    t=$'\uE0B2' # 
    v=""
    if [[ -z "$KITTY_WINDOW_ID" ]]; then
      n=$'%{\e[48;5;256m%}'
      g=$'\uE606' #   Hack Nerd Font Propo Regular
    else
      n=''
      g=$'\uF3E2' #   Kitty we use Font Awesome
    fi
    if [[ -n "$VIRTUAL_ENV" ]]; then
      venv_parent="${VIRTUAL_ENV%/*}" # Strip last folder (e.g., .venv)
      if [[ "$PWD" == "$venv_parent"/* || "$PWD" == "$venv_parent" ]]; then
        v="%{%F{blue}%}$t%f%{%K{blue}%}$g"
      else
        v="%{%F{magenta}%}$t%f%{%K{magenta}%}$g"
      fi
    fi
    RPS1="${n}${v} %(?.%{%F{green}%}.%{%F{red}%})${t}%f%(?.%{%K{green}%}.%{%K{red}%}) %*%f%k"

    # %(?.X.Y)    : Conditional: X if last command succeeded (exit code 0), Y if failed
    # %*          : Time in 24-hour HH:MM:SS format, reset colors
  }

  # Hook precmd to update prompt
  precmd_functions+=(precmd_prompt rprompt_segment_dynamic)
}
