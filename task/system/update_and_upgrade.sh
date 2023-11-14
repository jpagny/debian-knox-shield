#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Update and Upgrade System Task
#
# Function..........: task_update_and_upgrade 
# Description.......: Executes the system update and upgrade process. This function updates the package 
#                     lists and then performs an upgrade of all installed packages. The task requires root 
#                     privileges to execute and can be set as either mandatory or optional.
# Parameters........: None directly. The parameters such as task name, root requirement, actions, and task type 
#                     are predefined within the function.
# Returns...........: 
#               - 0 (OK): If the system update and upgrade complete successfully.
#               - 1 (NOK): If the update and upgrade process fails.
# Usage.............: This function is designed to be a part of a larger script or system setup routine. It should 
#                     be called when it's necessary to ensure the system is up-to-date.
# 
# Example...........: `task_update_and_upgrade` to execute the system update and upgrade.
#
###
task_update_and_upgrade() {

    local name="System update && upgrade"
    local isRootRequired=true
    local prereq=""
    local actions="apt-get update &> /dev/null && apt-get upgrade -y &> /dev/null" 
    local postActions=""
    local task_type=""

    if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
        log_error "System upgrade failed."
        return "$NOK"
    fi

    log_info "System update and upgrade completed successfully."
    return "$OK"
}

# Run the update and upgrade task
task_update_and_upgrade