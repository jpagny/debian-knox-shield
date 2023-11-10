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