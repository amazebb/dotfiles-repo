#!/bin/dash
# Launch nnn and with auto preview if from tmux
# Block nesting of nnn in subshells
if [ -n "$NNNLVL" ] && [ "${NNNLVL:-0}" -ge 1 ]; then
    echo "nnn is already running"
    return
fi

# The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
# If NNN_TMPFILE is set to a custom path, it must be exported for nnn to see.
# To cd on quit only on ^G, remove the "export" and set NNN_TMPFILE *exactly* as this:
#     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

# This will create a fifo where all nnn selections will be written to
NNN_FIFO="$(mktemp -t nnn -u)"
export NNN_FIFO
(
    umask 077
    mkfifo "$NNN_FIFO"
)

# Preview command
preview_cmd="$HOME/.local/bin/preview_cmd.sh"

# Use `tmux` split as preview
if [ -e "${TMUX%%,*}" ]; then
    tmux split-window -e "NNN_FIFO=$NNN_FIFO" -dh "$preview_cmd"
fi

nnn "$@"

rm -f "$NNN_FIFO"
