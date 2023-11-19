#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

###
# Harden File System Settings Task
#
# Function..........: task_harden_file_system_settings
# Description.......: Coordinates the process of hardening the file system settings on a Linux system. 
#                     This function serves as a task wrapper, invoking the `run_action_harden_file_system_settings` 
#                     to apply specific security enhancements to file system settings. It ensures that the task 
#                     is executed with necessary root privileges, checks prerequisites, runs the specified action, 
#                     and handles any required post-action steps. Additionally, the function logs the outcome 
#                     of the task, reporting success or failure.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If the file system settings are successfully hardened.
#                     - Non-zero value (NOK): If the task encounters an error or fails to complete successfully.
#
##
task_harden_file_system_settings() {
  
  local name="harden_file_system_settings"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task $name failed to complete successfully."
    return "$NOK"
  fi

  log_info "Task $name has been completed successfully and file_system settings are hardened."
  
  return "$OK"
}

###
# Harden File System Settings
#
# Function..........: run_action_harden_file_system_settings
# Description.......: Enhances the security of the file system on a Linux system by applying specific 
#                     kernel parameter settings. These settings increase the security around hardlinks and symlinks, 
#                     reducing the risk of certain types of exploits. The function writes these settings to a 
#                     dedicated configuration file in `/etc/sysctl.d/`.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all file system settings are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the current configuration file before making changes.
#                     - Applies settings to enhance the security of hardlinks and symlinks.
#                     - Writes the settings to `/etc/sysctl.d/50-fs-hardening.conf`.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
run_action_harden_file_system_settings() {

    local configFile="/etc/sysctl.d/50-fs-hardening.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    [ -f "$configFile" ] && cp "$configFile" "$backupFile"

    # Prepare the new settings
    local settings
    settings="fs.protected_hardlinks=1\n"
    settings+="fs.protected_symlinks=1\n"

    # Apply the settings
    echo -e "$settings" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to apply file system settings."
        [ -f "$backupFile" ] && mv "$backupFile" "$configFile"
        return 1  # or any non-zero value for NOK
    else
        log_info "File system settings have been successfully hardened."
        return 0  # or use a predefined constant for OK
    fi
}

# Run the task to harden kernel settings
task_harden_file_system_settings