#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"


task_disable_uncommon_network_interfaces() {
  
  local name="disable_uncommon_network_interfaces"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task to disable uncommon network interfaces ($name) failed."
    return "$NOK"
  fi

  log_info "Task to disable uncommon network interfaces ($name) has been completed successfully."
  
  return "$OK"
}

###
# Disable Uncommon Network interfaces
#
# Function..........: run_action_disable_uncommon_network_interfaces
# Description.......: Disables specific, less commonly used network interfaces for enhanced system security. 
#                     Currently, this function is configured to disable the Bluetooth interfaces by writing 
#                     configurations to `/etc/modprobe.d/bluetooth.conf`. It prevents the automatic loading 
#                     of the Bluetooth module.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If the configuration to disable Bluetooth is successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing Bluetooth configuration file before making changes.
#                     - Writes the setting to disable the Bluetooth interfaces.
#                     - Performs error checking after applying the setting and logs any failures.
#
##
run_action_disable_uncommon_network_interfaces() {

    local configFile="/etc/modprobe.d/bluetooth.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    [ -f "$configFile" ] && cp "$configFile" "$backupFile"

    # Prepare the setting to disable Bluetooth
    local setting="install bluetooth /bin/true"

    # Apply the setting
    echo "$setting" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to disable Bluetooth interfaces."
        # Optionally restore from backup
        [ -f "$backupFile" ] && mv "$backupFile" "$configFile"
        return $NOK
    else
        log_info "Bluetooth interfaces has been successfully disabled."
        return $OK
    fi
}

# Run the task to disable uncommon network interfaces
task_disable_uncommon_network_interfaces