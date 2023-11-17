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
  if dpkg -l "$package" &> /dev/null; then
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