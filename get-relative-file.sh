#!/bin/bash

get_relative_path() {
  # Get the current directory
  CURRENT_DIR=$(pwd)

  # Get the home directory
  HOME_DIR="$HOME"

  # Check if the current directory is under the home directory
  if [[ "$CURRENT_DIR" != "$HOME_DIR"* ]]; then
    echo "Current directory is not under the home directory."
    exit 1
  fi

  # Remove the home directory prefix from the current directory
  RELATIVE_PATH="${CURRENT_DIR#$HOME_DIR/}"

  # Handle the case where the current directory is the home directory
  if [ -z "$RELATIVE_PATH" ]; then
    RELATIVE_PATH="."
  fi

  # Print the relative path
  echo "~/$RELATIVE_PATH/$1"

  return 
}

get_relative_path $1
