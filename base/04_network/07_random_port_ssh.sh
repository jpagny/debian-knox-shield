#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

# Function to set a random SSH port
set_random_ssh_port() {
  local prereq="Setting a random SSH port"
  local name="Random SSH Port"
  local random_port=$(shuf -i 1024-65535 -n 1) # Generate a random port between 1024 and 65535
  local actions="sudo sed -i 's/^#Port 22/Port $random_port/' /etc/ssh/sshd_config"
  local configs="sudo service ssh restart"

  execute_task "$prereq" "$name" "$actions" "$configs"

  # Save the new SSH port to a file for reference
  echo "SSH is now listening on port: $random_port" | sudo tee /etc/ssh/ssh_port_info.txt
}

# Run the function to set a random SSH port
set_random_ssh_port
