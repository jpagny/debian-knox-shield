#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task for Installing and Configuring Knockd
#
# Function..........: task_add_knockd
# Description.......: Performs the task of installing and configuring Knockd on the system. Knockd is a port knocking
#                     daemon that allows secure access to network services by triggering predefined sequences of
#                     connection attempts (knocks). This task involves checking prerequisites, running the installation
#                     and configuration actions, and performing any necessary post-actions.
# Returns:
#   - 0 (OK): If Knockd is successfully installed and configured.
#   - 1 (NOK): If the process fails at any point during the task.
#
##
task_add_knockd() {
  
  local name="add_knockd"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "xxxx failed."
    return "$NOK"
  fi

  log_info "xxxx has been successfully xxxxx."
  
  return "$OK"
}

### Check Prerequisites for Knockd Installation
#
# Function..........: check_prerequisites_add_knockd
# Description.......: Ensures that the 'knockd' package is installed on the system as a prerequisite for configuring
#                     port knocking. This function attempts to install the 'knockd' package if it's not already present.
# Parameters........: None.
# Returns:
#   - 0 (OK): If the 'knockd' package is already installed or is successfully installed during execution.
#   - 1 (NOK): If the 'knockd' package cannot be installed.
#
##
check_prerequisites_add_knockd() {

    # Check if ufw is installed
    if ! command -v ufw >/dev/null 2>&1; then
        echo "ufw must be installed"
        return "$NOK"
    fi

    # Install knockd package
    if ! install_package "knockd"; then
        return "$NOK"
    fi

    # Remove all ufw rules related to SSH
    local ssh_rules=$(ufw status numbered | grep 'SSH' | awk '{print $1}' | sed 's/\[//;s/\]//')
    for rule in $ssh_rules; do
        ufw delete $rule
    done

    return "$OK"
}

### Configure Port Knocking with knockd
#
# Function..........: run_action_add_knockd
# Description.......: Configures port knocking using 'knockd'. This function creates or updates the 'knockd.conf' 
#                     configuration file with the desired settings for port knocking. It also performs validation
#                     of the configuration using 'knockd --check-config'.
# Parameters........: None.
# Returns:
#   - 0 (OK): If the port knocking configuration is successfully written and validated.
#   - 1 (NOK): If there is an error in the configuration or validation fails.
#
##
run_action_add_knockd() {

  local knockd_conf="/etc/knockd.conf"
  local sshd_conf="/etc/ssh/sshd_config"
  local ssh_port=$(grep "^Port " $sshd_conf | cut -d ' ' -f2)

  # Extract the main network interface name
  local interface=$(ip addr | grep 'state UP' | grep -v 'lo' | cut -d ':' -f2 | awk '{print $1}' | head -n 1)

  log_info "Configuring port knocking with knockd on interface $interface."

  # Backup existing configuration if it exists
  if [ -f "$knockd_conf" ]; then
    cp "$knockd_conf" "${knockd_conf}.backup"
  fi

  while [ "$approved" != "y" ]; do
    # Generate random numbers between 1 and 10 for sequences
    local open_ports=$(shuf -i 1-10 -n 1)
    local close_ports=$(shuf -i 1-10 -n 1)

    # Generate the sequences
    local open_sequence=$(generate_knock_sequence $open_ports)
    local close_sequence=$(generate_knock_sequence $close_ports)

    echo "Generated opening sequence: $open_sequence"
    echo "Generated closing sequence: $close_sequence"
    echo "Do you approve these sequences? (y/n)"
    read approved

    if [ "$approved" = "y" ]; then
      log_info "Séquences approuvées. Configuration de knockd en cours..."

      # Backup existing configuration if it exists
      [ -f "$knockd_conf" ] && cp "$knockd_conf" "${knockd_conf}.backup"

      # Writing new configuration
      {
        echo '[options]'
        echo "        interface = $interface"
        echo '        logfile = /var/log/knockd.log'
        echo
        echo '[openSSH]'
        echo "        sequence    = $open_sequence"
        echo '        seq_timeout = 5'
        echo "        command     = /sbin/iptables -A INPUT -s %IP% -p tcp --dport $ssh_port -j ACCEPT"
        echo '        tcpflags    = syn'
        echo
        echo '[closeSSH]'
        echo "        sequence    = $close_sequence"
        echo '        seq_timeout = 5'
        echo "        command     = /sbin/iptables -D INPUT -s %IP% -p tcp --dport $ssh_port -j ACCEPT"
        echo '        tcpflags    = syn'
      } > "$knockd_conf"
    fi

  done

  log_info "Port knocking configuration for knockd completed successfully."

  return "$OK"
}

generate_knock_sequence() {
  local length=$1
  local sequence=""
  local protocols=("tcp" "udp")  # List of protocols

  for i in $(seq 1 $length); do
    # Generate a random port
    local port=$(shuf -i 1024-65535 -n 1)
    # Randomly select a protocol
    local protocol=${protocols[$RANDOM % 2]}
    # Add the port and protocol to the sequence
    sequence+="${port}:${protocol}"
    [ $i -lt $length ] && sequence+=" "
  done

  echo $sequence
}

### Post Actions for Knockd Configuration
#
# Function..........: post_actions_add_knockd
# Description.......: Ensures that the knockd service is correctly installed and configured. It checks if the knockd
#                     service is installed, enables it to start on system boot, and restarts it to apply any new
#                     configurations. This step is crucial for maintaining the operation of knockd across system
#                     reboots and configuration changes.
# Returns...........: 
#               - 0 (OK): If the knockd service is successfully restarted and enabled.
#               - 1 (NOK): If the knockd service is not installed, not active, or fails to restart.
#
##
post_actions_add_knockd() {

  local knockd_conf="/etc/knockd.conf"
  local knockd_service="knockd"

  log_info "Verifying knockd configuration."

  # Reload systemd manager configuration
  systemctl daemon-reload

  # Enable knockd service to start on boot
  if ! systemctl enable $knockd_service; then
    log_error "Failed to enable knockd service."
    return "$NOK"
  fi

  # Restart knockd service to apply any new configurations
  if ! systemctl restart $knockd_service; then
    log_error "Failed to restart knockd service."
    return "$NOK"
  fi

  log_info "knockd service is active and running."
  return "$OK"
}

# Run the task to add knockd
task_add_knockd