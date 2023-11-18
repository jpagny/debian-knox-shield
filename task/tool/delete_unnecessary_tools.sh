#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Delete Unnecessary Tools
#
# Function..........: task_delete_unnecessary_tools
# Description.......: Executes a task to remove unnecessary tools from the system. 
#                     This is typically done to improve system security by reducing the 
#                     attack surface area. The task may include removing unused software, 
#                     services, or features that are not required for the system's operation.
#
# Returns...........: 
#               - 0 (OK): If the task is completed successfully.
#               - 1 (NOK): If the task fails.
#
##
task_delete_unnecessary_tools() {
  
  local name="delete_unnecessary_tools"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "xxxx failed."
    return "$NOK"
  fi

  log_info "xxxx has been successfully xxxxx."
  
  return "$OK"
}

### Run Action to Delete Unnecessary Tools
#
# Function..........: run_action_delete_unnecessary_tools
# Description.......: Executes the removal of specified unnecessary tools from the system. 
#                     This is aimed at enhancing system security by removing potentially 
#                     vulnerable or unused software.
#
# Parameters........: None
# Returns...........: 
#               - 0 (OK): If all specified packages are either successfully removed or were not installed.
#               - Non-zero value: If there's an error in removing any of the packages.
#
##
run_action_delete_unnecessary_tools() {

    # Define a list of unnecessary packages to be removed
    local packages=("telnet" "nis" "ntpdate")

    # Loop through each package and remove it if installed
    for pkg in "${packages[@]}"; do
        if dpkg -l "$pkg" | grep -qw "^ii"; then
            log_info "Removing $pkg..."
            apt-get -y --purge remove "$pkg" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                log_info "$pkg removed successfully."
            else
                log_error "Failed to remove $pkg."
            fi
        else
            log_info "$pkg is not installed or already removed."
        fi
    done

    return "$OK"
}

### Post-Action Checks for Deleting Unnecessary Tools
#
# Function..........: post_actions_delete_unnecessary_tools
# Description.......: Performs post-action checks to confirm the removal of unnecessary tools from the system.
#                     This function iterates through a predefined list of packages and verifies whether they
#                     have been successfully removed.
#
# Parameters........: None
# Returns...........: 
#               - 0 (OK): If all checks are completed successfully.
#               - Non-zero value: If any error occurs during the checks.
##
post_actions_delete_unnecessary_tools() {

    # Define a list of packages to check
    local packages=("telnet" "nis" "ntpdate")

    # Loop through each package and check if it has been removed
    for pkg in "${packages[@]}"; do
        if dpkg -l "$pkg" | grep -qw "^ii"; then
            log_warn "$pkg is not removed."
        else
            log_info "$pkg is removed."
        fi
    done

    return "$OK"
}

# Run the task to delete unnecessary tools
task_delete_unnecessary_tools