#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task for Setting a change SSH Port
#
# Function..........: task_ssh_change_port
# Description.......: Executes a series of actions to set a new port for the SSH service. 
#                     This involves checking prerequisites, executing the main action to set a new port,
#                     and performing any necessary post-actions. The task ensures enhanced security by 
#                     changing the SSH port to a non-standard value.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement,
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If the process of setting a new SSH port is successful.
#               - 1 (NOK): If any step in the process fails.
#
###
task_ssh_change_port() {
  
  # Change port ssh
  local name="ssh_change_port"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Failed to change SSH port."
    return "$NOK"
  fi

  log_info "Change SSH port has been successfully set."
  
  return "$OK"
}

### Check Prerequisites for SSH Change Port Configuration
#
# Function..........: check_prerequisites_ssh_change_port
# Description.......: Verifies if the SSH package is installed on the system. If not, it attempts to install 
#                     the SSH package. This check ensures that the necessary SSH tools are available 
#                     before attempting to modify SSH configuration settings, like changing the SSH port.
# Returns...........: 
#               - 0 (OK): If the SSH package is already installed or successfully installed during the execution.
#               - 1 (NOK): If the SSH package cannot be installed.
#
###
check_prerequisites_ssh_change_port() {
  # install ssh package
  if ! install_package "ssh"; then
    return "$NOK"
  fi

  return "$OK"
}

### Run Action to Set a Change SSH Port
#
# Function..........: run_action_ssh_change_port
# Description.......: Sets a new port for the SSH service by modifying the SSH configuration file (sshd_config). 
#                     It selects a new port between 1024 and 65535, then updates the sshd_config file to use this port. 
#                     After updating the configuration, the SSH service is restarted to apply the changes.
#                     The new port number is also saved to a file (/etc/ssh/ssh_port_info.txt) for reference.
# Parameters........: None. Uses local variables to generate a new port and define actions.
# Returns...........: The return status of the 'execute_task' function, which executes the actions and configurations.
#
###
run_action_ssh_change_port() {
  local configCredentials="$(dirname "$0")/../config/credentials.txt"
  local random_port
  local user_response

  if grep -q "^#task_ssh_change_port" "$configCredentials"; then

    portNumber=$(grep "port_number" "$configCredentials" | cut -d '=' -f 2)
    sed -i "s/^#Port 22/Port $portNumber/" /etc/ssh/sshd_config

    log_info "SSH is now listening on port: $random_port"

  else

    while true; do
      random_port=$(shuf -i 1024-65535 -n 1)
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

  fi
}

### Post Actions for SSH Change Port Configuration
#
# Function..........: post_actions_ssh_change_port
# Description.......: Performs the final action after setting a new SSH port, which involves restarting 
#                     the SSH service. This ensures that the new port setting takes effect. The function checks 
#                     if the SSH service is active and then attempts to restart it.
# Returns...........: 
#               - 0 (OK): If the SSH service is active and successfully restarted.
#               - 1 (NOK): If the SSH service is not active or fails to restart.
#
###
post_actions_ssh_change_port() {
  log_info "Restarting SSH service to apply new port changes."

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


# Run the task to set a change SSH port
task_ssh_change_port