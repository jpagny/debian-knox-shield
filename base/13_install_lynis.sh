#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

# Function to install Lynis
install_lynis() {
    local prereq="Installing Lynis"
    local name="Install Lynis"
    local actions="sudo apt-get update && sudo apt-get install -y lynis"
    local configs=":"

    # Install Lynis
    execute_task "$prereq" "$name" "$actions" "$configs"

    log_info "Lynis has been installed successfully."
}

# Run the function to install Lynis
install_lynis