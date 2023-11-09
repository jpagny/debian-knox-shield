#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

# Function to update and upgrade the system
update_and_upgrade() {
  local name="System Update and Upgrade"
  local prereq="Updating package lists and upgrading installed packages"
  local actions="sudo apt-get update -y"
  local configs="sudo apt-get upgrade -y"

  execute_task "$name" "$prereq" "$actions" "$configs"
}

# Run the update and upgrade function
update_and_upgrade
