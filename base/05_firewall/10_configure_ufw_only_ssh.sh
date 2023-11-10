#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

# Function to configure UFW
configure_ufw() {
    local ssh_port_file="/etc/ssh/ssh_port_info.txt"
    local ssh_port

    # Check if a custom SSH port has been set, otherwise use the default port 22
    if [[ -f "$ssh_port_file" ]]; then
        ssh_port=$(cat "$ssh_port_file" | grep -oP '(?<=SSH is now listening on port: )\d+')
    else
        ssh_port=22  # Default SSH port
    fi

    local prereq="Configuring UFW"
    local name="Configure UFW"
    local actions="sudo ufw allow $ssh_port/tcp && sudo ufw --force enable"
    local configs=":"

    execute_task "$prereq" "$name" "$actions" "$configs"
    log_info "UFW has been configured to allow only SSH port $ssh_port."
}

# Run the function to configure UFW
configure_ufw