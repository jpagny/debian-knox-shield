#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

# Function to install SSH
install_ssh() {
  local prereq="Installing OpenSSH server"
  local name="Install SSH"
  local actions="sudo apt-get install -y openssh-server"
  local configs=":"

  execute_task "$prereq" "$name" "$actions" "$configs"
}

# Run the function to install SSH
install_ssh
