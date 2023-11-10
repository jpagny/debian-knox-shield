#!/bin/bash

# Source the execute_task function and logger functions from the core directory
source "$(dirname "$0")/../core/execute_task.sh"
source "$(dirname "$0")/../core/logger.sh"

# Function to deactivate root SSH login
deactivate_root_ssh() {
  local prereq="Deactivating root SSH login"
  local name="Deactivate Root SSH"
  local sshd_config="/etc/ssh/sshd_config"
  local actions=""

  log_info "Checking SSH configuration for PermitRootLogin setting."

  # Check if PermitRootLogin exists in the sshd_config and is set to 'yes'
  if grep -q "^PermitRootLogin yes" "$sshd_config"; then
    log_info "PermitRootLogin set to 'yes'. Changing to 'no'."
    # If it exists and is set to 'yes', replace it with 'no'
    actions="sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' $sshd_config"
  else
    log_info "PermitRootLogin not set to 'yes' or does not exist. Adding 'PermitRootLogin no'."
    # If it doesn't exist or isn't set to 'yes', add 'PermitRootLogin no' to the file
    actions="echo 'PermitRootLogin no' | sudo tee -a $sshd_config"
  fi

  local configs="sudo service ssh restart"
  log_info "Restarting SSH service to apply changes."

  execute_task "$prereq" "$name" "$actions" "$configs"
}

# Run the function to deactivate root SSH login
deactivate_root_ssh
