#!/bin/bash

# import
source "$(dirname "$0")/../core/execute_task.sh"
source "$(dirname "$0")/../core/logger.sh"

### Add User with Sudo Privileges
#
# Function..........: add_user_with_sudo_privileges
# Description.......: Creates a new user and grants them sudo privileges.
# Parameters........: 
#              - $1: Username for the new user.
# Returns...........: 
#              - 0: If the user is successfully created and granted sudo privileges.
#              - Non-zero: If there is an error during the user creation or privilege assignment.
# Output............: Logs the progress and results of the user creation process.
#
###
task_add_user_with_sudo_privileges() {  
  # Ask for username approval and capture the returned username
  local username=$(ask_for_username_approval)
  
  # Set your own password
  read -sp "Enter a new password for the user: " password
  echo # Move to a new line

  # Add the user to the system with the generated username and the provided password
  local name="Add User"
  local isRootRequired=true
  local prereq="check_prerequisites_add_user_with_sudo_privileges"
  local actions="sudo adduser --gecos '' --disabled-password \"$username\""
  local configs="echo '$username:$password' | chpasswd; usermod -aG sudo \"$username\""

  execute_task "$prereq" "$name" "$actions" "$configs"

  if ! execute_task "$name" $isRootRequired "$prereq" "$actions" "$configs"; then
    log_error "User creation failed."
    return 1
  fi

  # Save the credentials to a file
  echo "Username: $username" > /tmp/user_credentials.txt
  echo "Password: $password" >> /tmp/user_credentials.txt

  log_info "User $username has been successfully created."
  return 0
}

### Check Prerequisites for Adding User with Sudo Privileges
#
# Function..........: check_prerequisites_add_user_with_sudo_privileges
# Description.......: Checks if the 'jq' tool is available for parsing JSON data.
# Returns...........: 
#              - 0: If 'jq' is installed.
#              - 1: If 'jq' is not found, indicating a prerequisite is missing.
# Output............: Logs the progress and results of the prerequisite check.
#
###
check_prerequisites_add_user_with_sudo_privileges() {

  if ! command -v apt-get install -y jq &> /dev/null; then
    log_error "."
    return 1
  else
    log_info "jq is already installed."
    return 0
  fi

  return 0
}

### Ask for Username Approval
#
# Function..........: ask_for_username_approval
# Description.......: Fetches a random username from an API and asks for user approval.
# Returns...........: The approved username.
# Output............: Logs the progress and results of the username approval process.
#
###
ask_for_username_approval() {

  local userData 
  local username 
  local approval="n"

  while [ "$approval" != "y" ]; do
    userData=$(curl -s https://randomuser.me/api/)
    
    log_debug "Fetched JSON data: $userData"

    username=$(echo "$userData" | jq -r '.results[0].login.username')

    log_debug "Extracted username: $username"

    if [ -z "$username" ]; then
      echo "No username was extracted. There might be an issue with the API or jq parsing."
      continue
    fi

    log_debug "Generated username: $username"

    read -p "Do you like this username : $username ? (y/n): " approval
    
    if [ "$approval" != "y" ]; then
      log_debug "Fetching a new username..."
    fi

  done

  echo "$username"
}

# Run the function to add a new user with sudo
task_add_user_with_sudo_privileges