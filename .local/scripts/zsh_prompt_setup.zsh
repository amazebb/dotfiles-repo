# Function to set up custom zsh prompt with p10k-like style and git status
setup_prompt() {
  # Enable command substitution in prompt
  setopt PROMPT_SUBST

  betz_content_vcs=""

  prompt_segment() {
    k='%K{blue}'
    echo -n "$k%50<..<%~"
  }

  prompt_segment_tail() {
    s='%F{blue}\uE0B0'
    # Prevent Mac terminal brightening font color with no background
    # https://apple.stackexchange.com/questions/282911/prevent-mac-terminal-brightening-font-color-with-no-background/446604#446604
    n='\e[48;5;256m' # set background to an out of range value, %K{256} does not work
    if [[ -n "${betz_content_vcs}" ]]; then
      local branch="${betz_content_vcs%% *}"        # Get branch name before modifiers
      local modifiers="${betz_content_vcs#$branch}" # Get modifiers (+/*/)
      if [[ "${modifiers}" =~ "[+~?]" ]]; then
        b='%K{yellow}'
        f='%F{yellow}'
      else
        b='%K{green}'
        f='%F{green}'
      fi
      echo -n "$b$s %f${betz_content_vcs}$f $n\uE0B0%f%k"
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

    # Get git command using dotfiles.sh
    local git_cmd
    git_cmd=$(/Users/x626f/.local/scripts/dotfiles.sh git-cmd)
    if [[ -z "$git_cmd" ]]; then
      return
    fi

    # Get branch name
    local branch=$($git_cmd rev-parse --abbrev-ref HEAD 2>/dev/null)
    # Check git status for changes
    local porcelain=$($git_cmd status --porcelain 2>/dev/null)

    local staged=0
    local untracked=0
    local unstaged=0
    if [[ -n "$porcelain" ]]; then
      staged=$(echo "$porcelain" | grep -c "^[MTADRC]")
      unstaged=$(echo "$porcelain" | grep -c "^.[MTDRC]")
      untracked=$(echo "$porcelain" | grep -c "^??")
    fi
    local dirty=$((unstaged + staged))

    # Build VCS string similar to p10k
    local seg="$branch"
    if [[ $dirty -gt 0 || $untracked -gt 0 ]]; then
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
    TIME='%D{%H:%M}' # Time in 24h format
    RPS1="%(?.%F{green}✔.%F{red}✘)%f%k %k$TIME%f%k"
  }

  # Set initial PS1 and RPS1
  PS1=""
  RPS1=""

  # Hook precmd to update prompt
  precmd_functions+=(precmd_prompt rprompt_segment_dynamic)
}
