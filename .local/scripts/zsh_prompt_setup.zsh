# Function to set up custom zsh prompt with p10k-like style and git status
setup_prompt() {
  # Enable command substitution in prompt
  setopt PROMPT_SUBST

  # Define theme as global associative array to ensure access
  typeset -gA theme
  theme=(
    SEGMENT_SEPARATOR $'\uE0B0' # Right-pointing triangle
    TIME_BC '%k'                # Time background color (none)
    TIME_FC '%F{white}'         # Time foreground color
    STATUS_OK '%F{green}'       # Status OK color
    STATUS_ERR '%F{red}'        # Status error color
    RESET '%k%f'                # Reset colors
  )

  # Define content as global associative array
  typeset -gA content
  content=(
    TIME '%D{%H:%M}'  # Time in 24h format
    STATUS '%(?.✔.✘)' # Status indicator
    VCS ""            # Git status (populated in precmd)
  )

  # Prompt segments for left side
  prompt_segment() {
    k='%K{blue}'
    echo -n "$k%50<..<%~"
  }

  prompt_segment_tail() {
    s='%F{blue}\uE0B0'
    # Prevent Mac terminal brightening font color with no background
    # https://apple.stackexchange.com/questions/282911/prevent-mac-terminal-brightening-font-color-with-no-background/446604#446604
    n='\e[48;5;256m' # set background to an out of range value, %K{256} does not work
    if [[ -n "${content[VCS]}" ]]; then
      local branch="${content[VCS]%% *}"        # Get branch name before modifiers
      local modifiers="${content[VCS]#$branch}" # Get modifiers (+/*/)
      if [[ "${modifiers}" =~ "[+~?]" ]]; then
        b='%K{yellow}'
        f='%F{yellow}'
      else
        b='%K{green}'
        f='%F{green}'
      fi
      echo -n "$b$s %f${content[VCS]}$f $n\uE0B0%f%k"
    else
      echo -n "$n$s%f%k"
    fi
  }

  # Prompt segment for user@host without triangle
  user_host_segment() {
    echo -n "%n@%m"
  }

  # Right prompt segment for status and time
  rprompt_segment() {
    local status_color
    if [[ $? -eq 0 ]]; then
      status_color="${theme[STATUS_OK]}"
    else
      status_color="${theme[STATUS_ERR]}"
    fi
    echo -n "${status_color}${content[STATUS]}${theme[RESET]} ${theme[TIME_BC]}${theme[TIME_FC]}${content[TIME]}${theme[RESET]}"
  }

  # Update Git status before each prompt
  precmd() {
    # Reset VCS content
    content[VCS]=""

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
    content[VCS]="$seg"
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
    local status_color
    if [[ $? -eq 0 ]]; then
      status_color="${theme[STATUS_OK]}"
    else
      status_color="${theme[STATUS_ERR]}"
    fi
    RPS1="${status_color}${content[STATUS]}${theme[RESET]} ${theme[TIME_BC]}${theme[TIME_FC]}${content[TIME]}${theme[RESET]}"
  }

  # Set initial PS1 and RPS1
  PS1=""
  RPS1=""

  # Hook precmd to update prompt
  precmd_functions+=(precmd_prompt rprompt_segment_dynamic)
}
