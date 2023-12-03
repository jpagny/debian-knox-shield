#!/bin/bash

# import
# shellcheck source=/dev/null
source "00_variable_global.sh"
source "01_logger.sh"

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
        return "$NOK"
    fi

    return "$OK"
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

  # Check if APT is available
  if ! command -v apt-get &> /dev/null; then
    log_error "APT package manager not found. This script is intended for Debian-based systems."
    return "$NOK"
  fi

  # Check if the package is already installed using dpkg
  if dpkg -l "$package" | grep -qw "^ii"; then
    log_info "$package is already installed."
    return "$OK"
  else
    log_info "$package is not installed. Installing..."

    if apt-get update &> /dev/null && apt-get install -y "$package" &> /dev/null; then
      log_info "$package has been installed successfully."
      return "$OK"
    else
      log_error "Failed to install $package."
      return "$NOK"
    fi
  fi
}

### Ask for Username Approval
#
# Function..........: ask_for_username_approval
# Description.......: Fetches a random username from an API and asks for user approval.
# Returns...........: The approved username.
# Output............: Logs the progress and results of the username approval process.
#
##
ask_for_username_approval() {

  local userData 
  local username 
  local approval="n"

  while [ "$approval" != "y" ]; do
    userData=$(curl -s https://randomuser.me/api/)
    
    log_debug "Fetched JSON data: $userData"

    username=$(echo "$userData" | jq -r '.results[0].login.username')

    log_debug "Extracted username: $username"

    if [ -z "$username" ]; then
      echo "No username was extracted. There might be an issue with the API or jq parsing."
      continue
    fi

    log_debug "Generated username: $username"

    read -r -p "Do you like this username : $username ? (y/n): " approval
    
    if [ "$approval" != "y" ]; then
      log_debug "Fetching a new username..."
    fi

  done

  echo "$username"
}

### Ask for Password Approval
#
# Function..........: ask_for_password_approval
# Description.......: Generates a strong password using the generate_strong_password function and asks for user approval.
# Returns...........: The approved strong password.
# Output............: Echoes the generated password and the query for approval, and logs the progress of password generation and approval.
#
##
ask_for_password_approval() {

  while true; do
    local password=$(pwgen -s -y -c -n 20 1)

    # Is it safe to show password ? 
    read -p "Do you approve this password : $password ? (y/n): " approval

    if [[ "$approval" == "y" || "$approval" == "Y" ]]; then
      echo "$password"
      break
    else
      echo "Generating a new password..."
    fi
  done
}