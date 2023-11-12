#!/bin/bash

# import
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task add user with sudo privileges
#
# Function..........: add_user_with_sudo_privileges
# Description.......: Creates a new user and grants them sudo privileges.
# Returns...........: 
#              - 0: If the user is successfully created and granted sudo privileges.
#              - Non-zero: If there is an error during the user creation or privilege assignment.
# Output............: Logs the progress and results of the user creation process.
#
###
task_add_user_with_sudo_privileges() {  

  # Add the user to the system with the generated username and the provided password
  local name="Add User"
  local isRootRequired=true
  local prereq="check_prerequisites_add_user_with_sudo_privileges"
  local actions="run_action_add_user_with_sudo_privileges"
  local postActions=""
  local task_type=""


  if ! execute_and_check "$name" "$task_type" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "User creation failed."
    return $NOK
  fi

  log_info "User $username has been successfully created."
  
  unset username

  return $OK
}

### Run action - add user with sudo privileges
#
# Function..........: run_action_add_user_with_sudo_privileges
# Description.......: This function creates a new user account on a Debian-based system 
#                     and adds it to the 'sudo' group, granting administrative privileges. 
#                     It prompts the user for a username and password, and then creates the account.
# Parameters........: None. Username and password are provided interactively.
# Output............: User and password creation messages and any errors encountered 
#                     during the process.
#
###
run_action_add_user_with_sudo_privileges() {
  # Ask for username approval and capture the returned username
  username=$(ask_for_username_approval)

  # Use the useradd command to create the user with the encrypted password
  adduser --gecos "" "$username" 

  # Add the user to the sudo group
  usermod -aG sudo "$username"
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

  # install jq package
  if ! install_package "sudo"; then
    return $NOK
  fi

  # install jq package
  if ! install_package "jq"; then
    return $NOK
  fi

  return $OK
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