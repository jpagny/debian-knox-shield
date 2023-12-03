#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task for Installing and Configuring Lynis
#
# Function..........: task_add_lynis
# Description.......: Installs and configures Lynis, a security auditing tool, on the system. Lynis is used for 
#                     performing security checks, system audits, and compliance testing. The task involves executing 
#                     a series of steps: checking prerequisites, installing Lynis, and optionally running post-installation 
#                     actions.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement, 
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If Lynis is successfully installed and configured.
#               - 1 (NOK): If the installation or configuration process fails at any point.
##
task_add_lynis() {
  
  local name="add_lynis"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "add_lynis failed."
    return "$NOK"
  fi

  log_info "add_lynis has been successfully add_lynisx."
  
  return "$OK"
}

### Check Prerequisites for Lynis Installation
#
# Function..........: check_prerequisites_add_lynis
# Description.......: Checks and ensures that the prerequisites for installing Lynis are met. This primarily 
#                     involves the installation of the Lynis package. The function uses an `install_package` 
#                     utility to attempt the installation of Lynis.
# Parameters........: 
#               - None. The function directly checks for the presence of the Lynis package and attempts to install it.
# Returns...........: 
#               - 0 (OK): If the Lynis package is successfully installed or already present.
#               - 1 (NOK): If the installation fails.
##
check_prerequisites_add_lynis() {
  # Install Lynis
  if ! install_package "lynis"; then
    log_error "Failed to install Lynis."
    return "$NOK"
  fi
  
  return "$OK"
}

### Run Action for Lynis Audit
#
# Function..........: run_action_add_lynis
# Description.......: Executes the Lynis audit process. This function is responsible for running the Lynis 
#                     command to perform a system-wide audit. It logs the initiation of the audit, executes the 
#                     `lynis audit system` command, and then assesses the outcome to ensure the audit completes 
#                     successfully.
# Parameters........: 
#               - None. The function executes the Lynis audit without additional parameters.
# Returns...........: 
#               - 0 (OK): If the Lynis audit is completed successfully.
#               - 1 (NOK): If there is a failure in the Lynis audit process.
##
run_action_add_lynis() {
  log_info "Running system audit..."

  # Run Lynis audit
  lynis audit system

  # Check the exit status of the Lynis command
  if [ $? -eq 0 ]; then
    log_info "Lynis audit completed successfully."
  else
    log_error "Lynis audit encountered issues."
    return "$NOK"
  fi

  return "$OK"
}

# Run the task to add_lynis
task_add_lynis
