#!/bin/bash

# import
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task - system update && upgrade
#
# Function..........: update_and_upgrade
# Description:......: Updates and upgrades the system using apt-get. 
#                     This function executes the system update and upgrade process.
# Requires Root:....: Yes
# Returns:..........: Returns 1 on failure, otherwise void.
#
###
task_update_and_upgrade() {

    local name="System update && upgrade"
    local isRootRequired=true
    local prereq=""
    local actions="apt-get update &> /dev/null && apt-get upgrade -y &> /dev/null" 
    local postActions=""

    if ! execute_task "$name" $isRootRequired "$prereq" "$actions" "$postActions"; then
        log_error "System upgrade failed."
        return $NOK
    fi

    log_info "System update and upgrade completed successfully."
    return $OK
}

# Run the update and upgrade function
task_update_and_upgrade