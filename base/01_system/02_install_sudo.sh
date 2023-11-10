#!/bin/bash

# import
source "$(dirname "$0")/../core/execute_task.sh"
source "$(dirname "$0")/../core/logger.sh"

### Task - install Sudo
#
# Function..........: install_sudo
# Description.......: Installs the sudo package if it is not already installed.
# Parameters........: None
# Returns...........: 
#              - 0: If sudo is successfully installed or already present.
#              - Non-zero: If the installation fails or if sudo is not installed and cannot be installed.
# Output............: Logs the progress and results of the installation.
#
###
task_install_sudo() {

  local name="Install sudo"
  local isRootRequired=true
  local prereq="check_prerequisites_install_sudo"
  local actions="apt-get install -y sudo"
  local configs=""
  
  if ! execute_task "$name" $isRootRequired "$prereq" "$actions" "$configs"; then
    log_error "Installation of sudo failed."
    return 1
  fi

  log_info "Sudo has been successfully installed."
  return 0
}

### Check Prerequisites install sudo
#
# Function..........: check_prerequisites
# Description.......: Checks if the APT package manager is available and if sudo is already installed.
#                     Intended for use in Debian-based systems.
# Returns...........: 
#              - 1: If APT is available and sudo is not installed.
#              - 2: If APT is not available or sudo is already installed.
# Output............: Logs a message indicating either the absence of APT or the presence of sudo.
#
###
check_prerequisites_install_sudo() {

  # Check if APT is available
  if ! command -v apt-get &> /dev/null; then
    log_error "APT package manager not found. This script is intended for Debian-based systems."
    return 1
  fi

  # Check if sudo is already installed
  if command -v sudo &> /dev/null; then
    log_info "sudo is already installed on the system."
    return 0
  fi

  return 0
}

# Run the install sudo function
task_install_sudo