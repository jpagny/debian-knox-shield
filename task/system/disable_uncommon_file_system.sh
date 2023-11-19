#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

###
# Disable Uncommon File Systems
#
# Function..........: run_action_disable_uncommon_file_system
# Description.......: Disables a set of uncommon file systems in a Linux environment for security purposes. 
#                     The function writes configurations to the `/etc/modprobe.d/uncommon-fs.conf` file, 
#                     effectively instructing the system to do nothing (use `/bin/true`) when an attempt is 
#                     made to load these file systems. This can help in mitigating the risks associated with 
#                     less commonly used file systems, which might not be as well vetted for vulnerabilities.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all configurations are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing configuration file in `/etc/modprobe.d/` before making changes.
#                     - Writes settings to disable a list of file systems including cramfs, freevxfs, jffs2, 
#                       hfs, hfsplus, squashfs, udf, fat, vfat, and gfs2.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
task_disable_uncommon_file_system() {
  
  local name="disable_uncommon_file_system"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task for disabling uncommon file systems ($name) failed."
    return "$NOK"
  fi

  log_info "Task for disabling uncommon file systems ($name) has been successfully completed."
  
  return "$OK"
}

###
# Disable Uncommon File Systems
#
# Function..........: run_action_disable_uncommon_file_system
# Description.......: Disables a set of uncommon file systems in a Linux environment for security purposes. 
#                     The function writes configurations to the `/etc/modprobe.d/uncommon-fs.conf` file, 
#                     effectively instructing the system to do nothing (use `/bin/true`) when an attempt is 
#                     made to load these file systems. This can help in mitigating the risks associated with 
#                     less commonly used file systems, which might not be as well vetted for vulnerabilities.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all configurations are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing configuration file in `/etc/modprobe.d/` before making changes.
#                     - Writes settings to disable a list of file systems including cramfs, freevxfs, jffs2, 
#                       hfs, hfsplus, squashfs, udf, fat, vfat, and gfs2.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
run_action_disable_uncommon_file_system() {

    local configFile="/etc/modprobe.d/uncommon-fs.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    [ -f "$configFile" ] && cp "$configFile" "$backupFile"

    # Prepare the settings
    local settings
    settings="install cramfs /bin/true\n"
    settings+="install freevxfs /bin/true\n"
    settings+="install jffs2 /bin/true\n"
    settings+="install hfs /bin/true\n"
    settings+="install hfsplus /bin/true\n"
    settings+="install squashfs /bin/true\n"
    settings+="install udf /bin/true\n"
    settings+="install fat /bin/true\n"
    settings+="install vfat /bin/true\n"
    settings+="install gfs2 /bin/true\n"

    # Apply the settings
    echo -e "$settings" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to disable uncommon file systems."
        # Optionally restore from backup
        [ -f "$backupFile" ] && mv "$backupFile" "$configFile"
        return 1  # or any non-zero value for NOK
    else
        log_info "Uncommon file systems have been successfully disabled."
        return 0  # or use a predefined constant for OK
    fi
}

# Run the task to disable uncommon file system
task_disable_uncommon_file_system
