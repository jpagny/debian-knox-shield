#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task for Configuring Adduser Defaults
#
# Function..........: task_configure_adduser
# Description.......: Executes a series of actions to configure the default behavior of the `adduser` command,
#                     specifically setting the default directory permissions for new user directories to 0700.
#                     The function checks prerequisites, runs the configuration actions, and handles any post-actions.
#                     This task is critical for ensuring that new user directories are created with secure permissions.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement,
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If the task completes successfully and the default settings are applied.
#               - 1 (NOK): If the task fails at any step.
#
##
task_configure_adduser() {
  
  local name="configure_adduser"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "configure_adduser failed."
    return "$NOK"
  fi

  log_info "configure_adduser has been successfully configure_adduser."
  
  return "$OK"
}

### Check Prerequisites for Configuring Adduser
#
# Function..........: check_prerequisites_configure_adduser
# Description.......: Checks if the /etc/adduser.conf file exists, which is necessary for setting default user 
#                     directory permissions. This file is typically present in Debian-based distributions.
# Returns...........: 
#               - 0 (OK): If /etc/adduser.conf exists.
#               - 1 (KO): If /etc/adduser.conf does not exist.
##
check_prerequisites_configure_adduser() {
  if [ ! -f /etc/adduser.conf ]; then
    log_error "The /etc/adduser.conf file does not exist. This configuration step is required for Debian-based systems."
    return "$KO"
  fi

  return "$OK"
}

### Run Action for Configuring Adduser
#
# Function..........: run_action_configure_adduser
# Description.......: Modifies the /etc/adduser.conf file to set the default directory permissions for new user 
#                     directories to 0700. This change ensures that new user directories are created with permissions 
#                     allowing only the user access, enhancing privacy and security.
# Returns...........: 
#               - 0 (OK): If the modification is successful.
#               - 1 (KO): If an error occurs (handled outside this function).
##
run_action_configure_adduser() {
  # Change the DIR_MODE in /etc/adduser.conf to set new user directories to 0700 permissions
  sed -i '/^DIR_MODE=/s/=.*/=0700/' /etc/adduser.conf
  
  return "$OK"
}

# Run the task to configure_adduser
task_configure_adduser
