#!/bin/bash

# import
source "$(dirname "$0")/../core/logger.sh"
source "$(dirname "$0")/../core/execute_task.sh"

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
        return 1
    fi

    log_info "System update and upgrade completed successfully."
    return 0
}

# Run the update and upgrade function
task_update_and_upgrade