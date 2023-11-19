#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

###
# Harden Network Settings Task
#
# Function..........: task_harden_network_settings
# Description.......: Coordinates the process of hardening network settings on a Linux system. 
#                     This function serves as a task wrapper, invoking the `run_action_harden_network_settings` 
#                     to apply a range of network security enhancements. It ensures that the task is executed 
#                     with necessary root privileges, checks prerequisites, runs the specified action, 
#                     and handles any required post-action steps. Additionally, the function logs the outcome 
#                     of the task, reporting success or failure.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If the network settings are successfully hardened.
#                     - Non-zero value (NOK): If the task encounters an error or fails to complete successfully.
#
###
task_harden_network_settings() {
  
  local name="harden_network_settings"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task $name failed to complete successfully."
    return "$NOK"
  fi

  log_info "Task $name has been completed successfully and network settings are hardened."
  
  return "$OK"
}

###
# Harden Network Settings
#
# Function..........: run_action_harden_network_settings
# Description.......: This function strengthens network security on a Linux system by applying various 
#                     network-related kernel parameter settings. These settings are aimed at enhancing the 
#                     network stack's resilience against common network attacks and vulnerabilities.
#                     Each setting is written to the `/etc/sysctl.d/50-net-stack.conf` file, either creating 
#                     a new entry or appending to it.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all network settings are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Disables TCP timestamps to prevent timing-based network activity tracking.
#                     - Enables TCP SYN cookies to protect against SYN flood attacks.
#                     - Disables acceptance of source-routed packets on all interfaces to prevent source routing attacks.
#                     - Disables ICMP redirect acceptance to prevent malicious routing information updates.
#                     - Ignores ICMP echo requests sent to broadcast addresses to prevent network broadcast amplification attacks.
#                     - Enables logging of "martian packets" (packets with impossible source addresses).
#                     - Enables reverse path filtering to validate incoming packets.
#                     - Disables sending of ICMP redirects on all interfaces to prevent misuse in network traffic redirection.
#
###
run_action_harden_network_settings() {

    local configFile="/etc/sysctl.d/50-net-stack.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    cp "$configFile" "$backupFile"

    # Prepare the new settings
    local settings
    settings+="net.ipv4.tcp_timestamps=0\n"
    settings+="net.ipv4.tcp_syncookies=1\n"
    settings+="net.ipv4.conf.all.accept_source_route=0\n"
    settings+="net.ipv4.conf.all.accept_redirects=0\n"
    settings+="net.ipv4.icmp_echo_ignore_broadcasts=1\n"
    settings+="net.ipv4.conf.all.log_martians=1\n"
    settings+="net.ipv4.conf.all.rp_filter=1\n"
    settings+="net.ipv4.conf.all.send_redirects=0\n"
    settings+="net.ipv4.conf.default.accept_source_route=0\n"
    settings+="net.ipv4.conf.default.log_martians=1\n"

    # Apply the settings
    echo -e "$settings" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to apply network settings."
        mv "$backupFile" "$configFile"
        return "$NOK"
    else
        log_info "Network settings have been successfully applied."
        return "$OK"
    fi
}

# Run the task to harden kernel settings
task_harden_network_settings