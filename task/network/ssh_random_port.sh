#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task for Setting a Random SSH Port
#
# Function..........: task_ssh_random_port
# Description.......: Executes a series of actions to set a random port for the SSH service. 
#                     This involves checking prerequisites, executing the main action to set a random port,
#                     and performing any necessary post-actions. The task ensures enhanced security by 
#                     changing the SSH port to a non-standard value.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement,
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If the process of setting a random SSH port is successful.
#               - 1 (NOK): If any step in the process fails.
#
###
task_ssh_random_port() {
  
  # Random port ssh
  local name="ssh_random_port"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Failed to set a random SSH port."
    return "$NOK"
  fi

  log_info "Random SSH port has been successfully set."
  
  return "$OK"
}

### Check Prerequisites for SSH Random Port Configuration
#
# Function..........: check_prerequisites_ssh_random_port
# Description.......: Verifies if the SSH package is installed on the system. If not, it attempts to install 
#                     the SSH package. This check ensures that the necessary SSH tools are available 
#                     before attempting to modify SSH configuration settings, like changing the SSH port.
# Returns...........: 
#               - 0 (OK): If the SSH package is already installed or successfully installed during the execution.
#               - 1 (NOK): If the SSH package cannot be installed.
#
###
check_prerequisites_ssh_random_port() {
  # install ssh package
  if ! install_package "ssh"; then
    return "$NOK"
  fi

  return "$OK"
}

### Run Action to Set a Random SSH Port
#
# Function..........: run_action_ssh_random_port
# Description.......: Sets a random port for the SSH service by modifying the SSH configuration file (sshd_config). 
#                     It selects a random port between 1024 and 65535, then updates the sshd_config file to use this port. 
#                     After updating the configuration, the SSH service is restarted to apply the changes.
#                     The new port number is also saved to a file (/etc/ssh/ssh_port_info.txt) for reference.
# Parameters........: None. Uses local variables to generate a random port and define actions.
# Returns...........: The return status of the 'execute_task' function, which executes the actions and configurations.
#
###
run_action_ssh_random_port() {
  local random_port
  local user_response

  while true; do
    random_port=$(shuf -i 1024-65535 -n 1) # Generate a random port between 1024 and 65535
    read -p "Use port $random_port for SSH? (y/n): " user_response

    case $user_response in
      [Yy]* ) 
        sed -i "s/^#Port 22/Port $random_port/" /etc/ssh/sshd_config
        log_info "SSH is now listening on port: $random_port"
        break;;
      [Nn]* ) 
        log_debug "Skipping port $random_port."
        continue;;
      * ) 
        echo "Please answer yes or no.";;
    esac
  done
}

### Post Actions for SSH Random Port Configuration
#
# Function..........: post_actions_ssh_random_port
# Description.......: Performs the final action after setting a random SSH port, which involves restarting 
#                     the SSH service. This ensures that the new port setting takes effect. The function checks 
#                     if the SSH service is active and then attempts to restart it.
# Returns...........: 
#               - 0 (OK): If the SSH service is active and successfully restarted.
#               - 1 (NOK): If the SSH service is not active or fails to restart.
#
###
post_actions_ssh_random_port() {
  log_info "Restarting SSH service to apply random port changes."

  # Using systemctl to restart the SSH service
  if systemctl is-active --quiet ssh; then
    systemctl restart ssh
    if [ $? -eq 0 ]; then
      log_info "SSH service restarted successfully to apply new port settings."
    else
    log_error "SSH service is not active and cannot be restarted."
      return "$NOK"
    fi
  else
    log_error "SSH service is not active and cannot be restarted."
    return "$NOK"
  fi


  return "$OK"
}


# Run the task to set a random SSH port
task_ssh_random_port