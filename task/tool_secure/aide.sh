#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task for Installing and Configuring AIDE
#
# Function..........: task_add_aide
# Description.......: Installs and configures AIDE (Advanced Intrusion Detection Environment) on the system. AIDE is 
#                     a file integrity checker used to detect unauthorized changes to files. The task involves 
#                     executing a series of steps: checking prerequisites, performing the installation and initial 
#                     configuration of AIDE, and executing post-installation actions.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement, 
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If AIDE is successfully installed and configured.
#               - 1 (NOK): If the process fails at any point.
##
task_add_aide() {
  
  local name="add_aide"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "add_aide failed."
    return "$NOK"
  fi

  log_info "add_aide has been successfully add_aidex."
  
  return "$OK"
}

### Check Prerequisites for AIDE Installation
#
# Function..........: check_prerequisites_add_aide
# Description.......: Checks and ensures that the prerequisites for installing AIDE (Advanced Intrusion Detection 
#                     Environment) are met. This primarily involves the installation of the AIDE package. The function 
#                     uses an `install_package` utility to attempt the installation of AIDE.
# Parameters........: 
#               - None. The function directly checks for the presence of the AIDE package and attempts to install it.
# Returns...........: 
#               - 0 (OK): If the AIDE package is successfully installed or already present.
#               - 1 (NOK): If the installation fails.
##
check_prerequisites_add_aide() {
  # Install AIDE package
  if ! install_package "aide"; then
    return "$NOK"
  fi

  return "$OK"
}

### Run Action for AIDE Initialization
#
# Function..........: run_action_add_aide
# Description.......: Executes the initial setup of AIDE (Advanced Intrusion Detection Environment). This includes 
#                     initializing the AIDE database by running 'aideinit'. After initialization, it checks for the 
#                     creation of the new AIDE database file and moves it to the active database location.
# Parameters........: 
#               - None. The function executes the AIDE initialization process without additional parameters.
# Returns...........: 
#               - 0 (OK): If the AIDE database is successfully initialized and configured.
#               - 1 (NOK): If there is a failure in creating or setting up the AIDE database.
##
run_action_add_aide() {
  # Initialize AIDE database
  log_info "Configuring aide.conf..."
  
  echo "!/home/.*" >> /etc/aide/aide.conf
  echo "!/var/log/.*" >> /etc/aide/aide.conf
  

  log_info "Initializing AIDE database..."

  aide --config /etc/aide/aide.conf --init 

  if [ -f /var/lib/aide/aide.db.new ]; then
    cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    return "$OK"
  else
    log_error "Failed to create AIDE database."
    return "$NOK"
  fi
}

### Post-Installation Actions for AIDE
#
# Function..........: post_actions_add_aide
# Description.......: Performs post-installation actions for AIDE (Advanced Intrusion Detection Environment). 
#                     This includes running a manual AIDE check to verify the correct functioning of AIDE. The function
#                     logs the initiation of the check, executes the `aide --check` command, and then assesses the 
#                     outcome to ensure the integrity check completes successfully.
# Parameters........: 
#               - None. The function executes the AIDE check without additional parameters.
# Returns...........: 
#               - 0 (OK): If the AIDE check is completed successfully and verification passes.
#               - 1 (NOK): If the AIDE check fails, indicating a problem with the AIDE setup.
##
post_actions_add_aide() {
  # Run a manual AIDE check for verification purposes
  log_info "Running a manual AIDE check for verification..."
  aide --config /etc/aide/aide.conf --check

  # Check the exit status of the last command (AIDE check)
  if [ $? -eq 0 ]; then
    log_info "AIDE check completed successfully. Verification passed."
    return "$OK"
  else
    log_error "AIDE check failed. Verification did not pass."
    return "$NOK"
  fi
}

# Run the task to add_aide
task_add_aide
