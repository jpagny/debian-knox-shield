#!/bin/bash

# import
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task - install Sudo
#
# Function..........: task_install_sudo
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
  local actions="run_action_install_sudo"
  local postActions=""
  
  if ! execute_task "$name" $isRootRequired "$prereq" "$actions" "$postActions"; then
    log_error "Installation of sudo failed."
    return $NOK
  fi

  log_info "Sudo has been successfully installed."
  return $OK
}

### Check Prerequisites install sudo
#
# Function..........: check_prerequisites_install_sudo
# Description.......: Checks if the APT package manager is available.
#                     Intended for use in Debian-based systems.
# Returns...........: 
#              - 0: If APT is available.
#              - 1: If APT is not available.
# Output............: Logs a message indicating either the absence of APT or the presence of sudo.
#
###
check_prerequisites_install_sudo() {

  # Check if APT is available
  if ! command -v apt-get &> /dev/null; then
    log_error "APT package manager not found. This script is intended for Debian-based systems."
    return $NOK
  fi

  return $OK
}

### Run action - Install Sudo
#
# Function..........: run_action_install_sudo
# Description.......: Installs the 'sudo' package if it's not already installed.
#                     This function is intended for use in Debian-based systems
#                     where 'sudo' might not be pre-installed.
# Returns...........: 
#              - 0: If the installation of 'sudo' was successful or if 'sudo' is already installed.
#              - 1: If the installation of 'sudo' failed.
# Output............: Logs a message indicating the success or failure of the installation.
#
###
run_action_install_sudo(){

  # install sudo package
  if ! install_package "sudo"; then
    return $NOK
  fi

  return $OK
}

# Run the install sudo function
task_install_sudo