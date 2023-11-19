#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

###
# Disable Uncommon Sound Drivers Task
#
# Function..........: task_disable_uncommon_sound_drivers
# Description.......: Orchestrates the process of disabling uncommon sound drivers on a Linux system. 
#                     This function serves as a wrapper, calling `run_action_disable_uncommon_sound_drivers`
#                     to apply specific security measures against less commonly used sound drivers.
#                     It checks for necessary prerequisites, executes the action, and handles any 
#                     post-action steps. The function also logs the outcome of the task.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If the task successfully disables the uncommon sound drivers.
#                     - Non-zero value (NOK): If the task encounters an error or fails to complete successfully.
#
##
task_disable_uncommon_sound_drivers() {
  
  local name="disable_uncommon_sound_drivers"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task to disable uncommon sound drivers ($name) failed."
    return "$NOK"
  fi

  log_info "Task to disable uncommon sound drivers ($name) has been completed successfully."
  
  return "$OK"
}

###
# Disable Uncommon Sound Drivers
#
# Function..........: run_action_disable_uncommon_sound_drivers
# Description.......: Increases system security by disabling a set of uncommon sound drivers. 
#                     This is done by writing configurations to `/etc/modprobe.d/uncommon-sound.conf`, 
#                     instructing the system to effectively ignore attempts to load these drivers.
#                     It's a preventive measure against potential vulnerabilities or attacks via these drivers.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all configurations are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing configuration file before making changes.
#                     - Writes settings to disable a list of uncommon sound drivers including snd-usb-audio, 
#                       snd-usb-caiaq, snd-usb-us122l, and snd-usb-usx2y.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
run_action_disable_uncommon_sound_drivers() {

    local configFile="/etc/modprobe.d/uncommon-sound.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    [ -f "$configFile" ] && cp "$configFile" "$backupFile"

    # Prepare the settings
    local settings

    settings="install snd-usb-audio /bin/true\n"
    settings+="install snd-usb-caiaq /bin/true\n"
    settings+="install snd-usb-us122l /bin/true\n"
    settings+="install snd-usb-usx2y /bin/true\n"

    # Apply the settings
    echo -e "$settings" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to disable uncommon sound drivers."
        # Optionally restore from backup
        [ -f "$backupFile" ] && mv "$backupFile" "$configFile"
        return 1  # NOK
    else
        log_info "Uncommon sound drivers have been successfully disabled."
        return 0  # OK
    fi
}

# Run the task to disable uncommon sound drivers
task_disable_uncommon_sound_drivers