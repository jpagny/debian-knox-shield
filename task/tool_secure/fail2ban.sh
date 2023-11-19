# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task for Installing and Configuring Fail2Ban
#
# Function..........: add_fail2ban
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
task_add_fail2ban() {
  
  local name="add_fail2ban"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Fail2Ban installation and configuration failed."
    return "$NOK"
  fi

  log_info "Fail2Ban has been successfully installed and configured."
  
  return "$OK"
}

### Check Prerequisites for Fail2Ban and Rsyslog Installation
#
# Function..........: check_prerequisites_add_fail2ban
# Description.......: Ensures that both 'rsyslog' and 'fail2ban' packages are installed on the system. 
#                     'rsyslog' is used for system logging, and its presence is crucial for Fail2Ban to monitor logs. 
#                     'fail2ban' is an intrusion prevention software framework that protects computer servers from brute-force attacks.
#                     The function attempts to install these packages if they are not already present.
# Returns...........: 
#               - 0 (OK): If both rsyslog and Fail2Ban are already installed or successfully installed during execution.
#               - 1 (NOK): If either rsyslog or Fail2Ban cannot be installed.
#
###
check_prerequisites_add_fail2ban() {

  # install rsyslog package
  if ! install_package "rsyslog"; then
    return "$NOK"
  fi

  # install fail2ban package
  if ! install_package "fail2ban"; then
    return "$NOK"
  fi

  local max_attempts=3
  local attempt=1

  # Check if fail2ban service is active, if not try to reconfigure and restart
  while ! systemctl is-active --quiet fail2ban; do
    if (( attempt > max_attempts )); then
      log_error "Failed to activate fail2ban service after $max_attempts attempts."
      return "$NOK"
    fi

    log_info "Fail2Ban service not active, attempting to reconfigure (Attempt $attempt/$max_attempts)."
    dpkg-reconfigure fail2ban

    # Increment the attempt counter
    ((attempt++))
  done

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
run_action_add_fail2ban() {

    local jail_local="/etc/fail2ban/jail.local"

    log_info "Configuring Fail2Ban with basic settings in jail.local."

    # Default configuration
    echo '[DEFAULT]' | sudo tee $jail_local
    echo 'bantime=10m' | sudo tee -a $jail_local
    echo 'findtime=10m' | sudo tee -a $jail_local
    echo 'maxretry=5' | sudo tee -a $jail_local

    # SSH specific configuration
    echo "" | sudo tee -a $jail_local
    echo '[sshd]' | sudo tee -a $jail_local
    echo 'enabled=true' | sudo tee -a $jail_local
    echo 'port=ssh' | sudo tee -a $jail_local
    echo 'filter=sshd' | sudo tee -a $jail_local
    echo 'logpath=/var/log/auth.log' | sudo tee -a $jail_local
    echo 'maxretry=5' | sudo tee -a $jail_local

    log_info "SSH Fail2Ban configuration successfully added to $jail_local."
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
post_actions_add_fail2ban() {
  
    log_info "Restarting Fail2Ban service to apply new configuration."

    systemctl enable fail2ban

    if systemctl is-active --quiet fail2ban; then
        systemctl restart fail2ban
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
task_add_fail2ban
