#!/bin/bash

# import
source "logger.sh"

### Verify has root privlieges
#
# Function..........: update_and_upgrade
# Description:......: Checks whether the script is executed with root privileges. 
# Returns:..........: 
#                     - 0 (Success): If the current user has root privileges (user ID is 0).
#                     - 1 (Failure): If the current user does not have root privileges.
# Output............: Logs an error message to the standard error output if the current user is not root.
#
### 
verify_has_root_privileges() {
    if [[ $(id -u) -ne 0 ]]; then
        log_error "This script must be run with root privileges."
        return 1
    fi

    return 0
}

### Install Package
#
# Function..........: install_package
# Description.......: Installs a given package using the APT package manager. 
#                     This function is intended for use on Debian-based systems.
#                     It checks if the specified package is already installed and, if not, 
#                     attempts to install it.
# Parameters........: 
#   - package: The name of the package to install.
# Returns...........: 
#   - 0: If the package is already installed or has been successfully installed.
#   - 1: If the installation of the package fails.
# Output............: Logs information about the installation process and any errors encountered.
# Note..............: This function uses 'apt-get' for package management and requires 
#                     administrative privileges to install packages. Ensure that the user 
#                     running this script has the necessary permissions.
#
###
install_package(){
    
  package=$1

  if ! command -v $package &> /dev/null; then
    log_info "$package is not installed. Installing..."

    if apt-get update &> /dev/null && apt-get install -y $package &> /dev/null; then
      log_info "$package has been installed successfully."
      return 0
    else
      log_error "Failed to install $package."
      return 1
    fi
  else
    log_info "$package is already installed."
    return 0
  fi
}

### Execute Task
#
# Function..........: execute_task
# Description.......: Executes a task with optional prerequisites and post actions. Validates each step and handles errors.
# Parameters........: 
#              - $1: Name of the task.
#              - $2: Boolean indicating if root privileges are required.
#              - $3: Command string for prerequisites.
#              - $4: Command string for the main actions.
#              - $5: Command string for post actions.
# Returns...........: 
#              - 0: If all steps are successfully executed.
#              - 1: If any step fails.
# Output............: Logs the progress and results of each step.
#
###
execute_task() {

  local name="$1"
  local require_root="$2"
  local prereq="$3"
  local actions="$4"
  local postActions="$5"

  log_task "$name"

  # 01 - Check for root privileges if required
  if [[ "$require_root" == "true" ]]; then
    if ! verify_has_root_privileges; then
      log_error "Root privileges required for $name."
      return 1
    fi
  fi

  # 02 - Execute the prerequisite if provided
  if [ -n "$prereq" ]; then

    log_prerequisite "Executing prerequisites for $name..."
    
    if eval "$prereq"; then
      log_info "Prerequisites completed"
    else
      log_error "Prerequisites failed"
      return 1  # Stop the procedure if the prerequisite fails
    fi  

  fi

  # 03 - Execute the actions
  log_action "Executing actions for $name..."

  if eval "$actions"; then
    log_info "Actions completed"
  else
    log_error "Actions failed"
    return 1  # Optionally stop also if actions fail
  fi

  # 04 - Execute the post action
  if [ -n "$postActions" ]; then  # Check if 'postActions' variable is not empty

      log_post_actions "Executing post actions for $name..."

      if ! eval "$postActions"; then
          log_error "Post actions failed"
          return 1  # Stop the script if post actions fails
      else
          log_info "Post actions completed successfully"
      fi

  fi

  log_info "Task $name execution completed successfully"
}
