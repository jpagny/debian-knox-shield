#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

# Function to install UFW if it's not already installed
install_ufw() {
    local prereq="Checking for UFW installation"
    local name="Install UFW"
    local actions="sudo apt-get install -y ufw"
    local configs=":"

    # Check if UFW is installed
    if ! command -v ufw &> /dev/null; then
        execute_task "$prereq" "$name" "$actions" "$configs"
        log_info "UFW installed successfully."
    else
        log_info "UFW is already installed."
    fi
}

# Run the function to install UFW
install_ufw
