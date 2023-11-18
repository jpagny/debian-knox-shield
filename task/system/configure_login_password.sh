#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Configure Login Password Settings
#
# Function..........: task_configure_login_password
# Description.......: Modifies the system's login password policies and settings as defined 
#                     in the system's login definitions file (usually /etc/login.defs). 
#                     This function adjusts settings like maximum and minimum password age, 
#                     password complexity, and other related configurations.
#
# Returns...........: 
#               - 0 (OK): If the task completes successfully.
#               - 1 (NOK): If the task encounters an error or fails.
##
task_configure_login_password() {
  
  local name="configure_login_password"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "xxxx failed."
    return "$NOK"
  fi

  log_info "xxxx has been successfully xxxxx."
  
  return "$OK"
}

### Run Action to Configure Login Password Settings
#
# Function..........: run_action_configure_login_password
# Description.......: Executes modifications to the system's login password settings, 
#                     specifically targeting the /etc/login.defs file. It adjusts various 
#                     parameters like SHA encryption rounds, password aging, and default umask.
#
# Returns...........: 
#               - 0 (OK): If all modifications are successfully applied.
#               - Non-zero value: If an error occurs during the modification process.
##
run_action_configure_login_password() {

    sed -i '/# SHA_CRYPT_MAX_ROUNDS/s/5000/1000000/g' /etc/login.defs
    sed -i '/# SHA_CRYPT_MIN_ROUNDS/s/5000/1000000/g' /etc/login.defs
    sed -i '/PASS_MAX_DAYS/s/99999/180/g' /etc/login.defs
    sed -i '/PASS_MIN_DAYS/s/0/1/g' /etc/login.defs
    sed -i '/PASS_WARN_AGE/s/7/28/g' /etc/login.defs
    sed -i '/UMASK/s/022/027/g' /etc/login.defs
    sed -i '/# SHA_CRYPT_MAX_ROUNDS/s/#//g' /etc/login.defs
    sed -i '/# SHA_CRYPT_MIN_ROUNDS/s/#//g' /etc/login.defs

    return "$OK"
}

# Run the task to configure login password
task_configure_login_password