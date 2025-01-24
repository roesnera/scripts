#!/bin/bash

# Config file to track hard links
CONFIG_FILE="hard_links_config.txt"

# Get the current directory
CURRENT_DIR=$(pwd)

# Function to check if a file is hard-linked and update the config
track_hard_links() {
  local FILE="$1"
  local INODE=$(stat -c %i "$FILE")
  local LINKS=$(stat -c %h "$FILE")

  # If the file has more than one hard link, track it
  if [ "$LINKS" -gt 1 ]; then
    echo "File: $FILE" >> "$CONFIG_FILE"
    echo "Locations:" >> "$CONFIG_FILE"
    local HOME_DIR="$HOME"
    find "$CURRENT_DIR" "$HOME_DIR" -inum "$INODE" 2>/dev/null | sort -u | while read -r ITEM; do
      local ITEM_DIR=$(dirname "$ITEM")
      if [[ "$ITEM_DIR" != "$CURRENT_DIR" ]]; then
        local RELATIVE_PATH="~/${ITEM#$HOME_DIR/}"
        echo "$RELATIVE_PATH" >> "$CONFIG_FILE"
      fi
    done
    echo "-----" >> "$CONFIG_FILE"
  fi
}

process_hard_links() {
  # Initialize or clear the config file
  > "$CONFIG_FILE"

  shopt -s dotglob
  # Loop through all files in the current directory
  for FILE in *; do
    # Check if it's a file (not a directory)
    if [ -f "$FILE" ]; then
      # # Define the target path in the home directory
      # TARGET="$HOME/$FILE"
      #
      # # Check if the file already exists in the home directory
      # if [ -e "$TARGET" ]; then
      #   echo "Skipping '$FILE': File already exists in the home directory."
      # else
      #   # Create a hard link
      #   ln "$FILE" "$TARGET"
      #   echo "Created hard link for '$FILE' in the home directory."
      # fi

      # Track hard-linked files
      track_hard_links "$FILE"
    fi
  done

  shopt -u dotglob

  echo "Hard link tracking complete. Config file: $CONFIG_FILE"
}

create_hard_links_from_config() {
  # Function to create hard links
  create_hard_links() {
    local FILE="$1"
    local LOCATIONS=("$@")  # All arguments are locations

    # Skip the first argument (file name)
    for ((i = 1; i < ${#LOCATIONS[@]}; i++)); do
      local TARGET="${LOCATIONS[$i]}"
      # Replace ~ with $HOME
      TARGET="${TARGET/#\~/$HOME}"
      if [ ! -e "$TARGET" ]; then
        echo "Creating hard link for '$FILE' at '$TARGET'"
        ln "$CURRENT_DIR/$FILE" "$TARGET"
      else
        echo "Skipping '$TARGET': File already exists."
      fi
    done
  }

  # Parse the config file
  declare -A FILE_LOCATIONS  # Associative array to store file locations
  CURRENT_FILE=""

  while read -r LINE; do
    # Check if the line starts with "File:"
    if [[ "$LINE" =~ ^File:\ (.+)$ ]]; then
      CURRENT_FILE="${BASH_REMATCH[1]}"
      FILE_LOCATIONS["$CURRENT_FILE"]=""
    # Check if the line starts with "~/" (a location)
    elif [[ "$LINE" =~ ^~/.+$ ]]; then
      if [ -n "$CURRENT_FILE" ]; then
        FILE_LOCATIONS["$CURRENT_FILE"]+="$LINE"$'\n'
      fi
    fi
  done < "$CONFIG_FILE"

  # Process each file and its locations
  for FILE in "${!FILE_LOCATIONS[@]}"; do
    LOCATIONS=($(echo "${FILE_LOCATIONS[$FILE]}" | tr '\n' ' '))
    if [ ${#LOCATIONS[@]} -gt 0 ]; then
      create_hard_links "$FILE" "${LOCATIONS[@]}"
    fi
  done

  echo "Hard link creation complete."
}

if [ "$1" = "update_config" ]; then
  process_hard_links
elif [ "$1" = "apply_config" ]; then
  # Check if the input file exists
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: File '$CONFIG_FILE' not found."
    echo "Try running the \"udpate_config\" option"
    exit 1
  fi
  create_hard_links_from_config
fi
