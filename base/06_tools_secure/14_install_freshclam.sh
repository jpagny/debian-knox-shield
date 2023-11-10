#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

# Function to install ClamAV
install_clamav() {
    local prereq="Installing ClamAV"
    local name="Install ClamAV"
    local actions="sudo apt-get update && sudo apt-get install -y clamav clamav-daemon"
    local configs="sudo freshclam"

    # Install ClamAV and update virus database
    execute_task "$prereq" "$name" "$actions" "$configs"

    log_info "ClamAV has been installed and virus database updated."
}

# Run the function to install ClamAV
install_clamav