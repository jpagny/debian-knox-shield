#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task: Configure UFW Settings
#
# Function..........: task_ufw_settings
# Description.......: This task configures UFW settings on the system. It ensures that UFW is 
#                     installed, deactivates it if active, and sets firewall rules to allow SSH and HTTP(S) traffic while 
#                     blocking all other incoming and outgoing traffic.
# Parameters........: None
# Returns...........: 
#               - 0 (OK): If UFW settings are successfully configured as specified.
#               - 1 (NOK): If the task fails to complete successfully.
#
##
task_ufw_settings() {
  
  local name="ufw_settings"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
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

### Check Prerequisites for UFW Settings
#
# Function..........: check_prerequisites_ufw_settings
# Description.......: Ensures that all prerequisites for configuring UFW settings are met. 
#                     This function checks for the installation of the UFW package and disables UFW if it's active.
# Returns...........: 
#               - 0 (OK): If the UFW package is installed and UFW is either inactive or successfully disabled.
#               - 1 (NOK): If the installation of the UFW package fails or disabling UFW fails.
#
##
check_prerequisites_ufw_settings() {
  # install ufw package
  if ! install_package "ufw"; then
    return "$NOK"
  fi

  if ufw status | grep -q "Status: active"; then
    ufw disable
    log_info "UFW has been disabled."
  fi

  return "$OK"
}

### Action: Configure UFW Settings
#
# Function..........: run_action_ufw_settings
# Description.......: This action configures UFW settings on the system. It retrieves the SSH port 
#                     from the SSH configuration file, resets UFW to its default state, sets default policies to deny 
#                     incoming and outgoing traffic, and then allows incoming and outgoing traffic for HTTP (port 80), HTTPS 
#                     (port 443), and SSH. This effectively blocks all other incoming and outgoing traffic except for the 
#                     specified services.
# Returns...........: 
#               - 0 (OK): If UFW settings are successfully configured as specified.
#
##
run_action_ufw_settings() {

    # Retrieve the SSH port
    local ssh_port=$(grep ^Port /etc/ssh/sshd_config | awk '{print $2}')
    if [ -z "$ssh_port" ]; then
        ssh_port=22  # default SSH port
    fi
    log_info "SSH is configured to use port $ssh_port."

    # Reset UFW to default to ensure a clean slate
    ufw --force reset

    # Set default policies
    ufw default deny incoming
    ufw default deny outgoing

    # Allow HTTP (port 80), 
    ufw allow in on http port 80
    ufw allow out on http port 80

    # Allow HTTPS (port 443), and 
    ufw allow in on https port 443
    ufw allow out on https port 443

    # Allow SSH port
    ufw allow in on $ssh_port
    ufw allow out on $ssh_port

    log_info "UFW has been configured: HTTPS and SSH ($ssh_port) are allowed; all other traffic is denied."

    return "$OK"
}

### Post-Action: Enable and Verify UFW Settings
#
# Function..........: post_actions_ufw_settings
# Description.......: This post-action enables UFW on the system and verifies its status to ensure 
#                     that it is active and running. It also logs the relevant status information.
# Returns...........: 
#               - 0 (OK): If UFW is successfully enabled and verified to be active.
#               - 1 (NOK): If UFW fails to enable or is not active as expected.
#
##
post_actions_ufw_settings() {

    ufw enable
    log_info "UFW has been enabled."

    # Test UFW status
    local ufw_status=$(ufw status)
    if [[ $ufw_status == *"Status: active"* ]]; then
        log_info "UFW is active and running."
    else
        log_error "UFW is not active. Please check the configuration."
        return "$NOK"
    fi

    return "$OK"
}


# Run the task to ufw settings
task_ufw_settings
