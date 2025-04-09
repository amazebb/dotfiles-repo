#!/bin/bash
# Display all 256 ANSI colors in the terminal

# Get terminal dimensions
rows=$(tput lines)
cols=$(tput cols)

# Total colors (256: 0 to 255)
total_colors=256

# Visible width of "Color XXX" (5 + 1 + 3)
item_width=9

# Calculate number of columns that fit (1 space between columns)
num_cols=$((cols / (item_width + 1)))
[ "$num_cols" -lt 1 ] && num_cols=1

# Calculate rows needed per column
rows_per_col=$(((total_colors + num_cols - 1) / num_cols))
[ "$rows_per_col" -gt "$rows" ] && rows_per_col="$rows"

# Print colors in columns
for ((row = 0; row < rows_per_col; row++)); do
	for ((col = 0; col < num_cols; col++)); do
		idx=$((row + col * rows_per_col))
		if [ "$idx" -lt "$total_colors" ]; then
			printf "\e[38;5;%smColor %-3d\e[0m " "$idx" "$idx"
		fi
	done
	echo
done
