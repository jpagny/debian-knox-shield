#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

# Function to install and configure Fail2Ban
install_and_configure_fail2ban() {
    local prereq_install="Installing Fail2Ban"
    local name_install="Install Fail2Ban"
    local actions_install="sudo apt-get install -y fail2ban"
    local configs_install=":"

    # Install Fail2Ban
    execute_task "$prereq_install" "$name_install" "$actions_install" "$configs_install"

    local prereq_config="Configuring Fail2Ban"
    local name_config="Configure Fail2Ban"
    local jail_local="/etc/fail2ban/jail.local"
    local actions_config="echo '[DEFAULT]' | sudo tee $jail_local"
    actions_config+=" && echo 'bantime = 10m' | sudo tee -a $jail_local"  # Example configuration
    actions_config+=" && echo 'findtime = 10m' | sudo tee -a $jail_local"
    actions_config+=" && echo 'maxretry = 5' | sudo tee -a $jail_local"
    local configs_config="sudo systemctl restart fail2ban"

    # Configure Fail2Ban
    execute_task "$prereq_config" "$name_config" "$actions_config" "$configs_config"

    log_info "Fail2Ban has been installed and configured."
}

# Run the function to install and configure Fail2Ban
install_and_configure_fail2ban
