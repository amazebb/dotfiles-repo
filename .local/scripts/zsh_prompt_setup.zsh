# Function to set up custom zsh prompt with p10k-like style and git status
setup_prompt() {
  # Enable command substitution in prompt
  setopt PROMPT_SUBST

  # Define theme as global associative array to ensure access
  typeset -gA theme
  theme=(
    SEGMENT_SEPARATOR $'\uE0B0' # Right-pointing triangle
    USER_BC '%K{blue}'          # User background color
    USER_FC '%F{white}'         # User foreground color
    PWD_BC '%K{blue}'           # PWD background color
    PWD_FC '%F{white}'          # PWD foreground color
    TIME_BC '%k'                # Time background color (none)
    TIME_FC '%F{white}'         # Time foreground color
    STATUS_OK '%F{green}'       # Status OK color
    STATUS_ERR '%F{red}'        # Status error color
    VCS_CLEAN_BC '%K{green}'    # Git clean background
    VCS_CLEAN_FC '%F{black}'    # Git clean foreground
    VCS_DIRTY_BC '%K{yellow}'   # Git dirty background
    VCS_DIRTY_FC '%F{black}'    # Git dirty foreground
    RESET '%k%f'                # Reset colors
    ENABLE_USER_HOST 0          # 0 to hide user@hostname by default, 1 to show
  )

  # Define content as global associative array
  typeset -gA content
  content=(
    USER "%n@%m"      # Username@hostname
    PWD "%~"          # Current directory
    TIME '%D{%H:%M}'  # Time in 24h format
    STATUS '%(?.✔.✘)' # Status indicator
    VCS ""            # Git status (populated in precmd)
  )

  # Prompt segments for left side
  prompt_segment() {
    echo -n "${theme[PWD_BC]}${theme[PWD_FC]} ${content[PWD]} ${theme[RESET]}${theme[PWD_FC]}${theme[SEGMENT_SEPARATOR]}"
  }

  # Prompt segment for user@host without triangle
  user_host_segment() {
    echo -n "${theme[USER_BC]}${theme[USER_FC]} ${content[USER]} ${theme[RESET]}"
  }

  # Git status segment
  vcs_segment() {
    if [[ -n "${content[VCS]}" ]]; then
      local branch="${content[VCS]%% *}"        # Get branch name before modifiers
      local modifiers="${content[VCS]#$branch}" # Get modifiers (+/*/)
      if [[ "${modifiers}" =~ "[+*?!]" ]]; then
        echo -n "${theme[VCS_DIRTY_BC]}${theme[VCS_DIRTY_FC]} ${content[VCS]} ${theme[RESET]}${theme[VCS_DIRTY_FC]}${theme[SEGMENT_SEPARATOR]}"
      else
        echo -n "${theme[VCS_CLEAN_BC]}${theme[VCS_CLEAN_FC]} ${content[VCS]} ${theme[RESET]}${theme[VCS_CLEAN_FC]}${theme[SEGMENT_SEPARATOR]}"
      fi
    fi
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
      [[ $unstaged -gt 0 ]] && seg="${seg} *$unstaged"
      [[ $untracked -gt 0 ]] && seg="${seg} ?$untracked"
    fi
    content[VCS]="$seg"
  }

  # Build left prompt dynamically to include git status
  precmd_prompt() {
    local left_prompt=""
    if [[ ${theme[ENABLE_USER_HOST]} -eq 1 ]]; then
      left_prompt+=$(user_host_segment)
    fi
    left_prompt+=$(prompt_segment)
    left_prompt+=$(vcs_segment)
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
