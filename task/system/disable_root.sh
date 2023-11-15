#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task for Disabling Root System Login
#
# Function..........: task_system_disable_root
# Description.......: Executes the process of disabling the root system login. This is done by executing
#                     a series of actions defined in the 'run_action_system_disable_root' function. 
#                     It ensures that root login is securely disabled to enhance system security.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement,
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If disabling root system login is successful.
#               - 1 (NOK): If the process fails.
#
###
task_system_disable_root() {

  local name="system_disable_root"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "System root login deactivation failed."
    return "$NOK"
  fi

  log_info "System root login has been successfully deactivated."
  
  return "$OK"
}

### Prerequisite Check for Disabling Root System Login
#
# Function..........: prerequisite_system_disable_root
# Description.......: Checks if there is at least one user with sudo privileges on the system. If no sudoers 
#                     are found, it prompts the user for confirmation before proceeding to disable the root 
#                     account. This is a safety measure to avoid locking out of administrative access.
# Returns...........: 
#               - 0 (OK): If there is at least one sudoer or the user confirms to proceed without a sudoer.
#               - 1 (NOK): If there are no sudoers and the user chooses not to proceed.
#
###
prerequisite_system_disable_root() {
    local sudoers_count
    sudoers_count=$(getent group sudo | cut -d: -f4 | tr ',' ' ' | wc -w)

    if [[ $sudoers_count -eq 0 ]]; then
        log_warn "No users with sudo privileges found. Disabling root may lock out administrative access."

        read -rp "Are you sure you want to continue? (y/N): " confirmation
        case "$confirmation" in
            [Yy]* )
                log_info "Proceeding with root account deactivation."
                return "$OK"
                ;;
            * )
                log_error "Root deactivation aborted. No sudoers available."
                return "$NOK"
                ;;
        esac
    fi

    log_info "Sudoers available. Safe to proceed with root deactivation."

    return "$OK"
}


### Run Action to Disable Root System Login
#
# Function..........: run_action_system_disable_root
# Description.......: Disables the root system login by changing the root password to a random, 
#                     securely generated string. This enhances system security by making the root 
#                     account inaccessible via traditional login methods. The function uses OpenSSL 
#                     to generate a random base64-encoded password.
# Returns...........: None directly. Outputs to stdout and logs information upon successful completion.
#
###
run_action_system_disable_root() {

    local random_password=$(openssl rand -base64 48)
    log_info "Generating a random password for root."

    echo "root:$random_password" | chpasswd

    log_info "Root account password has been changed to a random value, effectively disabling direct root login."
}

# Run the task to disable root account
task_system_disable_root