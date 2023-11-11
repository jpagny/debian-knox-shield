#!/bin/bash


### Execute Task Function
#
# Function..........: execute_task
# Description.......: Executes a task with optional prerequisites and post actions. Validates each step and handles errors.
# Parameters........: 
#              - $1: Name of the task.
#              - $2: Boolean indicating if root privileges are required.
#              - $3: Command string for prerequisites.
#              - $4: Command string for the main actions.
#              - $5: Command string for post actions.
# Returns...........: 
#              - 0: If all steps are successfully executed.
#              - 1: If any step fails.
# Output............: Logs the progress and results of each step.
#
###
execute_task() {

  local name="$1"
  local require_root="$2"
  local prereq="$3"
  local actions="$4"
  local postActions="$5"

  log_info "### Name: $name"

  # 01 - Check for root privileges if required
  if [[ "$require_root" == "true" ]]; then
    if ! verify_has_root_privileges; then
      log_error "Root privileges required for $name."
      return 1
    fi
  fi

  # 02 - Execute the prerequisite if provided
  if [ -n "$prereq" ]; then

    log_prerequisite "Executing prerequisites for $name..."
    
    if eval "$prereq"; then
      log_info "Prerequisites completed"
    else
      log_error "Prerequisites failed"
      return 1  # Stop the procedure if the prerequisite fails
    fi  

  fi

  # 03 - Execute the actions
  log_action "Executing actions for $name..."

  if eval "$actions"; then
    log_info "Actions completed"
  else
    log_error "Actions failed"
    return 1  # Optionally stop also if actions fail
  fi

  # 04 - Execute the post action
  if [ -n "$postActions" ]; then  # Check if 'postActions' variable is not empty

      log_post_actions "Executing post actions for $name..."

      if ! eval "$postActions"; then
          log_error "Post actions failed"
          return 1  # Stop the script if post actions fails
      else
          log_info "Post actions completed successfully"
      fi

  fi

  log_info "Task $name execution completed successfully"
}



# Define log level colors
LOG_COLOR_DEBUG='\033[0;36m' # Cyan for debug
LOG_COLOR_INFO='\033[0;32m'  # Green for info
LOG_COLOR_WARN='\033[0;33m'  # Yellow for warning
LOG_COLOR_ERROR='\033[0;31m' # Red for error

LOG_COLOR_TASK='\033[0;35m'       # Purple for task
LOG_COLOR_PREREQUISITE='\033[1;35m' # Pink for prerequisite
LOG_COLOR_ACTION='\033[0;95m'     # Light pink for action
LOG_COLOR_CONFIG='\033[0;95m'     # Light pink for config

LOG_COLOR_END='\033[0m'      # End color

### Debug log
#
# Function..........: log_debug
# Description.......: Logs a debug message with cyan color.
# Parameters........: 
#               - $1: Message to log.
#
###
log_debug() {
  echo -e "${LOG_COLOR_DEBUG}[DEBUG]: $1${LOG_COLOR_END}" >&2
}

### Information log
#
# Function..........: log_info
# Description.......: Logs an informational message with green color.
# Parameters........: 
#              - $1: Message to log.
#
###
log_info() {
  echo -e "${LOG_COLOR_INFO}[INFO]: $1${LOG_COLOR_END}" >&2
}

### Warning log
#
# Function..........: log_warn
# Description.......: Logs a warning message with yellow color.
# Parameters........: 
#              - $1: Message to log.
#
###
log_warn() {
  echo -e "${LOG_COLOR_WARN}[WARN]: $1${LOG_COLOR_END}" >&2
}

### Error log
#
# Function..........: log_error
# Description.......: Logs an error message with red color.
# Parameters........: 
#              - $1: Message to log.
#
###
log_error() {
  echo -e "${LOG_COLOR_ERROR}[ERROR]: $1${LOG_COLOR_END}" >&2
}

### Task log
#
# Function..........: log_task
# Description.......: Logs a task message with purple color.
# Parameters........: 
#              - $1: Message to log.
#
###
log_task() {
  echo -e "${LOG_COLOR_TASK}[TASK]: $1${LOG_COLOR_END}" >&2
}

### Prerequisite log
#
# Function..........: log_prerequisite
# Description.......: Logs a prerequisite message with pink color.
# Parameters........: 
#              - $1: Message to log.
#
###
log_prerequisite() {
  echo -e "${LOG_COLOR_PREREQUISITE}[PREREQUISITE]: $1${LOG_COLOR_END}" >&2
}

### Action log
#
# Function..........: log_action
# Description.......: Logs an action message with light pink color.
# Parameters........: 
#              - $1: Message to log.
#
###
log_action() {
  echo -e "${LOG_COLOR_ACTION}[ACTION]: $1${LOG_COLOR_END}" >&2
}

### Config log function
#
# Function..........: log_log_post_actionsconfiguration
# Description.......: Logs a post actions message with light pink color.
# Parameters........: 
#              - $1: Message to log.
#
###
log_post_actions() {
  echo -e "${LOG_COLOR_CONFIG}[POST ACTIONS]: $1${LOG_COLOR_END}" >&2
}




### Verify has root privlieges
#
# Function..........: update_and_upgrade
# Description:......: Checks whether the script is executed with root privileges. 
# Returns:..........: 
#                     - 0 (Success): If the current user has root privileges (user ID is 0).
#                     - 1 (Failure): If the current user does not have root privileges.
# Output............: Logs an error message to the standard error output if the current user is not root.
#
### 
verify_has_root_privileges() {
    if [[ $(id -u) -ne 0 ]]; then
        log_error "This script must be run with root privileges."
        return 1
    fi

    return 0
}

### Install Package
#
# Function..........: install_package
# Description.......: Installs a given package using the APT package manager. 
#                     This function is intended for use on Debian-based systems.
#                     It checks if the specified package is already installed and, if not, 
#                     attempts to install it.
# Parameters........: 
#   - package: The name of the package to install.
# Returns...........: 
#   - 0: If the package is already installed or has been successfully installed.
#   - 1: If the installation of the package fails.
# Output............: Logs information about the installation process and any errors encountered.
# Note..............: This function uses 'apt-get' for package management and requires 
#                     administrative privileges to install packages. Ensure that the user 
#                     running this script has the necessary permissions.
#
###
install_package(){
    
  package=$1

  if ! command -v $package &> /dev/null; then
    log_info "$package is not installed. Installing..."

    if apt-get update &> /dev/null && apt-get install -y $package &> /dev/null; then
      log_info "$package has been installed successfully."
      return 0
    else
      log_error "Failed to install $package."
      return 1
    fi
  else
    log_info "$package is already installed."
    return 0
  fi
}



### Task - system update && upgrade
#
# Function..........: update_and_upgrade
# Description:......: Updates and upgrades the system using apt-get. 
#                     This function executes the system update and upgrade process.
# Requires Root:....: Yes
# Returns:..........: Returns 1 on failure, otherwise void.
#
###
task_update_and_upgrade() {

    local name="System update && upgrade"
    local isRootRequired=true
    local prereq=""
    local actions="apt-get update && apt-get upgrade -y &> /dev/null" 
    local postActions=""

    if ! execute_task "$name" $isRootRequired "$prereq" "$actions" "$postActions"; then
        log_error "System upgrade failed."
        return 1
    fi

    log_info "System update and upgrade completed successfully."
    return 0
}

# Run the update and upgrade function
task_update_and_upgrade



### Task - install Sudo
#
# Function..........: task_install_sudo
# Description.......: Installs the sudo package if it is not already installed.
# Parameters........: None
# Returns...........: 
#              - 0: If sudo is successfully installed or already present.
#              - Non-zero: If the installation fails or if sudo is not installed and cannot be installed.
# Output............: Logs the progress and results of the installation.
#
###
task_install_sudo() {

  local name="Install sudo"
  local isRootRequired=true
  local prereq="check_prerequisites_install_sudo"
  local actions="run_action_install_sudo"
  local postActions=""
  
  if ! execute_task "$name" $isRootRequired "$prereq" "$actions" "$postActions"; then
    log_error "Installation of sudo failed."
    return 1
  fi

  log_info "Sudo has been successfully installed."
  return 0
}

### Check Prerequisites install sudo
#
# Function..........: check_prerequisites_install_sudo
# Description.......: Checks if the APT package manager is available.
#                     Intended for use in Debian-based systems.
# Returns...........: 
#              - 0: If APT is available.
#              - 1: If APT is not available.
# Output............: Logs a message indicating either the absence of APT or the presence of sudo.
#
###
check_prerequisites_install_sudo() {

  # Check if APT is available
  if ! command -v apt-get &> /dev/null; then
    log_error "APT package manager not found. This script is intended for Debian-based systems."
    return 1
  fi

  return 0
}

### Run action - Install Sudo
#
# Function..........: run_action_install_sudo
# Description.......: Installs the 'sudo' package if it's not already installed.
#                     This function is intended for use in Debian-based systems
#                     where 'sudo' might not be pre-installed.
# Returns...........: 
#              - 0: If the installation of 'sudo' was successful or if 'sudo' is already installed.
#              - 1: If the installation of 'sudo' failed.
# Output............: Logs a message indicating the success or failure of the installation.
#
###
run_action_install_sudo(){

  # install sudo package
  if ! install_package "sudo"; then
    return 1
  fi

  return 0
}

# Run the install sudo function
task_install_sudo



local username

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

  if ! execute_task "$name" $isRootRequired "$prereq" "$actions" "$postActions"; then
    log_error "User creation failed."
    return 1
  fi

  log_info "User $username has been successfully created."
  
  unset username

  return 0
}

### Run action - add user with sudo privileges
#
# Function..........: run_action_add_user_with_sudo_privileges
# Description.......: This function creates a new user account on a Debian-based system 
#                     and adds it to the 'sudo' group, granting administrative privileges. 
#                     It prompts the user for a username and password, encrypts the password, 
#                     and then creates the account with the encrypted password.
# Parameters........: None. Username and password are provided interactively.
# Output............: User and password creation messages and any errors encountered 
#                     during the process.
# Note..............: This function depends on the 'perl' package for password encryption.
#                     Ensure 'perl' is installed or modify the function to use a different 
#                     method for password encryption.
#
###
run_action_add_user_with_sudo_privileges() {
  # Ask for username approval and capture the returned username
  username=$(ask_for_username_approval)

  # Set your own password
  read -sp "Enter a new password for the user: " password
  echo # Move to a new line

  # Encrypt the password
  local encrypted_password=$(perl -e 'print crypt($ARGV[0], "password")' "$password")

  # Use the useradd command to create the user with the encrypted password
  sudo useradd -m -p "$encrypted_password" "$username"

  # Add the user to the sudo group
  sudo usermod -aG sudo "$username"
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
  if ! install_package "jq"; then
    return 1
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

