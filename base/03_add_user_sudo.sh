#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

# Function to install jq if it's not already present
install_jq() {
  local prereq="Checking for jq installation"
  local name="Install jq"
  local actions="sudo apt-get install -y jq"
  
  # Check if jq is installed
  if ! command -v jq &> /dev/null; then
    execute_task "$prereq" "$name" "$actions" ":"
  else
    log_info "jq is already installed."
  fi
}

# Function to ask for username approval
ask_for_username_approval() {
  local user_data username approval="n"

  while [ "$approval" != "y" ]; do
    user_data=$(curl -s https://randomuser.me/api/)
    username=$(echo $user_data | jq -r '.results[0].login.username')

    echo "Generated username: $username"
    read -p "Do you like this username? (y/n): " approval

    if [ "$approval" != "y" ]; then
      log_info "Fetching a new username..."
    fi
  done

  echo $username
}

# Function to generate a new user with sudo privileges
add_user_with_sudo() {
  # Install jq as a prerequisite
  install_jq

  # Ask for username approval
  local username=$(ask_for_username_approval)
  
  # Set your own password
  read -sp "Enter a new password for the user: " password
  echo # Move to a new line

  # Add the user to the system with the generated username and the provided password
  local prereq="Preparing to add new user with sudo privileges"
  local name="Add User"
  local actions="sudo adduser --gecos '' --disabled-password $username"
  local configs="echo '$username:$password' | sudo chpasswd; sudo usermod -aG sudo $username"

  execute_task "$prereq" "$name" "$actions" "$configs"

  # Save the credentials to a file
  echo "Username: $username" > /tmp/user_credentials.txt
  echo "Password: $password" >> /tmp/user_credentials.txt
}

# Run the function to add a new user with sudo
add_user_with_sudo