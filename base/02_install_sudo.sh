#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

# Function to install sudo
install_sudo() {
  local name="Install sudo"
  local prereq=""
  local actions="sudo apt-get install -y sudo"
  
  # Check if sudo is installed
  if ! command -v sudo &> /dev/null; then
    execute_task "$name" "$prereq"  "$actions" ""
  else
    log_info "sudo is already installed"
  fi
}

# Run the install sudo function
install_sudo