#!/bin/bash

# Script to visualize colors defined in colors.toml
# Usage: ./view-colors.sh

TOML_FILE="$(dirname "$0")/colors.toml"

if [ ! -f "$TOML_FILE" ]; then
    echo "Error: colors.toml not found at $TOML_FILE"
    exit 1
fi

# Function to convert hex to terminal color code
hex_to_term() {
    hex=$1
    r=$(printf '%d' 0x${hex:0:2})
    g=$(printf '%d' 0x${hex:2:2})
    b=$(printf '%d' 0x${hex:4:2})
    printf "\033[48;2;%d;%d;%dm  \033[0m" "$r" "$g" "$b"
}

echo "Color Visualization for $(basename "$TOML_FILE")"
echo "================================================"

# Group titles and their grep patterns
declare -A groups
groups["Base colors"]="^dark|^light"
groups["Standard colors"]="^bright_"
groups["Neutral colors"]="^neutral_"
groups["Faded colors"]="^faded_"
groups["Light mode colors"]="^light_"
groups["Gray"]="^gray "
groups["Starship colors"]="^[a-z-]+-[fb]g"
groups["Aider colors"]="^[a-z-]+-color"
groups["Delta colors"]="^delta-"

# Process each group
for group_name in "${!groups[@]}"; do
    echo -e "\n$group_name:"
    echo "------------------------"

    grep -E "${groups[$group_name]}" "$TOML_FILE" | while read line; do
        # Skip comments
        [[ "$line" =~ ^#.*$ ]] && continue

        # Extract name and color
        if [[ "$line" =~ ([a-z0-9_-]+)[[:space:]]*=[[:space:]]*\"([0-9a-fA-F]+)\" ]]; then
            name="${BASH_REMATCH[1]}"
            color="${BASH_REMATCH[2]}"

            # Display color block next to name and hex code
            color_block=$(hex_to_term "$color")
            printf "%-30s %s #%s\n" "$name" "$color_block" "$color"
        fi
    done
done