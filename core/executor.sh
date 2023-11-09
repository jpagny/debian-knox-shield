#!/bin/bash

# Import logger functions
source "$(dirname "$0")/logger.sh"

# Function to execute scripts from a specified directory
execute_scripts_in_directory() {
  local directory_path="$1"
  local directory_name="$(basename "$directory_path")"

  log_info "Executing scripts in the $directory_name directory..."

  for script in "$directory_path"/*.sh; do
    if [[ -x "$script" ]]; then  # Check if the script is executable
      log_info "Running $(basename "$script")..."
      "$script"
    else
      log_error "$(basename "$script") is not executable or not found."
    fi
  done
}