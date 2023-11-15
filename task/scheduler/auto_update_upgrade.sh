# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task for Setting Up Automatic System Update and Upgrade Scheduler
#
# Function..........: task_scheduler_auto_update_upgrade
# Description.......: Sets up a scheduler for automatically updating and upgrading the system at regular intervals. 
#                     This task automates the process of keeping the system up-to-date with the latest packages 
#                     and security updates.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement,
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If the scheduler is successfully set up.
#               - 1 (NOK): If setting up the scheduler fails.
#
###
task_sheduler_auto_update_upgrade() {

  local name="sheduler_auto_update_upgrade"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" "$task_type" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Failed to set up automatic update and upgrade scheduler."
    return "$NOK"
  fi

  log_info "Automatic update and upgrade scheduler successfully set up."
  
  return "$OK"
}

check_prerequisites_sheduler_auto_update_upgrade() {

  # install ssh package
  if ! install_package "unattended-upgrades"; then
    return "$NOK"
  fi

  return "$OK"
}

### Run Action to Configure Automatic System Update and Upgrade
#
# Function..........: run_action_scheduler_auto_update_upgrade
# Description.......: Configures the system to perform automatic updates and upgrades using unattended-upgrades. 
#                     This function first configures the necessary parameters in the unattended-upgrades 
#                     configuration file. It then sets up automatic update checks and enables automatic upgrades 
#                     by modifying the apt configuration. A backup of the original configuration files is created 
#                     before any changes are made. Additionally, the function performs a dry run to test the 
#                     configuration.
# Parameters........: None. The function uses predefined file paths and configurations.
# Returns...........: None directly. Outputs information about the configuration process and performs a dry run test.
#
###
run_action_sheduler_auto_update_upgrade() {

    # Configure unattended-upgrades
    log_info "Configuring automatic updates..."
    cp /etc/apt/apt.conf.d/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades.backup
    sed -i '/"${distro_id}:${distro_codename}-updates";/s/^\/\/ //' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i '/"${distro_id}:${distro_codename}-security";/s/^\/\/ //' /etc/apt/apt.conf.d/50unattended-upgrades

    # Enable automatic updates
    log_info "Activating automatic updates and upgrades..."
    cp /etc/apt/apt.conf.d/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades.backup
    echo 'APT::Periodic::Update-Package-Lists "1";' | tee -a /etc/apt/apt.conf.d/20auto-upgrades
    echo 'APT::Periodic::Unattended-Upgrade "1";' | tee -a /etc/apt/apt.conf.d/20auto-upgrades

    # Test the configuration
    log_debug "Testing the automatic update configuration..."
    unattended-upgrades --dry-run --debug

    log_info "Configuration complete."
}

# Run the task to disable root account
task_sheduler_auto_update_upgrade