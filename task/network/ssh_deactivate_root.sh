#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task to Deactivate Root SSH Login
#
# Function..........: task_ssh_deactivate_root
# Description.......: Executes a series of steps to deactivate root SSH login. The function checks prerequisites, 
#                     executes the main action to modify SSH settings, and performs any necessary post-actions. 
#                     This task is crucial for enhancing the security of the SSH service.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement, 
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If all steps are successfully executed.
#               - 1 (NOK): If any step in the process fails.
#
###
task_ssh_deactivate_root() {

  # Deactivate root SSH login
  local name="ssh_deactivate_root"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "SSH root deactivation failed."
    return "$NOK"
  fi

  log_info "Root SSH login has been successfully deactivated."
  
  return "$OK"
}

### Check Prerequisites for Deactivating Root SSH
#
# Function..........: check_prerequisites_ssh_deactivate_root
# Description.......: Ensures that all prerequisites for deactivating root SSH login are met. This function primarily 
#                     checks for the installation of the SSH package and installs it if not already present.
# Returns...........: 
#               - 0 (OK): If the SSH package is installed or successfully installed.
#               - 1 (NOK): If the installation of the SSH package fails.
#
###
check_prerequisites_ssh_deactivate_root() {

  # install ssh package
  if ! install_package "ssh"; then
    return "$NOK"
  fi

  return "$OK"
}

### Run Action to Deactivate Root SSH Login
#
# Function..........: run_action_ssh_deactivate_root
# Description.......: Modifies the SSH daemon configuration to deactivate root login. It checks the current 
#                     setting of 'PermitRootLogin' in the sshd_config file. If it's set to 'yes', the function 
#                     changes it to 'no'. If the setting is absent or set to any other value, it adds 'PermitRootLogin no'.
#                     After modifying the configuration, it restarts the SSH service to apply changes.
# Parameters........: None. Relies on global variables such as 'sshd_config'.
# Returns...........: The return status of the 'execute_task' function, which executes the actions and configurations.
#
###
run_action_ssh_deactivate_root() {

  local sshd_config="/etc/ssh/sshd_config"

  log_info "Checking SSH configuration for PermitRootLogin setting."

  # Check if PermitRootLogin is set to 'no' or 'yes'
  if grep -q "^PermitRootLogin no" "$sshd_config"; then
      log_info "PermitRootLogin is already set to 'no'. No changes needed."
  elif grep -q "^PermitRootLogin yes" "$sshd_config"; then
      log_info "PermitRootLogin set to 'yes'. Changing to 'no'."
      # If it exists and is set to 'yes', replace it with 'no'
      sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' "$sshd_config"
  else
      log_info "PermitRootLogin is not set. Adding 'PermitRootLogin no'."
      # If 'PermitRootLogin' is not set to either 'yes' or 'no', add 'PermitRootLogin no' to the file
      echo 'PermitRootLogin no' | tee -a "$sshd_config"
  fi

  return "$OK"
}

### Post Actions for Deactivating Root SSH
#
# Function..........: post_actions_ssh_deactivate_root
# Description.......: Performs post-action tasks after modifying SSH configuration to deactivate root login.
#                     This primarily involves restarting the SSH service to apply the changes made to the configuration.
#                     It checks if the SSH service is active and then attempts to restart it.
# Returns...........: 
#               - 0 (OK): If the SSH service is successfully restarted.
#               - 1 (NOK): If the SSH service is not active or fails to restart.
#
###
post_actions_ssh_deactivate_root() {
  log_info "Restarting SSH service to apply changes."

  # Using systemctl to restart the SSH service
  if systemctl is-active --quiet ssh; then

    systemctl restart sshd

    if [ $? -eq 0 ]; then
      log_info "SSH service restarted successfully."
      
    else
      log_error "Failed to restart SSH service."
      return "$NOK"

    fi

  else
    log_error "SSH service is not active."
    return "$NOK"

  fi

  return "$OK"
}


# Run the task to deactivate root SSH login
task_ssh_deactivate_root