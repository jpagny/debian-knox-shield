#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task for Installing and Running chkrootkit
#
# Function..........: task_add_chkrootkit
# Description.......: Performs the task of installing and running chkrootkit on the system. chkrootkit is a tool 
#                     that scans for rootkits, backdoors, and possible local exploits. This task involves checking 
#                     prerequisites, executing the chkrootkit scan, and performing any necessary post-actions.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement,
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If chkrootkit is successfully executed.
#               - 1 (NOK): If the process fails at any point.
##
task_add_chkrootkit() {
  
  local name="add_chkrootkit"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "chkrootkit failed."
    return "$NOK"
  fi

  log_info "chkrootkit has been successfully chkrootkitx."
  
  return "$OK"
}

### Check Prerequisites for chkrootkit Installation
#
# Function..........: check_prerequisites_add_chkrootkit
# Description.......: Checks and ensures that the prerequisites for installing chkrootkit are met. This primarily 
#                     involves the installation of the chkrootkit package. The function uses an `install_package` 
#                     utility to attempt installation.
# Parameters........: 
#               - None. The function directly checks for the presence of the chkrootkit package and attempts to install it.
# Returns...........: 
#               - 0 (OK): If the chkrootkit package is successfully installed or already present.
#               - 1 (NOK): If the installation fails.
##
check_prerequisites_add_chkrootkit() {
  # install chkrootkit package
  if ! install_package "chkrootkit"; then
    return "$NOK"
  fi

  return "$OK"
}

### Run Action for chkrootkit
#
# Function..........: run_action_add_chkrootkit
# Description.......: Executes the chkrootkit scan. This function is responsible for actually running the chkrootkit 
#                     tool, which scans the system for known rootkits, backdoors, and potentially harmful local exploits.
#                     The function logs the initiation of the scan and then executes the chkrootkit command.
# Parameters........: 
#               - None. The function directly executes the chkrootkit scan without any additional parameters.
# Returns...........: 
#               - 0 (OK): Always returns OK as it does not check the outcome of the chkrootkit scan.
##
run_action_add_chkrootkit() {
  # Run chkrootkit scan
  log_info "Running chkrootkit scan..."
  chkrootkit

  return "$OK"
}

### Post Actions for chkrootkit
#
# Function..........: post_actions_add_chkrootkit
# Description.......: Configures the chkrootkit to run daily checks. This function modifies the chkrootkit configuration 
#                     file to enable automated daily scans. It uses the `sed` command to change the configuration setting 
#                     `RUN_DAILY` from "false" to "true" in the `/etc/chkrootkit.conf` file. It then verifies if the change 
#                     was successful.
# Parameters........: 
#               - None. The function operates directly on the chkrootkit configuration file.
# Returns...........: 
#               - 0 (OK): If the daily chkrootkit check is successfully enabled.
#               - 1 (NOK): If the process of enabling the daily check fails.
##
post_actions_add_chkrootkit() {
  # Edit chkrootkit configuration to enable daily runs
  sed -i 's/RUN_DAILY="false"/RUN_DAILY="true"/' /etc/chkrootkit/chkrootkit.conf

  if grep -q 'RUN_DAILY="true"' /etc/chkrootkit/chkrootkit.conf; then
    log_info "Daily chkrootkit check has been enabled."
    return "$OK"
  else
    log_error "Failed to enable daily chkrootkit check."
    return "$NOK"
  fi

  return "$OK"
}

# Run the task to chkrootkit
task_add_chkrootkit
