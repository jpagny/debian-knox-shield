#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

###
# Disable Uncommon Input Drivers Task
#
# Function..........: task_disable_uncommon_input_drivers
# Description.......: Orchestrates the process of disabling uncommon input drivers on a Linux system. 
#                     This function acts as a wrapper, executing `run_action_disable_uncommon_input_drivers`
#                     to apply specific security measures against less commonly used input drivers.
#                     It ensures that the task is executed with the necessary root privileges, checks prerequisites,
#                     runs the specified action, and handles any required post-action steps. The function also logs
#                     the outcome of the task, indicating success or failure.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If the task successfully disables the uncommon input drivers.
#                     - Non-zero value (NOK): If the task encounters an error or fails to complete successfully.
#
##
task_disable_uncommon_input_drivers() {
  
  local name="disable_uncommon_input_drivers"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task to disable uncommon input drivers ($name) failed."
    return "$NOK"
  fi

  log_info "Task to disable uncommon input drivers ($name) has been completed successfully."
  
  return "$OK"
}

###
# Disable Uncommon Input Drivers
#
# Function..........: run_action_disable_uncommon_input_drivers
# Description.......: Increases system security by disabling a set of uncommon input drivers. 
#                     This is done by writing configurations to `/etc/modprobe.d/uncommon-input.conf`, 
#                     instructing the system to effectively ignore attempts to load these drivers.
#                     This preventive measure targets potential vulnerabilities or attacks via these drivers.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all configurations are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing configuration file before making changes.
#                     - Writes settings to disable a list of uncommon input drivers including joydev, pcspkr, 
#                       serio_raw, snd-rawmidi, snd-seq-midi, snd-seq-oss, snd-seq, snd-seq-device, snd-timer, 
#                       and snd.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
run_action_disable_uncommon_input_drivers() {

    local configFile="/etc/modprobe.d/uncommon-input.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    [ -f "$configFile" ] && cp "$configFile" "$backupFile"

    # Prepare the settings
    local settings
    settings="install joydev /bin/true\n"
    settings+="install pcspkr /bin/true\n"
    settings+="install serio_raw /bin/true\n"
    settings+="install snd-rawmidi /bin/true\n"
    settings+="install snd-seq-midi /bin/true\n"
    settings+="install snd-seq-oss /bin/true\n"
    settings+="install snd-seq /bin/true\n"
    settings+="install snd-seq-device /bin/true\n"
    settings+="install snd-timer /bin/true\n"
    settings+="install snd /bin/true\n"

    # Apply the settings
    echo -e "$settings" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to disable uncommon input drivers."
        # Optionally restore from backup
        [ -f "$backupFile" ] && mv "$backupFile" "$configFile"
        return 1  # NOK
    else
        log_info "Uncommon input drivers have been successfully disabled."
        return 0  # OK
    fi
}

# Run the task to disable uncommon input drivers
task_disable_uncommon_input_drivers
