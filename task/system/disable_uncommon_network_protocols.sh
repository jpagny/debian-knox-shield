#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

###
# Disable Uncommon Network Protocols
#
# Function..........: run_action_disable_uncommon_network_protocols
# Description.......: This function increases network security on a Linux system by disabling uncommon 
#                     network protocols. It does this by writing configurations to the 
#                     `/etc/modprobe.d/uncommon-net.conf` file, instructing the system to do nothing 
#                     (`/bin/true`) when an attempt is made to load these protocols. This helps mitigate 
#                     risks associated with less commonly used network protocols, which might be less 
#                     secure or less scrutinized for vulnerabilities.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all configurations are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing configuration file in `/etc/modprobe.d/` before making changes.
#                     - Writes settings to disable a list of network protocols including dccp, sctp, rds, and tipc.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
task_disable_uncommon_network_protocols() {
  
  local name="disable_uncommon_network_protocols"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task to disable uncommon network protocols ($name) failed."
    return "$NOK"
  fi

  log_info "Task to disable uncommon network protocols ($name) has been completed successfully."
  
  return "$OK"
}

###
# Disable Uncommon Network Protocols
#
# Function..........: run_action_disable_uncommon_network_protocols
# Description.......: This function increases network security on a Linux system by disabling uncommon 
#                     network protocols. It does this by writing configurations to the 
#                     `/etc/modprobe.d/uncommon-net.conf` file, instructing the system to do nothing 
#                     (`/bin/true`) when an attempt is made to load these protocols. This helps mitigate 
#                     risks associated with less commonly used network protocols, which might be less 
#                     secure or less scrutinized for vulnerabilities.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all configurations are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing configuration file in `/etc/modprobe.d/` before making changes.
#                     - Writes settings to disable a list of network protocols including dccp, sctp, rds, and tipc.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
run_action_disable_uncommon_network_protocols() {

    local configFile="/etc/modprobe.d/uncommon-net.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    [ -f "$configFile" ] && cp "$configFile" "$backupFile"

    # Prepare the settings
    local settings
    settings="install dccp /bin/true\n"
    settings+="install sctp /bin/true\n"
    settings+="install rds /bin/true\n"
    settings+="install tipc /bin/true\n"

    # Apply the settings
    echo -e "$settings" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to disable uncommon network protocols."
        # Optionally restore from backup
        [ -f "$backupFile" ] && mv "$backupFile" "$configFile"
        return $NOK
    else
        log_info "Uncommon network protocols have been successfully disabled."
        return $OK
    fi
}

# Run the task to disable uncommon network protocols
task_disable_uncommon_network_protocols