#!/bin/bash

# import
# shellcheck source=/dev/null
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
task_add_random_user_password_with_sudo_privileges() {  

  # Add the user to the system with the generated username and the provided password
  local name="add_random_user_password_with_sudo_privileges"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "User creation failed."
    return "$NOK"
  fi

  log_info "User $username has been successfully created."
  
  unset username

  return "$OK"
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
check_prerequisites_add_random_user_password_with_sudo_privileges() {

  # install jq package
  if ! install_package "sudo"; then
    return "$NOK"
  fi

  # install jq package
  if ! install_package "jq"; then
    return "$NOK"
  fi

  # install pwgen package
  if ! install_package "pwgen"; then
    return "$NOK"
  fi

  return "$OK"
}

### Run Action: Add Random User with Sudo Privileges
#
# Function..........: run_action_add_random_user_password_with_sudo_privileges
# Description.......: Creates a new user with a username approved by the user, sets a strong, approved password, and grants sudo privileges.
# Parameters........: None.
# Returns...........: None.
# Output............: Logs the successful addition of a new user with sudo privileges.
##
run_action_add_random_user_password_with_sudo_privileges() {

  local username
  local password
  local confirmation

  # Ask for username approval and capture the returned username
  username=$(ask_for_username_approval)

  # Ask for password approval and capture the returned password
  password=$(ask_for_password_approval)

  while true; do
    
    # Is it safe to show credentials ? 
    echo "Please make sure you have recorded this information safely:"
    echo "Username: $username"
    echo "Password: $password"

    # Ask for confirmation
    read -p "Have you saved the username and password? (y/n): " confirmation
    if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then
      break
    else
      echo "Let's try again..."
    fi

  done

  # Use the useradd command to create the user without a password prompt
  adduser --gecos "" --disabled-password "$username"

  # Set the password for the user securely using chpasswd
  echo "$username:$password" | chpasswd

  # Add the user to the sudo group
  usermod -aG sudo "$username"

  log_info "User $username added with sudo privileges."
}

# Run the task to add a new user with sudo privileges
task_add_random_user_password_with_sudo_privileges
