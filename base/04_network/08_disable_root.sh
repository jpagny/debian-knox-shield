#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

# Function to disable root account
disable_root_account() {
    local prereq="Disabling root account"
    local name="Disable Root"
    local random_password=$(openssl rand -base64 48) # Generate a complex password
    local actions="echo 'root:$random_password' | sudo chpasswd"
    local configs=":"

    execute_task "$prereq" "$name" "$actions" "$configs"

    log_info "Root account has been disabled."
}

# Run the function to disable root account
disable_root_account