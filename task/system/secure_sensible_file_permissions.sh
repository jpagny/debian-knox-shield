#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Secure and Sensible File Permissions
#
# Function..........: task_secure_sensible_file_permissions
# Description.......: Ensures that file permissions across the system are set in a secure and sensible manner. 
#                     This task involves checking prerequisites, executing the main action to adjust file permissions, 
#                     and handling any necessary post-action steps. It aims to balance security needs with functional requirements.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If the file permissions are successfully secured and sensibly set.
#               - 1 (NOK): If the process fails to complete successfully.
#
###
task_secure_sensible_file_permissions() {
  
  local name="secure_sensible_file_permissions"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Securing and setting sensible file permissions failed."
    return "$NOK"
  fi

  log_info "File permissions have been securely and sensibly configured."
  
  return "$OK"
}

### Set Secure File Permissions
#
# Function..........: run_action_xxxx
# Description.......: Applies a series of ownership and permission changes to critical system files and directories. 
#                     These changes are intended to enhance system security by restricting write and execute access 
#                     to essential system configuration files and directories.
#                     The function modifies permissions for GRUB configuration, user home directories, system critical files 
#                     like /etc/passwd, /etc/group, cron directories, sudoers configuration, SSH configuration, and more.
# Returns...........: 
#               - 0 (OK): If all changes are successfully applied.
#               - 1 (NOK): If any of the changes fail to apply.
#
###
run_action_secure_sensible_file_permissions() {

  chown root:root /etc/grub.conf >/dev/null 2>&1
  chown -R root:root /etc/grub.d >/dev/null 2>&1
  chown root:root /boot/grub2/grub.cfg >/dev/null 2>&1

  chmod og-rwx /etc/grub.conf >/dev/null 2>&1
  chmod og-rwx /etc/grub.conf >/dev/null 2>&1
  chmod -R og-rwx /etc/grub.d >/dev/null 2>&1
  chmod og-rwx /boot/grub2/grub.cfg >/dev/null 2>&1
  chmod og-rwx /boot/grub/grub.cfg >/dev/null 2>&1
  chmod 0700 /home/* >/dev/null 2>&1
  chmod 0644 /etc/passwd
  chmod 0644 /etc/group
  chmod -R 0600 /etc/cron.hourly
  chmod -R 0600 /etc/cron.daily
  chmod -R 0600 /etc/cron.weekly
  chmod -R 0600 /etc/cron.monthly
  chmod -R 0600 /etc/cron.d
  chmod -R 0600 /etc/crontab
  chmod -R 0600 /etc/shadow
  chmod 750 /etc/sudoers.d
  chmod -R 0440 /etc/sudoers.d/*
  chmod 0600 /etc/ssh/sshd_config
  chmod 0750 /usr/bin/w
  chmod 0750 /usr/bin/who
  chmod 0700 /etc/sysctl.conf
  chmod 644 /etc/motd
  chmod 0600 /boot/System.map-* >/dev/null 2>&1

  return "$OK"
}

# Run the task to xxxx
task_secure_sensible_file_permissions