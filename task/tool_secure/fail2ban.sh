# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task for Installing and Configuring Fail2Ban
#
# Function..........: task_fail2ban
# Description.......: Performs the task of installing and configuring Fail2Ban on the system. Fail2Ban is a tool 
#                     that helps protect against unauthorized access by monitoring system logs and automatically 
#                     banning IP addresses that show malicious signs. This task involves checking prerequisites, 
#                     running the installation and configuration actions, and performing any necessary post-actions.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement,
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If Fail2Ban is successfully installed and configured.
#               - 1 (NOK): If the process fails at any point.#
###
task_fail2ban() {
  
  local name="add_fail2ban"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" "$task_type" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Fail2Ban installation and configuration failed."
    return "$NOK"
  fi

  log_info "Fail2Ban has been successfully installed and configured."
  
  return "$OK"
}

### Check Prerequisites for Fail2Ban Installation
#
# Function..........: check_prerequisites_fail2ban
# Description.......: Verifies if the Fail2Ban package is installed on the system. If not, it attempts to 
#                     install Fail2Ban. Fail2Ban is an intrusion prevention software framework that protects 
#                     computer servers from brute-force attacks.
# Returns...........: 
#               - 0 (OK): If Fail2Ban is already installed or successfully installed during the execution.
#               - 1 (NOK): If Fail2Ban cannot be installed.
#
###
check_prerequisites_fail2ban() {
  # install fail2ban package
  if ! install_package "fail2ban"; then
    return "$NOK"
  fi

  return "$OK"
}

### Run Action to Configure Fail2Ban
#
# Function..........: run_action_fail2ban
# Description.......: Sets up the basic configuration for Fail2Ban by creating and populating a 'jail.local' file. 
#                     This file sets the default ban time, find time, and maximum retry attempts before an IP is banned. 
#                     These settings are crucial for defining how Fail2Ban handles potential security threats.
# Parameters........: None. The function uses hardcoded values and a predefined path for the 'jail.local' file.
# Returns...........: None directly. The configuration is written to '/etc/fail2ban/jail.local'.
#
###
run_action_fail2ban() {

    local jail_local="/etc/fail2ban/jail.local"

    log_info "Configuring Fail2Ban with basic settings in jail.local."

    echo '[DEFAULT]' | sudo tee $jail_local
    echo 'bantime = 10m' | sudo tee -a $jail_local
    echo 'findtime = 10m' | sudo tee -a $jail_local
    echo 'maxretry = 5' | sudo tee -a $jail_local

    log_info "Fail2Ban configuration successfully written to $jail_local."
}

### Post Actions for Fail2Ban Configuration
#
# Function..........: post_actions_fail2ban
# Description.......: Restarts the Fail2Ban service to apply any new configurations made to the system. This function 
#                     first checks if the Fail2Ban service is active and then proceeds to restart it, ensuring that 
#                     all configuration changes are loaded and enforced.
# Returns...........: 
#               - 0 (OK): If the Fail2Ban service is successfully restarted.
#               - 1 (NOK): If the Fail2Ban service is not active or fails to restart.
#
###
post_actions_fail2ban() {
  
    log_info "Restarting Fail2Ban service to apply new configuration."

    if systemctl is-active --quiet fail2ban; then
        sudo systemctl restart fail2ban
        if [ $? -eq 0 ]; then
            log_info "Fail2Ban service restarted successfully."
        else
            log_error "Failed to restart Fail2Ban service."
            return "$NOK"
        fi
    else
        log_error "Fail2Ban service is not active."
        return "$NOK"
    fi

    return "$OK"
}

# Run the task to add fail2ban and configure
task_fail2ban