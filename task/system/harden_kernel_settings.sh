#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

###
# Harden Kernel Settings Task
#
# Function..........: task_harden_kernel_settings
# Description.......: Orchestrates the process of hardening the Linux kernel settings. 
#                     This function is a task wrapper that calls the `run_action_harden_kernel_settings` action. 
#                     It checks for necessary prerequisites, executes the action to harden kernel settings, 
#                     and handles any post-action steps. The function ensures that it is executed with 
#                     the necessary root privileges and logs the outcome of the operation.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If the kernel settings are successfully hardened.
#                     - Non-zero value (NOK): If the process encounters an error or fails to complete successfully.
#
###
task_harden_kernel_settings() {
  
  local name="harden_kernel_settings"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task $name failed to complete successfully."
    return "$NOK"
  fi

  log_info "Task $name has been completed successfully and kernel settings are hardened."
  
  return "$OK"
}

###
# Harden Kernel Settings
#
# Function..........: run_action_harden_kernel_settings
# Description.......: Enhances system security by applying a series of kernel parameter settings aimed at 
#                     hardening the Linux kernel. The function writes each setting to a separate configuration 
#                     file in the `/etc/sysctl.d/` directory. It includes steps for backing up existing 
#                     configurations and implements error checking to ensure each setting is applied correctly.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all kernel settings are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up existing configuration files in `/etc/sysctl.d/` to a designated backup directory.
#                     - Applies a range of security-enhancing settings to the kernel, each written to its own file.
#                     - Includes settings for message restrictions, core dump control, memory randomization, 
#                       and various other security measures.
#                     - Performs error checking after each setting application and logs any failures.
#
###
run_action_harden_kernel_settings() {

    local sysctlDir="/etc/sysctl.d"
    local backupDir="${sysctlDir}/backup"

    # Create backup directory
    mkdir -p "$backupDir"
    
    # Backup current configurations
    find "$sysctlDir" -name '50-*.conf' -exec cp {} "$backupDir/" \;

    # New kernel settings
    local kernelSettings

    kernelSettings+="kernel.dmesg_restrict=1\n"
    kernelSettings+="fs.suid_dumpable=0\n"
    kernelSettings+="kernel.exec-shield=2\n"
    kernelSettings+="kernel.randomize_va_space=2\n"
    kernelSettings+="dev.tty.ldisc_autoload=0\n"
    kernelSettings+="fs.protected_fifos=2\n"
    kernelSettings+="kernel.core_uses_pid=1\n"
    kernelSettings+="kernel.kptr_restrict=2\n"
    kernelSettings+="kernel.sysrq=0\n"
    kernelSettings+="kernel.unprivileged_bpf_disabled=1\n"
    kernelSettings+="kernel.yama.ptrace_scope=1\n"
    kernelSettings+="net.core.bpf_jit_harden=2\n"

    # Apply the settings
    local configFileName

    for setting in $kernelSettings; do

        configFileName=$(echo $setting | awk -F= '{print $1}' | tr '.' '-' | tr '_' '-')
        echo "$setting" > "${sysctlDir}/50-${configFileName}.conf" 2>/dev/null

        if [ $? -ne 0 ]; then
            log_error "Failed to apply setting: $setting"
            cp -r "${backupDir}/." "${sysctlDir}/"
            return "$NOK"
        fi
    done

    log_info "Kernel settings have been successfully hardened."
    return "$OK"
}

# Run the task to harden kernel settings
task_harden_kernel_settings