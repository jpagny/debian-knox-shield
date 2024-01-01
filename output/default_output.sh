#!/bin/bash


#-------------- 00_variable_global.sh

OK=0
NOK=1

DEBUG_MODE=0

#-------------- 01_logger.sh

# Define log level colors
LOG_COLOR_DEBUG='\033[0;36m'        # Cyan for debug
LOG_COLOR_INFO='\033[0;32m'         # Green for info
LOG_COLOR_WARN='\033[0;33m'         # Yellow for warning
LOG_COLOR_ERROR='\033[0;31m'        # Red for error

LOG_COLOR_TASK='\033[1;35m'         # Magenta for task
LOG_COLOR_PREREQUISITE='\033[1;33m' # Yellow for prerequisite
LOG_COLOR_ACTION='\033[1;33m'       # Yellow for action
LOG_COLOR_POST_ACTION='\033[1;33m'  # Yellow for post action

LOG_COLOR_END='\033[0m'             # End color

### Log Debug Message
#
# Function..........: log_debug
# Description.......: Logs a debug message if the DEBUG_MODE is enabled. The message is 
#                     printed in the color specified by LOG_COLOR_DEBUG. The function is 
#                     intended for use in scripts where conditional logging based on a debug 
#                     mode is required.
# Parameters........: 
#               - $1: The debug message to be logged.
# Side Effects......: Outputs a message to standard error (stderr) if DEBUG_MODE is set to 1.
#                     The message is colored based on the LOG_COLOR_DEBUG variable.
#
###
log_debug() {
  if [ "$DEBUG_MODE" -eq 1 ]; then
    echo -e "${LOG_COLOR_DEBUG}     [debug]: $1${LOG_COLOR_END}" >&2
  fi
}

### Log Information Message
#
# Function..........: log_info
# Description.......: Outputs an information message, prefixed with '[info]'. The message 
#                     is displayed in the color specified by LOG_COLOR_INFO. This function 
#                     is used for general informational logging within the script.
# Parameters........: 
#               - $1: The informational message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and an '[info]' prefix.
#
###
log_info() {
  echo -e "${LOG_COLOR_INFO}    [info]: $1${LOG_COLOR_END}" >&2
}

### Log Warning Message
#
# Function..........: log_warn
# Description.......: Outputs a warning message, prefixed with '[warn]'. The message 
#                     is displayed in the color specified by LOG_COLOR_WARN. This function 
#                     is used for logging warnings within the script, indicating potential 
#                     issues or important notices that are not critical errors.
# Parameters........: 
#               - $1: The warning message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and a '[warn]' prefix. The output is intended to draw 
#                     attention to potential issues or important information.
#
###
log_warn() {
  echo -e "${LOG_COLOR_WARN}    [warn]: $1${LOG_COLOR_END}" >&2
}

### Log Error Message
#
# Function..........: log_error
# Description.......: Outputs an error message, prefixed with '[error]'. The message 
#                     is displayed in the color specified by LOG_COLOR_ERROR. This function 
#                     is used for logging error messages within the script, indicating 
#                     issues or problems that need immediate attention or that have caused 
#                     a failure in the script's execution.
# Parameters........: 
#               - $1: The error message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and an '[error]' prefix. The output is intended to 
#                     highlight errors or critical problems in the script.
#
###
log_error() {
  echo -e "${LOG_COLOR_ERROR}     [error]: $1${LOG_COLOR_END}" >&2
}

### Log Task Message
#
# Function..........: log_task
# Description.......: Outputs a task message, prefixed with '[TASK]'. The message is 
#                     displayed in the color specified by LOG_COLOR_TASK. This function is 
#                     used for logging task-related messages within the script, providing a 
#                     clear indication of task executions or updates.
# Parameters........: 
#               - $1: The task message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and a '[TASK]' prefix. The output is intended to 
#                     highlight task-related activities or statuses in the script.
#
###
log_task() {
  echo -e "${LOG_COLOR_TASK}[TASK]: $1${LOG_COLOR_END}" >&2
}

### Log Prerequisite Message
#
# Function..........: log_prerequisite
# Description.......: Outputs a prerequisite message, prefixed with '[PREREQUISITE]'. The message 
#                     is displayed in the color specified by LOG_COLOR_PREREQUISITE. This function 
#                     is used for logging messages related to prerequisites within the script, 
#                     highlighting essential setup steps or requirements.
# Parameters........: 
#               - $1: The prerequisite message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and a '[PREREQUISITE]' prefix. The output is intended to 
#                     emphasize prerequisites or initial setup requirements in the script.
#
###
log_prerequisite() {
  echo -e "${LOG_COLOR_PREREQUISITE}  [PREREQUISITE]: $1${LOG_COLOR_END}" >&2
}

### Log Action Message
#
# Function..........: log_action
# Description.......: Outputs an action message, prefixed with '[ACTION]'. The message 
#                     is displayed in the color specified by LOG_COLOR_ACTION. This function 
#                     is used for logging messages related to specific actions taken or 
#                     to be taken within the script, aiding in tracking the script's operations.
# Parameters........: 
#               - $1: The action message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and an '[ACTION]' prefix. The output is intended to 
#                     highlight significant actions or steps in the script's execution.
#
###
log_action() {
  echo -e "${LOG_COLOR_ACTION}  [ACTION]: $1${LOG_COLOR_END}" >&2
}

### Log Post Action Message
#
# Function..........: log_post_actions
# Description.......: Outputs a post-action message, prefixed with '[POST ACTIONS]'. The message 
#                     is displayed in the color specified by LOG_COLOR_POST_ACTION. This function 
#                     is used for logging messages related to actions taken after the main 
#                     processing of the script, such as cleanup steps, summaries, or final status 
#                     updates.
# Parameters........: 
#               - $1: The post-action message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and a '[POST ACTIONS]' prefix. The output is intended to 
#                     highlight actions or steps taken after the main execution of the script.
#
###
log_post_actions() {
  echo -e "${LOG_COLOR_POST_ACTION}  [POST ACTIONS]: $1${LOG_COLOR_END}" >&2
}


#-------------- 02_execute_task.sh

# shellcheck source=/dev/null

# Task status file
STATUS_FILE="task_status.txt"

# Create STATUS_FILE if it doesn't exist
if [ ! -f "$STATUS_FILE" ]; then
    touch "$STATUS_FILE"
fi

### Execute Task
#
# Function..........: execute_task
# Description.......: Executes a specified task within the script. It checks if the task 
#                     has been previously completed, requires root privileges, executes 
#                     prerequisites, main actions, and post-actions. It logs each step 
#                     and marks the task as successful or failed in the STATUS_FILE.
# Parameters........: 
#               - $1: Task name (task_name) - the identifier for the task.
#               - $2: Require root (require_root) - specifies if the task requires root privileges.
#               - $3: Prerequisites (prereq) - commands or functions to be executed as prerequisites.
#               - $4: Actions (actions) - the main actions of the task.
#               - $5: Post-actions (postActions) - commands or functions to be executed after the main actions.
# Returns...........: 
#               - 0: If the task is skipped or completed successfully.
#               - 1: If any step (prerequisite, action, post-action) fails or if root privileges are missing.
#
###
execute_task() {

  local task_name="$1"
  local require_root="$2"
  local prereq="$3"
  local actions="$4"
  local postActions="$5"

  log_task "$task_name"

  mark_task_running "$task_name"

  # 01 - Check if Task Previously Succeeded
  if check_task_failed_previously "$task_name"; then
    echo "The task $task_name has already succeeded previously. It is being skipped."
    return "$OK"
  fi

  # 02 - Check for root privileges if required
  if [[ "$require_root" == "true" ]]; then
    if ! verify_has_root_privileges; then
      log_error "Root privileges required for $task_name."
      return "$NOK"
    fi
  fi

  # 03 - Execute the prerequisite if provided
  if [ -n "$prereq" ]; then

    log_prerequisite "Executing prerequisites for $task_name..."
    
    if eval "$prereq"; then
      log_info "Prerequisites completed"
    else
      log_error "Prerequisites failed"
      return "$NOK"  # Stop the procedure if the prerequisite fails
    fi  

  fi

  # 04 - Execute the actions
  log_action "Executing actions for $task_name..."

  if eval "$actions"; then
    log_info "Actions completed"
  else
    log_error "Actions failed"
    return "$NOK"  # Optionally stop also if actions fail
  fi

  # 05 - Execute the post action
  if [ -n "$postActions" ]; then  # Check if 'postActions' variable is not empty

      log_post_actions "Executing post actions for $task_name..."

      if ! eval "$postActions"; then
          log_error "Post actions failed"
          return "$NOK"  # Stop the script if post actions fails
      else
          log_info "Post actions completed successfully"
      fi

  fi

  # 06 - Mark Task as Successfully Completed
  mark_task_ok "$task_name"

  log_info "Task $task_name execution completed successfully"
}

### Execute and Check Task
#
# Function..........: execute_and_check
# Description.......: Executes a specified task and checks its completion status. If the task is 'mandatory' 
#                     and fails, the script terminates. If the task is 'optional' and fails, the script 
#                     continues, returning a non-zero status.
# Parameters........: 
#               - $1: Task name.
#               - $2: Task type ('mandatory' or 'optional').
#               - $3 - $6: Additional parameters required for the task (e.g., root requirement, prerequisites, actions, post-actions).
# Returns...........: 
#               - 0 (OK): If the task is successfully completed.
#               - 1 (NOK): If the task fails and is 'optional'.
#               - Exits the script: If the task fails and is 'mandatory'.
# Usage.............: This function should be used to execute tasks where the failure of 'mandatory' tasks should 
#                     stop the entire script, while 'optional' tasks' failure should not halt the script execution.
# 
###
execute_and_check() {

  local task_name="$1"
  local require_root="$2"
  local prereq="$3"
  local actions="$4"
  local postActions="$5"
  local task_type="$6" 

  execute_task "$task_name" "$require_root" "$prereq" "$actions" "$postActions"
  local status=$?

  if [ $status -ne "$OK" ]; then

    mark_task_ko "$task_name"

    case "$task_type" in
      "mandatory")
        log_error "Mandatory task $task_name failed. Stopping the script."
        exit 1
        ;;

      "optional")
        log_warn "Optional task $task_name failed. Continuing with the script."
        return 1
        ;;

      *)
        log_error "Unrecognized task type $task_type for task $task_name."
        return 1
        ;;
        
    esac

  fi

  return "$OK"
}


### Check if Task Failed Previously
#
# Function..........: check_task_failed_previously
# Description.......: Checks if a given task has failed in previous runs by looking into the 
#                     STATUS_FILE. It searches for an entry with the format 'taskname:ok'. 
#                     If such an entry is found, it means the task was successful in a 
#                     previous run.
# Parameters........: 
#               - $1: The name of the task to check.
# Returns...........: 
#               - 0: If the task was successful in a previous run (entry 'taskname:ok' found).
#               - 1: If the task was not successful in a previous run or if STATUS_FILE 
#                    does not exist.
###
check_task_failed_previously() {
  local task_name=$1

  if [ -f "$STATUS_FILE" ]; then
    grep -q "^$task_name:ok$" "$STATUS_FILE"
    return $?
  fi
  return "$NOK"
}


### Mark Task as Running
#
# Function..........: mark_task_running
# Description.......: Marks a specified task as 'running' in the STATUS_FILE.
#                     If an entry for the task does not exist or if the task is 
#                     not already marked with 'running', 'ko', or 'ok', it adds a 
#                     new 'running' status entry for the task.
# Parameters........: 
#               - $1: The name of the task to be marked as running.
# Returns...........: None.
# Side Effects......: Modifies the STATUS_FILE by adding the status of the task as 'running'.
#                     Does not duplicate entries if the task is already marked with
#                     any status ('running', 'ko', or 'ok').
###
mark_task_running() {
  local task_name=$1

  if [ ! -f "$STATUS_FILE" ]; then
    echo "Error: The file $STATUS_FILE does not exist."
    return $NOK
  fi

  if ! grep -qE "^$task_name:(running|ko|ok)$" "$STATUS_FILE"; then
    echo "$task_name:running" >> "$STATUS_FILE"
  fi
}


### Mark Task as Successful
#
# Function..........: mark_task_ok
# Description.......: Marks a specified task as successful ('ok') in the STATUS_FILE.
#                     If an entry for the task with a 'ko' or 'running' status exists, 
#                     it updates the entry to 'ok'. If no such entry exists, or if 
#                     the task is not already marked with 'ko' or 'running', it adds 
#                     a new 'ok' status entry for the task.
# Parameters........: 
#               - $1: The name of the task to be marked as successful.
# Returns...........: None.
# Side Effects......: Modifies the STATUS_FILE by updating or adding the status of the task.
#                     If the task had a 'ko' or 'running' status, it is changed to 'ok'. 
#                     If the task was not previously listed or had a different status, 
#                     it is added with an 'ok' status.
###
mark_task_ok() {
  local task_name=$1

  if [ ! -f "$STATUS_FILE" ]; then
    echo "Error: The file $STATUS_FILE does not exist."
    return $NOK
  fi

  sed -i "/^$task_name:\(ko\|running\)$/c\\$task_name:ok" "$STATUS_FILE"

  if [ $? -ne 0 ]; then
    echo "$task_name:ok" >> "$STATUS_FILE"
  fi
}

### Mark Task as Unsuccessful
#
# Function..........: mark_task_ko
# Description.......: Marks a specified task as unsuccessful ('ko') in the STATUS_FILE.
#                     If an entry for the task with an 'ok' or 'running' status exists,
#                     it updates the entry to 'ko'. If no such entry exists, or if 
#                     the task is not already marked with 'ok' or 'running', it adds 
#                     a new 'ko' status entry for the task.
# Parameters........: 
#               - $1: The name of the task to be marked as unsuccessful.
# Returns...........: None.
# Side Effects......: Modifies the STATUS_FILE by updating or adding the status of the task.
#                     If the task had an 'ok' or 'running' status, it is changed to 'ko'.
#                     If the task was not previously listed or had a different status,
#                     it is added with a 'ko' status.
###
mark_task_ko() {
  local task_name=$1

  if [ ! -f "$STATUS_FILE" ]; then
    echo "Error: The file $STATUS_FILE does not exist."
    return $NOK
  fi

  sed -i "/^$task_name:\(ok\|running\)$/c\\$task_name:ko" "$STATUS_FILE"

  if [ $? -ne 0 ]; then
    echo "$task_name:ko" >> "$STATUS_FILE"
  fi
}


#-------------- 03_utils.sh

# shellcheck source=/dev/null

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
        return "$NOK"
    fi

    return "$OK"
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

  # Check if APT is available
  if ! command -v apt-get &> /dev/null; then
    log_error "APT package manager not found. This script is intended for Debian-based systems."
    return "$NOK"
  fi

  # Check if the package is already installed using dpkg
  if dpkg -l "$package" | grep -qw "^ii"; then
    log_info "$package is already installed."
    return "$OK"
  else
    log_info "$package is not installed. Installing..."

    if apt-get update &> /dev/null && apt-get install -y "$package" &> /dev/null; then
      log_info "$package has been installed successfully."
      return "$OK"
    else
      log_error "Failed to install $package."
      return "$NOK"
    fi
  fi
}

### Ask for Username Approval
#
# Function..........: ask_for_username_approval
# Description.......: Fetches a random username from an API and asks for user approval.
# Returns...........: The approved username.
# Output............: Logs the progress and results of the username approval process.
#
##
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

    read -r -p "Do you like this username : $username ? (y/n): " approval
    
    if [ "$approval" != "y" ]; then
      log_debug "Fetching a new username..."
    fi

  done

  echo "$username"
}

### Ask for Password Approval
#
# Function..........: ask_for_password_approval
# Description.......: Generates a strong password using the generate_strong_password function and asks for user approval.
# Returns...........: The approved strong password.
# Output............: Echoes the generated password and the query for approval, and logs the progress of password generation and approval.
#
##
ask_for_password_approval() {

  while true; do
    local password=$(pwgen -s -y -c -n 20 1)

    # Is it safe to show password ? 
    read -p "Do you approve this password : $password ? (y/n): " approval

    if [[ "$approval" == "y" || "$approval" == "Y" ]]; then
      echo "$password"
      break
    else
      echo "Generating a new password..."
    fi
  done
}

#-------------- 04_option.sh

### Process Command Line Arguments for Debug Mode
#
# Description.......: This script segment checks for the presence of the '--debug' flag in the command line arguments.
#                     If '--debug' is found, the script sets DEBUG_MODE to 1, enabling debug functionality.
#                     This is useful for turning on additional logging or diagnostic output in the script.
# Arguments.........: 
#               - --debug (optional): Flag to enable debug mode.
# Returns...........: None directly. Sets the global variable DEBUG_MODE to 1 if '--debug' is present.
# Usage.............: Place this snippet at the beginning of a script to enable debug mode based on command line input.
# 
# Example...........: `./script.sh --debug` will enable debug mode by setting DEBUG_MODE to 1.
#
###
DEBUG_MODE=0

for arg in "$@"; do

  if [ "$arg" = "--debug" ]; then
    DEBUG_MODE=1
  fi

done


#-------------- system/configure_adduser.sh - mandatory

# shellcheck source=/dev/null

### Task for Configuring Adduser Defaults
#
# Function..........: task_configure_adduser
# Description.......: Executes a series of actions to configure the default behavior of the `adduser` command,
#                     specifically setting the default directory permissions for new user directories to 0700.
#                     The function checks prerequisites, runs the configuration actions, and handles any post-actions.
#                     This task is critical for ensuring that new user directories are created with secure permissions.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement,
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If the task completes successfully and the default settings are applied.
#               - 1 (NOK): If the task fails at any step.
#
##
task_configure_adduser() {
  
  local name="configure_adduser"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "configure_adduser failed."
    return "$NOK"
  fi

  log_info "configure_adduser has been successfully configure_adduser."
  
  return "$OK"
}

### Check Prerequisites for Configuring Adduser
#
# Function..........: check_prerequisites_configure_adduser
# Description.......: Checks if the /etc/adduser.conf file exists, which is necessary for setting default user 
#                     directory permissions. This file is typically present in Debian-based distributions.
# Returns...........: 
#               - 0 (OK): If /etc/adduser.conf exists.
#               - 1 (KO): If /etc/adduser.conf does not exist.
##
check_prerequisites_configure_adduser() {
  if [ ! -f /etc/adduser.conf ]; then
    log_error "The /etc/adduser.conf file does not exist. This configuration step is required for Debian-based systems."
    return "$KO"
  fi

  return "$OK"
}

### Run Action for Configuring Adduser
#
# Function..........: run_action_configure_adduser
# Description.......: Modifies the /etc/adduser.conf file to set the default directory permissions for new user 
#                     directories to 0700. This change ensures that new user directories are created with permissions 
#                     allowing only the user access, enhancing privacy and security.
# Returns...........: 
#               - 0 (OK): If the modification is successful.
#               - 1 (KO): If an error occurs (handled outside this function).
##
run_action_configure_adduser() {
  # Change the DIR_MODE in /etc/adduser.conf to set new user directories to 0700 permissions
  sed -i '/^DIR_MODE=/s/=.*/=0700/' /etc/adduser.conf
  
  return "$OK"
}

# Run the task to configure_adduser
task_configure_adduser

#-------------- system/update_and_upgrade.sh - mandatory

# shellcheck source=/dev/null

### Update and Upgrade System Task
#
# Function..........: task_update_and_upgrade 
# Description.......: Executes the system update and upgrade process. This function updates the package 
#                     lists and then performs an upgrade of all installed packages. The task requires root 
#                     privileges to execute and can be set as either mandatory or optional.
# Parameters........: None directly. The parameters such as task name, root requirement, actions, and task type 
#                     are predefined within the function.
# Returns...........: 
#               - 0 (OK): If the system update and upgrade complete successfully.
#               - 1 (NOK): If the update and upgrade process fails.
# 
###
task_update_and_upgrade() {

    local name="system_update_upgrade"
    local isRootRequired=true
    local prereq=""
    local actions="apt-get update &> /dev/null && apt-get upgrade -y &> /dev/null" 
    local postActions=""
    local task_type="mandatory"

    if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
        log_error "System upgrade failed."
        return "$NOK"
    fi

    log_info "System update and upgrade completed successfully."
    return "$OK"
}

# Run the update and upgrade task
task_update_and_upgrade
#-------------- system/configure_login_password.sh - mandatory

# shellcheck source=/dev/null

### Configure Login Password Settings
#
# Function..........: task_configure_login_password
# Description.......: Modifies the system's login password policies and settings as defined 
#                     in the system's login definitions file (usually /etc/login.defs). 
#                     This function adjusts settings like maximum and minimum password age, 
#                     password complexity, and other related configurations.
#
# Returns...........: 
#               - 0 (OK): If the task completes successfully.
#               - 1 (NOK): If the task encounters an error or fails.
##
task_configure_login_password() {
  
  local name="configure_login_password"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "xxxx failed."
    return "$NOK"
  fi

  log_info "xxxx has been successfully xxxxx."
  
  return "$OK"
}

### Run Action to Configure Login Password Settings
#
# Function..........: run_action_configure_login_password
# Description.......: Executes modifications to the system's login password settings, 
#                     specifically targeting the /etc/login.defs file. It adjusts various 
#                     parameters like SHA encryption rounds, password aging, and default umask.
#
# Returns...........: 
#               - 0 (OK): If all modifications are successfully applied.
#               - Non-zero value: If an error occurs during the modification process.
##
run_action_configure_login_password() {

    sed -i '/# SHA_CRYPT_MAX_ROUNDS/s/5000/1000000/g' /etc/login.defs
    sed -i '/# SHA_CRYPT_MIN_ROUNDS/s/5000/1000000/g' /etc/login.defs
    sed -i '/PASS_MAX_DAYS/s/99999/180/g' /etc/login.defs
    sed -i '/PASS_MIN_DAYS/s/0/1/g' /etc/login.defs
    sed -i '/PASS_WARN_AGE/s/7/28/g' /etc/login.defs
    sed -i '/UMASK/s/022/027/g' /etc/login.defs
    sed -i '/# SHA_CRYPT_MAX_ROUNDS/s/#//g' /etc/login.defs
    sed -i '/# SHA_CRYPT_MIN_ROUNDS/s/#//g' /etc/login.defs

    return "$OK"
}

# Run the task to configure login password
task_configure_login_password
#-------------- system/configure_password_quality.sh - mandatory

# shellcheck source=/dev/null

### Configure Password Quality Standards
#
# Function..........: task_configure_password_quality
# Description.......: Executes a task to enhance the password quality standards on the system. 
#                     This task aims to set strict password policies to improve system security. 
#                     The function checks prerequisites, executes the main action to adjust password quality settings, 
#                     and handles any necessary post-action steps.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If the password quality standards are successfully configured.
#               - 1 (NOK): If the configuration process fails.
#
###
task_configure_password_quality() {
  
  local name="configure_password_quality"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Configuration of password quality standards failed."
    return "$NOK"
  fi

  log_info "Password quality standards have been successfully configured."
  
  return "$OK"
}

### Check Prerequisites for Configuring Password Quality
#
# Function..........: check_prerequisites_configure_password_quality
# Description.......: Verifies if the libpam-pwquality package is installed on the system. This package 
#                     is necessary for enforcing password quality policies. If the package is not installed,
#                     the script attempts to install it.
# Returns...........: 
#               - 0 (OK): If libpam-pwquality is already installed or successfully installed during the execution.
#               - 1 (NOK): If libpam-pwquality cannot be installed.
#
check_prerequisites_configure_password_quality() {
  # install libpam-pwquality package
  if ! install_package "libpam-pwquality"; then
    return "$NOK"
  fi

  return "$OK"
}

### Enhance Password Security
#
# Function..........: run_action_configure_password_quality
# Description.......: Configures password quality requirements using the pam_pwquality module. 
#                     This function sets various parameters to enforce strong password policies, 
#                     such as minimum length, character diversity, and complexity.
#                     It modifies the /etc/pam.d/common-password file to apply these settings.
# Parameters........: 
#               - None
# Local Variables...:
#               - retry: The number of attempts a user has to enter a compliant password.
#               - minLen: The minimum length required for the password.
#               - difok: The number of characters that must be different from the old password.
#               - ucredit: The requirement for uppercase characters in the password.
#               - lcredit: The requirement for lowercase characters in the password.
#               - dcredit: The requirement for numeric digits in the password.
#               - ocredit: The requirement for non-alphanumeric (special) characters in the password.
#               - maxrepeat: The maximum number of consecutive identical characters allowed in the password.
#               - gecoscheck: Enforces a check against the user's GECOS field to prevent using personal information in the password.
# Returns...........: 
#               - 0 (OK): If the password policy is successfully applied.
#
###
run_action_configure_password_quality() {

  local sshd_config="/etc/pam.d/common-password"

  # Define password quality parameters
  local enforcing=1              # Ensure the policy is enforced
  local retry=3                  # Number of retries for password entry
  local minLen=10                # Minimum length of the password
  local difok=3                  # Number of characters different from the old password
  local ucredit=-1               # Number of required uppercase characters
  local lcredit=-1               # Number of required lowercase characters
  local dcredit=-1               # Number of required digit characters
  local ocredit=-1               # Number of required special characters
  local maxrepeat=3              # Maximum number of consecutive identical characters
  local gecoscheck="gecoscheck"  # Check against the user's GECOS field

  # Form the new pam_pwquality line with the defined parameters
  local pam_pwquality_line="password required pam_pwquality.so enforcing=$enforcing enforce_for_root retry=$retry minlen=$minLen difok=$difok ucredit=$ucredit lcredit=$lcredit dcredit=$dcredit ocredit=$ocredit maxrepeat=$maxrepeat $gecoscheck"

  # Modify the common-password file based on the existence of pam_pwquality.so
  if grep -q "pam_pwquality.so" "$sshd_config"; then
    # Replace the existing pam_pwquality.so line
    sed -i "s/^password.*pam_pwquality.so.*/$pam_pwquality_line/" "$sshd_config"
  else
    # Insert the new line before pam_unix.so
    sed -i "/^password.*pam_unix.so.*/i $pam_pwquality_line" "$sshd_config"
  fi
}

# Run the task to configure password quality
task_configure_password_quality
#-------------- system/secure_sensible_file_permissions.sh - mandatory

# shellcheck source=/dev/null

### Secure and Sensible File Permissions
#
# Function..........: task_secure_sensible_file_permissions
# Description.......: Ensures that file permissions across the system are set in a secure and sensible manner. 
#                     This task involves checking prerequisites, executing the main action to adjust file permissions, 
#                     and handling any necessary post-action steps. It aims to balance security needs with functional requirements.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If the file permissions are successfully secured and sensibly set.
#               - 1 (NOK): If the process fails to complete successfully.
#
###
task_secure_sensible_file_permissions() {
  
  local name="secure_sensible_file_permissions"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Securing and setting sensible file permissions failed."
    return "$NOK"
  fi

  log_info "File permissions have been securely and sensibly configured."
  
  return "$OK"
}


check_prerequisites_secure_sensible_file_permissions(){

  # install jq package
  if ! install_package "sudo"; then
    return "$NOK"
  fi

}


### Set Secure File Permissions
#
# Function..........: run_action_xxxx
# Description.......: Applies a series of ownership and permission changes to critical system files and directories. 
#                     These changes are intended to enhance system security by restricting write and execute access 
#                     to essential system configuration files and directories.
#                     The function modifies permissions for GRUB configuration, user home directories, system critical files 
#                     like /etc/passwd, /etc/group, cron directories, sudoers configuration, SSH configuration, and more.
# Returns...........: 
#               - 0 (OK): If all changes are successfully applied.
#               - 1 (NOK): If any of the changes fail to apply.
#
###
run_action_secure_sensible_file_permissions() {

  chown root:root /etc/grub.conf >/dev/null 2>&1
  chown -R root:root /etc/grub.d >/dev/null 2>&1
  chown root:root /boot/grub2/grub.cfg >/dev/null 2>&1

  chmod og-rwx /etc/grub.conf >/dev/null 2>&1
  chmod og-rwx /etc/grub.conf >/dev/null 2>&1
  chmod -R og-rwx /etc/grub.d >/dev/null 2>&1
  chmod og-rwx /boot/grub2/grub.cfg >/dev/null 2>&1
  chmod og-rwx /boot/grub/grub.cfg >/dev/null 2>&1
  chmod 0700 /home/* >/dev/null 2>&1
  chmod 0644 /etc/passwd
  chmod 0644 /etc/group
  chmod -R 0600 /etc/cron.hourly
  chmod -R 0600 /etc/cron.daily
  chmod -R 0600 /etc/cron.weekly
  chmod -R 0600 /etc/cron.monthly
  chmod -R 0600 /etc/cron.d
  chmod -R 0600 /etc/crontab
  chmod -R 0600 /etc/shadow
  chmod 750 /etc/sudoers.d
  chmod -R 0440 /etc/sudoers.d/*
  chmod 0600 /etc/ssh/sshd_config
  chmod 0750 /usr/bin/w
  chmod 0750 /usr/bin/who
  chmod 0700 /etc/sysctl.conf
  chmod 644 /etc/motd
  chmod 0600 /boot/System.map-* >/dev/null 2>&1

  return "$OK"
}

# Run the task to xxxx
task_secure_sensible_file_permissions
#-------------- system/harden_kernel_settings.sh - mandatory

# shellcheck source=/dev/null

###
# Harden Kernel Settings Task
#
# Function..........: task_harden_kernel_settings
# Description.......: Orchestrates the process of hardening the Linux kernel settings. 
#                     This function is a task wrapper that calls the `run_action_harden_kernel_settings` action. 
#                     It checks for necessary prerequisites, executes the action to harden kernel settings, 
#                     and handles any post-action steps. The function ensures that it is executed with 
#                     the necessary root privileges and logs the outcome of the operation.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If the kernel settings are successfully hardened.
#                     - Non-zero value (NOK): If the process encounters an error or fails to complete successfully.
#
###
task_harden_kernel_settings() {
  
  local name="harden_kernel_settings"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task $name failed to complete successfully."
    return "$NOK"
  fi

  log_info "Task $name has been completed successfully and kernel settings are hardened."
  
  return "$OK"
}

###
# Harden Kernel Settings
#
# Function..........: run_action_harden_kernel_settings
# Description.......: Enhances system security by applying a series of kernel parameter settings aimed at 
#                     hardening the Linux kernel. The function writes each setting to a separate configuration 
#                     file in the `/etc/sysctl.d/` directory. It includes steps for backing up existing 
#                     configurations and implements error checking to ensure each setting is applied correctly.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all kernel settings are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up existing configuration files in `/etc/sysctl.d/` to a designated backup directory.
#                     - Applies a range of security-enhancing settings to the kernel, each written to its own file.
#                     - Includes settings for message restrictions, core dump control, memory randomization, 
#                       and various other security measures.
#                     - Performs error checking after each setting application and logs any failures.
#
###
run_action_harden_kernel_settings() {

    local sysctlDir="/etc/sysctl.d"
    local backupDir="${sysctlDir}/backup"

    # Create backup directory
    mkdir -p "$backupDir"
    
    # Backup current configurations
    find "$sysctlDir" -name '50-*.conf' -exec cp {} "$backupDir/" \;

    # New kernel settings
    local kernelSettings

    kernelSettings+="kernel.dmesg_restrict=1\n"
    kernelSettings+="fs.suid_dumpable=0\n"
    kernelSettings+="kernel.exec-shield=2\n"
    kernelSettings+="kernel.randomize_va_space=2\n"
    kernelSettings+="dev.tty.ldisc_autoload=0\n"
    kernelSettings+="fs.protected_fifos=2\n"
    kernelSettings+="kernel.core_uses_pid=1\n"
    kernelSettings+="kernel.kptr_restrict=2\n"
    kernelSettings+="kernel.sysrq=0\n"
    kernelSettings+="kernel.unprivileged_bpf_disabled=1\n"
    kernelSettings+="kernel.yama.ptrace_scope=1\n"
    kernelSettings+="net.core.bpf_jit_harden=2\n"

    # Apply the settings
    local configFileName

    for setting in $kernelSettings; do

        configFileName=$(echo $setting | awk -F= '{print $1}' | tr '.' '-' | tr '_' '-')
        echo "$setting" > "${sysctlDir}/50-${configFileName}.conf" 2>/dev/null

        if [ $? -ne 0 ]; then
            log_error "Failed to apply setting: $setting"
            cp -r "${backupDir}/." "${sysctlDir}/"
            return "$NOK"
        fi
    done

    log_info "Kernel settings have been successfully hardened."
    return "$OK"
}

# Run the task to harden kernel settings
task_harden_kernel_settings
#-------------- system/harden_network_settings.sh - mandatory

# shellcheck source=/dev/null

###
# Harden Network Settings Task
#
# Function..........: task_harden_network_settings
# Description.......: Coordinates the process of hardening network settings on a Linux system. 
#                     This function serves as a task wrapper, invoking the `run_action_harden_network_settings` 
#                     to apply a range of network security enhancements. It ensures that the task is executed 
#                     with necessary root privileges, checks prerequisites, runs the specified action, 
#                     and handles any required post-action steps. Additionally, the function logs the outcome 
#                     of the task, reporting success or failure.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If the network settings are successfully hardened.
#                     - Non-zero value (NOK): If the task encounters an error or fails to complete successfully.
#
###
task_harden_network_settings() {
  
  local name="harden_network_settings"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task $name failed to complete successfully."
    return "$NOK"
  fi

  log_info "Task $name has been completed successfully and network settings are hardened."
  
  return "$OK"
}

###
# Harden Network Settings
#
# Function..........: run_action_harden_network_settings
# Description.......: This function strengthens network security on a Linux system by applying various 
#                     network-related kernel parameter settings. These settings are aimed at enhancing the 
#                     network stack's resilience against common network attacks and vulnerabilities.
#                     Each setting is written to the `/etc/sysctl.d/50-net-stack.conf` file, either creating 
#                     a new entry or appending to it.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all network settings are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Disables TCP timestamps to prevent timing-based network activity tracking.
#                     - Enables TCP SYN cookies to protect against SYN flood attacks.
#                     - Disables acceptance of source-routed packets on all interfaces to prevent source routing attacks.
#                     - Disables ICMP redirect acceptance to prevent malicious routing information updates.
#                     - Ignores ICMP echo requests sent to broadcast addresses to prevent network broadcast amplification attacks.
#                     - Enables logging of "martian packets" (packets with impossible source addresses).
#                     - Enables reverse path filtering to validate incoming packets.
#                     - Disables sending of ICMP redirects on all interfaces to prevent misuse in network traffic redirection.
#
###
run_action_harden_network_settings() {

    local configFile="/etc/sysctl.d/50-net-stack.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    cp "$configFile" "$backupFile"

    # Prepare the new settings
    local settings
    settings+="net.ipv4.tcp_timestamps=0\n"
    settings+="net.ipv4.tcp_syncookies=1\n"
    settings+="net.ipv4.conf.all.accept_source_route=0\n"
    settings+="net.ipv4.conf.all.accept_redirects=0\n"
    settings+="net.ipv4.icmp_echo_ignore_broadcasts=1\n"
    settings+="net.ipv4.conf.all.log_martians=1\n"
    settings+="net.ipv4.conf.all.rp_filter=1\n"
    settings+="net.ipv4.conf.all.send_redirects=0\n"
    settings+="net.ipv4.conf.default.accept_source_route=0\n"
    settings+="net.ipv4.conf.default.log_martians=1\n"

    # Apply the settings
    echo -e "$settings" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to apply network settings."
        mv "$backupFile" "$configFile"
        return "$NOK"
    else
        log_info "Network settings have been successfully applied."
        return "$OK"
    fi
}

# Run the task to harden kernel settings
task_harden_network_settings
#-------------- system/harden_file_system_settings.sh - mandatory

# shellcheck source=/dev/null

###
# Harden File System Settings Task
#
# Function..........: task_harden_file_system_settings
# Description.......: Coordinates the process of hardening the file system settings on a Linux system. 
#                     This function serves as a task wrapper, invoking the `run_action_harden_file_system_settings` 
#                     to apply specific security enhancements to file system settings. It ensures that the task 
#                     is executed with necessary root privileges, checks prerequisites, runs the specified action, 
#                     and handles any required post-action steps. Additionally, the function logs the outcome 
#                     of the task, reporting success or failure.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If the file system settings are successfully hardened.
#                     - Non-zero value (NOK): If the task encounters an error or fails to complete successfully.
#
##
task_harden_file_system_settings() {
  
  local name="harden_file_system_settings"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task $name failed to complete successfully."
    return "$NOK"
  fi

  log_info "Task $name has been completed successfully and file_system settings are hardened."
  
  return "$OK"
}

###
# Harden File System Settings
#
# Function..........: run_action_harden_file_system_settings
# Description.......: Enhances the security of the file system on a Linux system by applying specific 
#                     kernel parameter settings. These settings increase the security around hardlinks and symlinks, 
#                     reducing the risk of certain types of exploits. The function writes these settings to a 
#                     dedicated configuration file in `/etc/sysctl.d/`.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all file system settings are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the current configuration file before making changes.
#                     - Applies settings to enhance the security of hardlinks and symlinks.
#                     - Writes the settings to `/etc/sysctl.d/50-fs-hardening.conf`.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
run_action_harden_file_system_settings() {

    local configFile="/etc/sysctl.d/50-fs-hardening.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    [ -f "$configFile" ] && cp "$configFile" "$backupFile"

    # Prepare the new settings
    local settings
    settings="fs.protected_hardlinks=1\n"
    settings+="fs.protected_symlinks=1\n"

    # Apply the settings
    echo -e "$settings" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to apply file system settings."
        [ -f "$backupFile" ] && mv "$backupFile" "$configFile"
        return 1  # or any non-zero value for NOK
    else
        log_info "File system settings have been successfully hardened."
        return 0  # or use a predefined constant for OK
    fi
}

# Run the task to harden kernel settings
task_harden_file_system_settings
#-------------- system/disable_uncommon_file_system.sh - mandatory

# shellcheck source=/dev/null

###
# Disable Uncommon File Systems
#
# Function..........: run_action_disable_uncommon_file_system
# Description.......: Disables a set of uncommon file systems in a Linux environment for security purposes. 
#                     The function writes configurations to the `/etc/modprobe.d/uncommon-fs.conf` file, 
#                     effectively instructing the system to do nothing (use `/bin/true`) when an attempt is 
#                     made to load these file systems. This can help in mitigating the risks associated with 
#                     less commonly used file systems, which might not be as well vetted for vulnerabilities.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all configurations are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing configuration file in `/etc/modprobe.d/` before making changes.
#                     - Writes settings to disable a list of file systems including cramfs, freevxfs, jffs2, 
#                       hfs, hfsplus, squashfs, udf, fat, vfat, and gfs2.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
task_disable_uncommon_file_system() {
  
  local name="disable_uncommon_file_system"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task for disabling uncommon file systems ($name) failed."
    return "$NOK"
  fi

  log_info "Task for disabling uncommon file systems ($name) has been successfully completed."
  
  return "$OK"
}

###
# Disable Uncommon File Systems
#
# Function..........: run_action_disable_uncommon_file_system
# Description.......: Disables a set of uncommon file systems in a Linux environment for security purposes. 
#                     The function writes configurations to the `/etc/modprobe.d/uncommon-fs.conf` file, 
#                     effectively instructing the system to do nothing (use `/bin/true`) when an attempt is 
#                     made to load these file systems. This can help in mitigating the risks associated with 
#                     less commonly used file systems, which might not be as well vetted for vulnerabilities.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all configurations are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing configuration file in `/etc/modprobe.d/` before making changes.
#                     - Writes settings to disable a list of file systems including cramfs, freevxfs, jffs2, 
#                       hfs, hfsplus, squashfs, udf, fat, vfat, and gfs2.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
run_action_disable_uncommon_file_system() {

    local configFile="/etc/modprobe.d/uncommon-fs.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    [ -f "$configFile" ] && cp "$configFile" "$backupFile"

    # Prepare the settings
    local settings
    settings="install cramfs /bin/true\n"
    settings+="install freevxfs /bin/true\n"
    settings+="install jffs2 /bin/true\n"
    settings+="install hfs /bin/true\n"
    settings+="install hfsplus /bin/true\n"
    settings+="install squashfs /bin/true\n"
    settings+="install udf /bin/true\n"
    settings+="install fat /bin/true\n"
    settings+="install vfat /bin/true\n"
    settings+="install gfs2 /bin/true\n"

    # Apply the settings
    echo -e "$settings" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to disable uncommon file systems."
        # Optionally restore from backup
        [ -f "$backupFile" ] && mv "$backupFile" "$configFile"
        return 1  # or any non-zero value for NOK
    else
        log_info "Uncommon file systems have been successfully disabled."
        return 0  # or use a predefined constant for OK
    fi
}

# Run the task to disable uncommon file system
task_disable_uncommon_file_system

#-------------- system/disable_uncommon_network_protocols.sh - mandatory

# shellcheck source=/dev/null

###
# Disable Uncommon Network Protocols
#
# Function..........: run_action_disable_uncommon_network_protocols
# Description.......: This function increases network security on a Linux system by disabling uncommon 
#                     network protocols. It does this by writing configurations to the 
#                     `/etc/modprobe.d/uncommon-net.conf` file, instructing the system to do nothing 
#                     (`/bin/true`) when an attempt is made to load these protocols. This helps mitigate 
#                     risks associated with less commonly used network protocols, which might be less 
#                     secure or less scrutinized for vulnerabilities.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all configurations are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing configuration file in `/etc/modprobe.d/` before making changes.
#                     - Writes settings to disable a list of network protocols including dccp, sctp, rds, and tipc.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
task_disable_uncommon_network_protocols() {
  
  local name="disable_uncommon_network_protocols"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task to disable uncommon network protocols ($name) failed."
    return "$NOK"
  fi

  log_info "Task to disable uncommon network protocols ($name) has been completed successfully."
  
  return "$OK"
}

###
# Disable Uncommon Network Protocols
#
# Function..........: run_action_disable_uncommon_network_protocols
# Description.......: This function increases network security on a Linux system by disabling uncommon 
#                     network protocols. It does this by writing configurations to the 
#                     `/etc/modprobe.d/uncommon-net.conf` file, instructing the system to do nothing 
#                     (`/bin/true`) when an attempt is made to load these protocols. This helps mitigate 
#                     risks associated with less commonly used network protocols, which might be less 
#                     secure or less scrutinized for vulnerabilities.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all configurations are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing configuration file in `/etc/modprobe.d/` before making changes.
#                     - Writes settings to disable a list of network protocols including dccp, sctp, rds, and tipc.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
run_action_disable_uncommon_network_protocols() {

    local configFile="/etc/modprobe.d/uncommon-net.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    [ -f "$configFile" ] && cp "$configFile" "$backupFile"

    # Prepare the settings
    local settings
    settings="install dccp /bin/true\n"
    settings+="install sctp /bin/true\n"
    settings+="install rds /bin/true\n"
    settings+="install tipc /bin/true\n"

    # Apply the settings
    echo -e "$settings" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to disable uncommon network protocols."
        # Optionally restore from backup
        [ -f "$backupFile" ] && mv "$backupFile" "$configFile"
        return $NOK
    else
        log_info "Uncommon network protocols have been successfully disabled."
        return $OK
    fi
}

# Run the task to disable uncommon network protocols
task_disable_uncommon_network_protocols
#-------------- system/disable_uncommon_network_interfaces.sh - mandatory

# shellcheck source=/dev/null


task_disable_uncommon_network_interfaces() {
  
  local name="disable_uncommon_network_interfaces"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task to disable uncommon network interfaces ($name) failed."
    return "$NOK"
  fi

  log_info "Task to disable uncommon network interfaces ($name) has been completed successfully."
  
  return "$OK"
}

###
# Disable Uncommon Network interfaces
#
# Function..........: run_action_disable_uncommon_network_interfaces
# Description.......: Disables specific, less commonly used network interfaces for enhanced system security. 
#                     Currently, this function is configured to disable the Bluetooth interfaces by writing 
#                     configurations to `/etc/modprobe.d/bluetooth.conf`. It prevents the automatic loading 
#                     of the Bluetooth module.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If the configuration to disable Bluetooth is successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing Bluetooth configuration file before making changes.
#                     - Writes the setting to disable the Bluetooth interfaces.
#                     - Performs error checking after applying the setting and logs any failures.
#
##
run_action_disable_uncommon_network_interfaces() {

    local configFile="/etc/modprobe.d/bluetooth.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    [ -f "$configFile" ] && cp "$configFile" "$backupFile"

    # Prepare the setting to disable Bluetooth
    local setting="install bluetooth /bin/true"

    # Apply the setting
    echo "$setting" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to disable Bluetooth interfaces."
        # Optionally restore from backup
        [ -f "$backupFile" ] && mv "$backupFile" "$configFile"
        return $NOK
    else
        log_info "Bluetooth interfaces has been successfully disabled."
        return $OK
    fi
}

# Run the task to disable uncommon network interfaces
task_disable_uncommon_network_interfaces
#-------------- system/disable_uncommon_sound_drivers.sh - mandatory

# shellcheck source=/dev/null

###
# Disable Uncommon Sound Drivers Task
#
# Function..........: task_disable_uncommon_sound_drivers
# Description.......: Orchestrates the process of disabling uncommon sound drivers on a Linux system. 
#                     This function serves as a wrapper, calling `run_action_disable_uncommon_sound_drivers`
#                     to apply specific security measures against less commonly used sound drivers.
#                     It checks for necessary prerequisites, executes the action, and handles any 
#                     post-action steps. The function also logs the outcome of the task.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If the task successfully disables the uncommon sound drivers.
#                     - Non-zero value (NOK): If the task encounters an error or fails to complete successfully.
#
##
task_disable_uncommon_sound_drivers() {
  
  local name="disable_uncommon_sound_drivers"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task to disable uncommon sound drivers ($name) failed."
    return "$NOK"
  fi

  log_info "Task to disable uncommon sound drivers ($name) has been completed successfully."
  
  return "$OK"
}

###
# Disable Uncommon Sound Drivers
#
# Function..........: run_action_disable_uncommon_sound_drivers
# Description.......: Increases system security by disabling a set of uncommon sound drivers. 
#                     This is done by writing configurations to `/etc/modprobe.d/uncommon-sound.conf`, 
#                     instructing the system to effectively ignore attempts to load these drivers.
#                     It's a preventive measure against potential vulnerabilities or attacks via these drivers.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all configurations are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing configuration file before making changes.
#                     - Writes settings to disable a list of uncommon sound drivers including snd-usb-audio, 
#                       snd-usb-caiaq, snd-usb-us122l, and snd-usb-usx2y.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
run_action_disable_uncommon_sound_drivers() {

    local configFile="/etc/modprobe.d/uncommon-sound.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    [ -f "$configFile" ] && cp "$configFile" "$backupFile"

    # Prepare the settings
    local settings

    settings="install snd-usb-audio /bin/true\n"
    settings+="install snd-usb-caiaq /bin/true\n"
    settings+="install snd-usb-us122l /bin/true\n"
    settings+="install snd-usb-usx2y /bin/true\n"

    # Apply the settings
    echo -e "$settings" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to disable uncommon sound drivers."
        # Optionally restore from backup
        [ -f "$backupFile" ] && mv "$backupFile" "$configFile"
        return "$NOK"
    else
        log_info "Uncommon sound drivers have been successfully disabled."
        return "$OK"
    fi
}

# Run the task to disable uncommon sound drivers
task_disable_uncommon_sound_drivers
#-------------- system/disable_uncommon_input_drivers.sh - mandatory

# shellcheck source=/dev/null

###
# Disable Uncommon Input Drivers Task
#
# Function..........: task_disable_uncommon_input_drivers
# Description.......: Orchestrates the process of disabling uncommon input drivers on a Linux system. 
#                     This function acts as a wrapper, executing `run_action_disable_uncommon_input_drivers`
#                     to apply specific security measures against less commonly used input drivers.
#                     It ensures that the task is executed with the necessary root privileges, checks prerequisites,
#                     runs the specified action, and handles any required post-action steps. The function also logs
#                     the outcome of the task, indicating success or failure.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If the task successfully disables the uncommon input drivers.
#                     - Non-zero value (NOK): If the task encounters an error or fails to complete successfully.
#
##
task_disable_uncommon_input_drivers() {
  
  local name="disable_uncommon_input_drivers"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task to disable uncommon input drivers ($name) failed."
    return "$NOK"
  fi

  log_info "Task to disable uncommon input drivers ($name) has been completed successfully."
  
  return "$OK"
}

###
# Disable Uncommon Input Drivers
#
# Function..........: run_action_disable_uncommon_input_drivers
# Description.......: Increases system security by disabling a set of uncommon input drivers. 
#                     This is done by writing configurations to `/etc/modprobe.d/uncommon-input.conf`, 
#                     instructing the system to effectively ignore attempts to load these drivers.
#                     This preventive measure targets potential vulnerabilities or attacks via these drivers.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all configurations are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing configuration file before making changes.
#                     - Writes settings to disable a list of uncommon input drivers including joydev, pcspkr, 
#                       serio_raw, snd-rawmidi, snd-seq-midi, snd-seq-oss, snd-seq, snd-seq-device, snd-timer, 
#                       and snd.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
run_action_disable_uncommon_input_drivers() {

    local configFile="/etc/modprobe.d/uncommon-input.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    [ -f "$configFile" ] && cp "$configFile" "$backupFile"

    # Prepare the settings
    local settings
    settings="install joydev /bin/true\n"
    settings+="install pcspkr /bin/true\n"
    settings+="install serio_raw /bin/true\n"
    settings+="install snd-rawmidi /bin/true\n"
    settings+="install snd-seq-midi /bin/true\n"
    settings+="install snd-seq-oss /bin/true\n"
    settings+="install snd-seq /bin/true\n"
    settings+="install snd-seq-device /bin/true\n"
    settings+="install snd-timer /bin/true\n"
    settings+="install snd /bin/true\n"

    # Apply the settings
    echo -e "$settings" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to disable uncommon input drivers."
        # Optionally restore from backup
        [ -f "$backupFile" ] && mv "$backupFile" "$configFile"
        return 1  # NOK
    else
        log_info "Uncommon input drivers have been successfully disabled."
        return 0  # OK
    fi
}

# Run the task to disable uncommon input drivers
task_disable_uncommon_input_drivers

#-------------- system/disable_uncommon_firewire.sh - mandatory

# shellcheck source=/dev/null

###
# Disable Uncommon FireWire Drivers Task
#
# Function..........: task_disable_uncommon_firewire
# Description.......: Orchestrates the process of disabling uncommon FireWire drivers on a Linux system. 
#                     This function acts as a wrapper, executing `run_action_disable_uncommon_firewire`
#                     to apply specific security measures against less commonly used FireWire drivers.
#                     It ensures that the task is executed with the necessary root privileges, checks prerequisites,
#                     runs the specified action, and handles any required post-action steps. The function also logs
#                     the outcome of the task, indicating success or failure.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If the task successfully disables the uncommon FireWire drivers.
#                     - Non-zero value (NOK): If the task encounters an error or fails to complete successfully.
#
##
task_disable_uncommon_firewire() {
  
  local name="disable_uncommon_firewire"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Task to disable uncommon FireWire drivers ($name) failed."
    return "$NOK"
  fi

  log_info "Task to disable uncommon FireWire drivers ($name) has been completed successfully."
  
  return "$OK"
}

###
# Disable Uncommon FireWire Drivers
#
# Function..........: run_action_disable_uncommon_firewire
# Description.......: Enhances system security by disabling a set of uncommon FireWire drivers. 
#                     The function writes configurations to `/etc/modprobe.d/firewire.conf`, 
#                     instructing the system to effectively ignore attempts to load these drivers.
#                     This action is a preventive measure against potential vulnerabilities or 
#                     attacks via these drivers.
# Parameters........: None
# Returns...........: 
#                     - 0 (OK): If all configurations are successfully applied.
#                     - Non-zero value (NOK): If any part of the process fails.
# Actions...........: 
#                     - Backs up the existing configuration file before making changes.
#                     - Writes settings to disable uncommon FireWire drivers including firewire-core, 
#                       firewire-ohci, and firewire-sbp2.
#                     - Performs error checking after applying the settings and logs any failures.
#
##
run_action_disable_uncommon_firewire() {

    local configFile="/etc/modprobe.d/firewire.conf"
    local backupFile="${configFile}.backup"

    # Backup the current configuration
    [ -f "$configFile" ] && cp "$configFile" "$backupFile"

    # Prepare the settings
    local settings
    settings="install firewire-core /bin/true\n"
    settings+="install firewire-ohci /bin/true\n"
    settings+="install firewire-sbp2 /bin/true\n"

    # Apply the settings
    echo -e "$settings" > "$configFile" 2>/dev/null

    if [ $? -ne 0 ]; then
        log_error "Failed to disable uncommon FireWire drivers."
        # Optionally restore from backup
        [ -f "$backupFile" ] && mv "$backupFile" "$configFile"
        return 1  # NOK
    else
        log_info "Uncommon FireWire drivers have been successfully disabled."
        return 0  # OK
    fi
}

# Run the task to disable uncommon firewire
task_disable_uncommon_firewire

#-------------- user/add_random_user_password_with_sudo.sh - mandatory

# shellcheck source=/dev/null

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
  local task_type="mandatory"

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

#-------------- network/ssh_random_port.sh - mandatory

# shellcheck source=/dev/null

### Task for Setting a Random SSH Port
#
# Function..........: task_ssh_random_port
# Description.......: Executes a series of actions to set a random port for the SSH service. 
#                     This involves checking prerequisites, executing the main action to set a random port,
#                     and performing any necessary post-actions. The task ensures enhanced security by 
#                     changing the SSH port to a non-standard value.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement,
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If the process of setting a random SSH port is successful.
#               - 1 (NOK): If any step in the process fails.
#
###
task_ssh_random_port() {
  
  # Random port ssh
  local name="ssh_random_port"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Failed to set a random SSH port."
    return "$NOK"
  fi

  log_info "Random SSH port has been successfully set."
  
  return "$OK"
}

### Check Prerequisites for SSH Random Port Configuration
#
# Function..........: check_prerequisites_ssh_random_port
# Description.......: Verifies if the SSH package is installed on the system. If not, it attempts to install 
#                     the SSH package. This check ensures that the necessary SSH tools are available 
#                     before attempting to modify SSH configuration settings, like changing the SSH port.
# Returns...........: 
#               - 0 (OK): If the SSH package is already installed or successfully installed during the execution.
#               - 1 (NOK): If the SSH package cannot be installed.
#
###
check_prerequisites_ssh_random_port() {
  # install ssh package
  if ! install_package "ssh"; then
    return "$NOK"
  fi

  return "$OK"
}

### Run Action to Set a Random SSH Port
#
# Function..........: run_action_ssh_random_port
# Description.......: Sets a random port for the SSH service by modifying the SSH configuration file (sshd_config). 
#                     It selects a random port between 1024 and 65535, then updates the sshd_config file to use this port. 
#                     After updating the configuration, the SSH service is restarted to apply the changes.
#                     The new port number is also saved to a file (/etc/ssh/ssh_port_info.txt) for reference.
# Parameters........: None. Uses local variables to generate a random port and define actions.
# Returns...........: The return status of the 'execute_task' function, which executes the actions and configurations.
#
###
run_action_ssh_random_port() {
  local random_port
  local user_response

  while true; do
    random_port=$(shuf -i 1024-65535 -n 1) # Generate a random port between 1024 and 65535
    read -p "Use port $random_port for SSH? (y/n): " user_response

    case $user_response in
      [Yy]* ) 
        sed -i "s/^#Port 22/Port $random_port/" /etc/ssh/sshd_config
        log_info "SSH is now listening on port: $random_port"
        break;;
      [Nn]* ) 
        log_debug "Skipping port $random_port."
        continue;;
      * ) 
        echo "Please answer yes or no.";;
    esac
  done
}

### Post Actions for SSH Random Port Configuration
#
# Function..........: post_actions_ssh_random_port
# Description.......: Performs the final action after setting a random SSH port, which involves restarting 
#                     the SSH service. This ensures that the new port setting takes effect. The function checks 
#                     if the SSH service is active and then attempts to restart it.
# Returns...........: 
#               - 0 (OK): If the SSH service is active and successfully restarted.
#               - 1 (NOK): If the SSH service is not active or fails to restart.
#
###
post_actions_ssh_random_port() {
  log_info "Restarting SSH service to apply random port changes."

  # Using systemctl to restart the SSH service
  if systemctl is-active --quiet ssh; then
    systemctl restart ssh
    if [ $? -eq 0 ]; then
      log_info "SSH service restarted successfully to apply new port settings."
    else
    log_error "SSH service is not active and cannot be restarted."
      return "$NOK"
    fi
  else
    log_error "SSH service is not active and cannot be restarted."
    return "$NOK"
  fi


  return "$OK"
}


# Run the task to set a random SSH port
task_ssh_random_port
#-------------- firewall/ufw_settings.sh - mandatory

# shellcheck source=/dev/null

### Task: Configure UFW Settings
#
# Function..........: task_ufw_settings
# Description.......: This task configures UFW settings on the system. It ensures that UFW is 
#                     installed, deactivates it if active, and sets firewall rules to allow SSH and HTTP(S) traffic while 
#                     blocking all other incoming and outgoing traffic.
# Parameters........: None
# Returns...........: 
#               - 0 (OK): If UFW settings are successfully configured as specified.
#               - 1 (NOK): If the task fails to complete successfully.
#
##
task_ufw_settings() {
  
  local name="ufw_settings"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "xxxx failed."
    return "$NOK"
  fi

  log_info "xxxx has been successfully xxxxx."
  
  return "$OK"
}

### Check Prerequisites for UFW Settings
#
# Function..........: check_prerequisites_ufw_settings
# Description.......: Ensures that all prerequisites for configuring UFW settings are met. 
#                     This function checks for the installation of the UFW package and disables UFW if it's active.
# Returns...........: 
#               - 0 (OK): If the UFW package is installed and UFW is either inactive or successfully disabled.
#               - 1 (NOK): If the installation of the UFW package fails or disabling UFW fails.
#
##
check_prerequisites_ufw_settings() {
  # install ufw package
  if ! install_package "ufw"; then
    return "$NOK"
  fi

  if ufw status | grep -q "Status: active"; then
    ufw disable
    log_info "UFW has been disabled."
  fi

  return "$OK"
}

### Action: Configure UFW Settings
#
# Function..........: run_action_ufw_settings
# Description.......: This action configures UFW settings on the system. It retrieves the SSH port 
#                     from the SSH configuration file, resets UFW to its default state, sets default policies to deny 
#                     incoming and outgoing traffic, and then allows incoming and outgoing traffic for HTTP (port 80), HTTPS 
#                     (port 443), and SSH. This effectively blocks all other incoming and outgoing traffic except for the 
#                     specified services.
# Returns...........: 
#               - 0 (OK): If UFW settings are successfully configured as specified.
#
##
run_action_ufw_settings() {

    # Retrieve the SSH port
    local ssh_port=$(grep ^Port /etc/ssh/sshd_config | awk '{print $2}')
    if [ -z "$ssh_port" ]; then
        ssh_port=22  # default SSH port
    fi
    log_info "SSH is configured to use port $ssh_port."

    # Reset UFW to default to ensure a clean slate
    ufw --force reset

    # Set default policies
    ufw default deny incoming
    ufw default deny outgoing

    # Allow HTTP (port 80)
    ufw allow in 80/tcp
    ufw allow out 80/tcp

    # Allow HTTPS (port 443)
    ufw allow in 443/tcp
    ufw allow out 443/tcp

    # Allow DNS port
    ufw allow out 53
    ufw allow in 53

    # Allow SSH port
    ufw allow in $ssh_port/tcp
    ufw allow out $ssh_port/tcp

    log_info "UFW has been configured: HTTP, HTTPS, DNS AND SSH ($ssh_port) are allowed; all other traffic is denied."

    return "$OK"
}

### Post-Action: Enable and Verify UFW Settings
#
# Function..........: post_actions_ufw_settings
# Description.......: This post-action enables UFW on the system and verifies its status to ensure 
#                     that it is active and running. It also logs the relevant status information.
# Returns...........: 
#               - 0 (OK): If UFW is successfully enabled and verified to be active.
#               - 1 (NOK): If UFW fails to enable or is not active as expected.
#
##
post_actions_ufw_settings() {

    ufw enable
    log_info "UFW has been enabled."

    # Test UFW status
    local ufw_status=$(ufw status)
    if [[ $ufw_status == *"Status: active"* ]]; then
        log_info "UFW is active and running."
    else
        log_error "UFW is not active. Please check the configuration."
        return "$NOK"
    fi

    return "$OK"
}


# Run the task to ufw settings
task_ufw_settings

#-------------- tool_secure/fail2ban.sh - mandatory
# shellcheck source=/dev/null

### Task for Installing and Configuring Fail2Ban
#
# Function..........: add_fail2ban
# Description.......: Performs the task of installing and configuring Fail2Ban on the system. Fail2Ban is a tool 
#                     that helps protect against unauthorized access by monitoring system logs and automatically 
#                     banning IP addresses that show malicious signs. This task involves checking prerequisites, 
#                     running the installation and configuration actions, and performing any necessary post-actions.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement,
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If Fail2Ban is successfully installed and configured.
#               - 1 (NOK): If the process fails at any point.#
###
task_add_fail2ban() {
  
  local name="add_fail2ban"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Fail2Ban installation and configuration failed."
    return "$NOK"
  fi

  log_info "Fail2Ban has been successfully installed and configured."
  
  return "$OK"
}

### Check Prerequisites for Fail2Ban and Rsyslog Installation
#
# Function..........: check_prerequisites_add_fail2ban
# Description.......: Ensures that both 'rsyslog' and 'fail2ban' packages are installed on the system. 
#                     'rsyslog' is used for system logging, and its presence is crucial for Fail2Ban to monitor logs. 
#                     'fail2ban' is an intrusion prevention software framework that protects computer servers from brute-force attacks.
#                     The function attempts to install these packages if they are not already present.
# Returns...........: 
#               - 0 (OK): If both rsyslog and Fail2Ban are already installed or successfully installed during execution.
#               - 1 (NOK): If either rsyslog or Fail2Ban cannot be installed.
#
###
check_prerequisites_add_fail2ban() {

  # install rsyslog package
  if ! install_package "rsyslog"; then
    return "$NOK"
  fi

  # install fail2ban package
  if ! install_package "fail2ban"; then
    return "$NOK"
  fi

  local max_attempts=3
  local attempt=1

  # Check if fail2ban service is active, if not try to reconfigure and restart
  while ! systemctl is-active --quiet fail2ban; do
    if (( attempt > max_attempts )); then
      log_error "Failed to activate fail2ban service after $max_attempts attempts."
      return "$NOK"
    fi

    log_info "Fail2Ban service not active, attempting to reconfigure (Attempt $attempt/$max_attempts)."
    dpkg-reconfigure fail2ban

    # Increment the attempt counter
    ((attempt++))
  done

  return "$OK"
}

### Run Action to Configure Fail2Ban
#
# Function..........: run_action_fail2ban
# Description.......: Sets up the basic configuration for Fail2Ban by creating and populating a 'jail.local' file. 
#                     This file sets the default ban time, find time, and maximum retry attempts before an IP is banned. 
#                     These settings are crucial for defining how Fail2Ban handles potential security threats.
# Parameters........: None. The function uses hardcoded values and a predefined path for the 'jail.local' file.
# Returns...........: None directly. The configuration is written to '/etc/fail2ban/jail.local'.
#
###
run_action_add_fail2ban() {

    local jail_local="/etc/fail2ban/jail.local"

    log_info "Configuring Fail2Ban with basic settings in jail.local."

    # Default configuration
    echo '[DEFAULT]' | sudo tee $jail_local
    echo 'bantime=10m' | sudo tee -a $jail_local
    echo 'findtime=10m' | sudo tee -a $jail_local
    echo 'maxretry=5' | sudo tee -a $jail_local

    # SSH specific configuration
    echo "" | sudo tee -a $jail_local
    echo '[sshd]' | sudo tee -a $jail_local
    echo 'enabled=true' | sudo tee -a $jail_local
    echo 'port=ssh' | sudo tee -a $jail_local
    echo 'filter=sshd' | sudo tee -a $jail_local
    echo 'logpath=/var/log/auth.log' | sudo tee -a $jail_local
    echo 'maxretry=5' | sudo tee -a $jail_local

    log_info "SSH Fail2Ban configuration successfully added to $jail_local."
}

### Post Actions for Fail2Ban Configuration
#
# Function..........: post_actions_fail2ban
# Description.......: Restarts the Fail2Ban service to apply any new configurations made to the system. This function 
#                     first checks if the Fail2Ban service is active and then proceeds to restart it, ensuring that 
#                     all configuration changes are loaded and enforced.
# Returns...........: 
#               - 0 (OK): If the Fail2Ban service is successfully restarted.
#               - 1 (NOK): If the Fail2Ban service is not active or fails to restart.
#
###
post_actions_add_fail2ban() {
  
    log_info "Restarting Fail2Ban service to apply new configuration."

    systemctl enable fail2ban

    if systemctl is-active --quiet fail2ban; then
        systemctl restart fail2ban
        if [ $? -eq 0 ]; then
            log_info "Fail2Ban service restarted successfully."
        else
            log_error "Failed to restart Fail2Ban service."
            return "$NOK"
        fi
    else
        log_error "Fail2Ban service is not active."
        return "$NOK"
    fi

    return "$OK"
}

# Run the task to add fail2ban and configure
task_add_fail2ban

#-------------- tool_secure/knockd.sh - mandatory

# shellcheck source=/dev/null

### Task for Installing and Configuring Knockd
#
# Function..........: task_add_knockd
# Description.......: Performs the task of installing and configuring Knockd on the system. Knockd is a port knocking
#                     daemon that allows secure access to network services by triggering predefined sequences of
#                     connection attempts (knocks). This task involves checking prerequisites, running the installation
#                     and configuration actions, and performing any necessary post-actions.
# Returns:
#   - 0 (OK): If Knockd is successfully installed and configured.
#   - 1 (NOK): If the process fails at any point during the task.
#
##
task_add_knockd() {
  
  local name="add_knockd"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "xxxx failed."
    return "$NOK"
  fi

  log_info "xxxx has been successfully xxxxx."
  
  return "$OK"
}

### Check Prerequisites for Knockd Installation
#
# Function..........: check_prerequisites_add_knockd
# Description.......: Ensures that the 'knockd' package is installed on the system as a prerequisite for configuring
#                     port knocking. This function attempts to install the 'knockd' package if it's not already present.
# Parameters........: None.
# Returns:
#   - 0 (OK): If the 'knockd' package is already installed or is successfully installed during execution.
#   - 1 (NOK): If the 'knockd' package cannot be installed.
#
##
check_prerequisites_add_knockd() {

    # Check if ufw is installed
    if ! command -v ufw >/dev/null 2>&1; then
        log_error "ufw must be installed"
        return "$NOK"
    fi

    # Check if ssh is installed
    if ! install_package "ssh"; then
    log_error "ssh must be installed"
        return "$NOK"
    fi

    # Install knockd package
    if ! install_package "knockd"; then
        return "$NOK"
    fi

    local ssh_port=$(grep "^Port " "/etc/ssh/sshd_config" | cut -d ' ' -f2)

    # Count the total number of lines
    local total_lines=$(sudo ufw status numbered | wc -l)

    # Loop from the last line to the first
    for ((i=$total_lines; i>0; i--)); do
        # Read line i
        line=$(sudo ufw status numbered | tail -n +$i | head -n 1)
        
        # Check if the line contains the SSH port
        if echo "$line" | grep -q "$ssh_port"; then
          # Extract the rule number and remove the brackets
          rule_num=$(echo "$line" | cut -d ']' -f 1 | tr -d '[')
            
          # Delete the corresponding rule
          ufw --force delete "$rule_num"
        fi
    done

    return "$OK"
}

### Configure Port Knocking with knockd
#
# Function..........: run_action_add_knockd
# Description.......: Configures port knocking using 'knockd'. This function creates or updates the 'knockd.conf' 
#                     configuration file with the desired settings for port knocking. It also performs validation
#                     of the configuration using 'knockd --check-config'.
# Parameters........: None.
# Returns:
#   - 0 (OK): If the port knocking configuration is successfully written and validated.
#   - 1 (NOK): If there is an error in the configuration or validation fails.
#
##
run_action_add_knockd() {

  local knockd_conf="/etc/knockd.conf"
  local sshd_conf="/etc/ssh/sshd_config"
  local ssh_port=$(grep "^Port " $sshd_conf | cut -d ' ' -f2)

  # Extract the main network interface name
  local interface=$(ip addr | grep 'state UP' | grep -v 'lo' | cut -d ':' -f2 | awk '{print $1}' | head -n 1)

  log_info "Configuring port knocking with knockd on interface $interface."

  # Backup existing configuration if it exists
  if [ -f "$knockd_conf" ]; then
    cp "$knockd_conf" "${knockd_conf}.backup"
  fi

  while [ "$approved" != "y" ]; do
    # Generate random numbers between 1 and 10 for sequences
    local open_ports=$(shuf -i 1-10 -n 1)
    local close_ports=$(shuf -i 1-10 -n 1)

    # Generate the sequences
    local open_sequence=$(generate_knock_sequence $open_ports)
    local close_sequence=$(generate_knock_sequence $close_ports)

    echo "Generated opening sequence: $open_sequence"
    echo "Generated closing sequence: $close_sequence"
    echo "Do you approve these sequences? (y/n)"
    read approved

    if [ "$approved" = "y" ]; then
      log_info "Séquences approuvées. Configuration de knockd en cours..."

      # Backup existing configuration if it exists
      [ -f "$knockd_conf" ] && cp "$knockd_conf" "${knockd_conf}.backup"

      # Writing new configuration
      {
        echo '[options]'
        echo "        interface = $interface"
        echo '        logfile = /var/log/knockd.log'
        echo
        echo '[openSSH]'
        echo "        sequence    = $open_sequence"
        echo '        seq_timeout = 5'
    echo "        command     = /sbin/iptables -C INPUT -s %IP% -p tcp --dport $ssh_port -j ACCEPT || /sbin/iptables -A INPUT -s %IP% -p tcp --dport $ssh_port -j ACCEPT"
        echo
        echo '[closeSSH]'
        echo "        sequence    = $close_sequence"
        echo '        seq_timeout = 5'
        echo "        command     = /sbin/iptables -D INPUT -s %IP% -p tcp --dport $ssh_port -j ACCEPT"
      } > "$knockd_conf"
    fi

  done

  while true; do
    # Log to launch knock for opening
    local open_sequence_no_commas=$(echo $open_sequence | tr ',' ' ')
    echo "To launch knock for opening: knock -d 10 -v <ip> $open_sequence_no_commas"

    # Log to launch knock for closing
    local close_sequence_no_commas=$(echo $close_sequence | tr ',' ' ')
    echo "To launch knock for closing: knock -d 10 -v <ip> $close_sequence_no_commas"

    # Ask if the user has copied the sequence into a file
    read -p "Have you copied the sequence into a file? (y/n): " answer
    if [[ $answer == "y" || $answer == "Y" ]]; then
      break
    fi
  done

  log_info "Port knocking configuration for knockd completed successfully."

  return "$OK"
}

generate_knock_sequence() {
  local length=$1
  local sequence=""
  local protocols=("tcp" "udp")  # List of protocols

  for i in $(seq 1 $length); do
    # Generate a random port
    local port=$(shuf -i 1024-65535 -n 1)
    # Randomly select a protocol
    local protocol=${protocols[$RANDOM % 2]}
    # Add the port and protocol to the sequence
    sequence+="${port}:${protocol}"
    [ $i -lt $length ] && sequence+=","
  done

  echo $sequence
}

### Post Actions for Knockd Configuration
#
# Function..........: post_actions_add_knockd
# Description.......: Ensures that the knockd service is correctly installed and configured. It checks if the knockd
#                     service is installed, enables it to start on system boot, and restarts it to apply any new
#                     configurations. This step is crucial for maintaining the operation of knockd across system
#                     reboots and configuration changes.
# Returns...........: 
#               - 0 (OK): If the knockd service is successfully restarted and enabled.
#               - 1 (NOK): If the knockd service is not installed, not active, or fails to restart.
#
##
post_actions_add_knockd() {

  local knockd_conf="/etc/knockd.conf"
  local knockd_service="knockd"

  log_info "Verifying knockd configuration."

  # Reload systemd manager configuration
  systemctl daemon-reload

  # Enable knockd service to start on boot
  if ! systemctl enable $knockd_service; then
    log_error "Failed to enable knockd service."
    return "$NOK"
  fi

  # Restart knockd service to apply any new configurations
  if ! systemctl restart $knockd_service; then
    log_error "Failed to restart knockd service."
    return "$NOK"
  fi

  log_info "knockd service is active and running."
  return "$OK"
}

# Run the task to add knockd
task_add_knockd
#-------------- tool_secure/aide.sh - mandatory

# shellcheck source=/dev/null

### Task for Installing and Configuring AIDE
#
# Function..........: task_add_aide
# Description.......: Installs and configures AIDE (Advanced Intrusion Detection Environment) on the system. AIDE is 
#                     a file integrity checker used to detect unauthorized changes to files. The task involves 
#                     executing a series of steps: checking prerequisites, performing the installation and initial 
#                     configuration of AIDE, and executing post-installation actions.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement, 
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If AIDE is successfully installed and configured.
#               - 1 (NOK): If the process fails at any point.
##
task_add_aide() {
  
  local name="add_aide"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "add_aide failed."
    return "$NOK"
  fi

  log_info "add_aide has been successfully add_aidex."
  
  return "$OK"
}

### Check Prerequisites for AIDE Installation
#
# Function..........: check_prerequisites_add_aide
# Description.......: Checks and ensures that the prerequisites for installing AIDE (Advanced Intrusion Detection 
#                     Environment) are met. This primarily involves the installation of the AIDE package. The function 
#                     uses an `install_package` utility to attempt the installation of AIDE.
# Parameters........: 
#               - None. The function directly checks for the presence of the AIDE package and attempts to install it.
# Returns...........: 
#               - 0 (OK): If the AIDE package is successfully installed or already present.
#               - 1 (NOK): If the installation fails.
##
check_prerequisites_add_aide() {
  # Install AIDE package
  if ! install_package "aide"; then
    return "$NOK"
  fi

  return "$OK"
}

### Run Action for AIDE Initialization
#
# Function..........: run_action_add_aide
# Description.......: Executes the initial setup of AIDE (Advanced Intrusion Detection Environment). This includes 
#                     initializing the AIDE database by running 'aideinit'. After initialization, it checks for the 
#                     creation of the new AIDE database file and moves it to the active database location.
# Parameters........: 
#               - None. The function executes the AIDE initialization process without additional parameters.
# Returns...........: 
#               - 0 (OK): If the AIDE database is successfully initialized and configured.
#               - 1 (NOK): If there is a failure in creating or setting up the AIDE database.
##
run_action_add_aide() {
  # Initialize AIDE database
  log_info "Configuring aide.conf..."
  
  echo "!/home/.*" >> /etc/aide/aide.conf
  echo "!/var/log/.*" >> /etc/aide/aide.conf
  

  log_info "Initializing AIDE database..."

  aide --config /etc/aide/aide.conf --init 

  if [ -f /var/lib/aide/aide.db.new ]; then
    cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    return "$OK"
  else
    log_error "Failed to create AIDE database."
    return "$NOK"
  fi
}

### Post-Installation Actions for AIDE
#
# Function..........: post_actions_add_aide
# Description.......: Performs post-installation actions for AIDE (Advanced Intrusion Detection Environment). 
#                     This includes running a manual AIDE check to verify the correct functioning of AIDE. The function
#                     logs the initiation of the check, executes the `aide --check` command, and then assesses the 
#                     outcome to ensure the integrity check completes successfully.
# Parameters........: 
#               - None. The function executes the AIDE check without additional parameters.
# Returns...........: 
#               - 0 (OK): If the AIDE check is completed successfully and verification passes.
#               - 1 (NOK): If the AIDE check fails, indicating a problem with the AIDE setup.
##
post_actions_add_aide() {
  # Run a manual AIDE check for verification purposes
  log_info "Running a manual AIDE check for verification..."
  aide --config /etc/aide/aide.conf --check

  # Check the exit status of the last command (AIDE check)
  if [ $? -eq 0 ]; then
    log_info "AIDE check completed successfully. Verification passed."
    return "$OK"
  else
    log_error "AIDE check failed. Verification did not pass."
    return "$NOK"
  fi
}

# Run the task to add_aide
task_add_aide

#-------------- tool_util/delete_unnecessary_tools.sh - optional

# shellcheck source=/dev/null

### Delete Unnecessary Tools
#
# Function..........: task_delete_unnecessary_tools
# Description.......: Executes a task to remove unnecessary tools from the system. 
#                     This is typically done to improve system security by reducing the 
#                     attack surface area. The task may include removing unused software, 
#                     services, or features that are not required for the system's operation.
#
# Returns...........: 
#               - 0 (OK): If the task is completed successfully.
#               - 1 (NOK): If the task fails.
#
##
task_delete_unnecessary_tools() {
  
  local name="delete_unnecessary_tools"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type="optional"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "xxxx failed."
    return "$NOK"
  fi

  log_info "xxxx has been successfully xxxxx."
  
  return "$OK"
}

### Run Action to Delete Unnecessary Tools
#
# Function..........: run_action_delete_unnecessary_tools
# Description.......: Executes the removal of specified unnecessary tools from the system. 
#                     This is aimed at enhancing system security by removing potentially 
#                     vulnerable or unused software.
#
# Parameters........: None
# Returns...........: 
#               - 0 (OK): If all specified packages are either successfully removed or were not installed.
#               - Non-zero value: If there's an error in removing any of the packages.
#
##
run_action_delete_unnecessary_tools() {

    # Define a list of unnecessary packages to be removed
    local packages=("telnet" "nis" "ntpdate")

    # Loop through each package and remove it if installed
    for pkg in "${packages[@]}"; do
        if dpkg -l "$pkg" | grep -qw "^ii"; then
            log_info "Removing $pkg..."
            apt-get -y --purge remove "$pkg" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                log_info "$pkg removed successfully."
            else
                log_error "Failed to remove $pkg."
            fi
        else
            log_info "$pkg is not installed or already removed."
        fi
    done

    return "$OK"
}

### Post-Action Checks for Deleting Unnecessary Tools
#
# Function..........: post_actions_delete_unnecessary_tools
# Description.......: Performs post-action checks to confirm the removal of unnecessary tools from the system.
#                     This function iterates through a predefined list of packages and verifies whether they
#                     have been successfully removed.
#
# Parameters........: None
# Returns...........: 
#               - 0 (OK): If all checks are completed successfully.
#               - Non-zero value: If any error occurs during the checks.
##
post_actions_delete_unnecessary_tools() {

    # Define a list of packages to check
    local packages=("telnet" "nis" "ntpdate")

    # Loop through each package and check if it has been removed
    for pkg in "${packages[@]}"; do
        if dpkg -l "$pkg" | grep -qw "^ii"; then
            log_warn "$pkg is not removed."
        else
            log_info "$pkg is removed."
        fi
    done

    return "$OK"
}

# Run the task to delete unnecessary tools
task_delete_unnecessary_tools
#-------------- tool_util/vim.sh - optional
# shellcheck source=/dev/null

### Install Vim Text Editor
#
# Function..........: task_add_vim
# Description.......: Installs the Vim text editor on the system. Vim is a highly configurable text editor built to 
#                     enable efficient text editing. It is an improved version of the vi editor distributed with most UNIX systems.
#                     This function checks for root privileges, executes the installation action, and handles any post-installation tasks.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If Vim is successfully installed.
#               - 1 (NOK): If the installation fails.
#
###
task_add_vim() {
  
  local name="add_vim"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type="optional"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Vim installation failed."
    return "$NOK"
  fi

  log_info "Vim has been successfully installed."
  
  return "$OK"
}

### Install Vim Editor
#
# Function..........: run_action_add_vim
# Description.......: Installs the Vim text editor. Vim is a highly configurable, powerful, and popular text editor 
#                     that is an improved version of the vi editor. This function calls install_package to 
#                     handle the installation process of Vim.
# Returns...........: 
#               - 0 (OK): If Vim is successfully installed.
#               - 1 (NOK): If the installation fails.
#
###
run_action_add_vim() {

# install vim package
  if ! install_package "vim"; then
    return "$NOK"
  fi
}

# Run the task to add vim
task_add_vim
#-------------- tool_util/docker-ce.sh - mandatory

# shellcheck source=/dev/null

### Task for Installing Docker Community Edition (CE)
#
# Function..........: task_add_docker-ce
# Description.......: Installs Docker CE on the system and performs post-installation actions to ensure that 
#                     Docker is properly configured and operational. This includes checking prerequisites, 
#                     installing Docker, adding a user to the Docker group for secure operation, and verifying 
#                     the installation with a test container.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement, 
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If Docker CE is successfully installed, configured, and verified.
#               - 1 (NOK): If the installation or configuration process fails at any point.
##
task_add_docker-ce() {
  
  local name="add_docker-ce"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "add_docker failed."
    return "$NOK"
  fi

  log_info "add_docker has been successfully add_dockerx."
  
  return "$OK"
}

### Check Prerequisites for Docker CE Installation
#
# Function..........: check_prerequisites_add_docker-ce
# Description.......: Prepares the system for Docker CE installation. This includes installing necessary 
#                     packages like apt-transport-https, ca-certificates, curl, and software-properties-common. 
#                     It also involves adding Docker's official GPG key, setting up the Docker repository, 
#                     updating the package database, and installing Docker CE.
# Parameters........: 
#               - None. The function handles all the steps necessary to prepare for Docker CE installation.
# Returns...........: 
#               - 0 (OK): If all prerequisites are successfully installed and configured, and Docker CE is 
#                          installed.
#               - 1 (NOK): If any step in the process fails, including package installation, repository setup, 
#                           or Docker CE installation.
##
check_prerequisites_add_docker-ce() {

  # install pwgen package
  if ! install_package "pwgen"; then
    return "$NOK"
  fi

  # install apt-transport-https package
  if ! install_package "apt-transport-https"; then
    return "$NOK"
  fi

  # install ca-certificates package
  if ! install_package "ca-certificates"; then
    return "$NOK"
  fi

  # install curl package
  if ! install_package "curl"; then
    return "$NOK"
  fi

  # install gnupg package
  if ! install_package "gnupg"; then
    return "$NOK"
  fi

  install -m 0755 -d /etc/apt/keyrings

  # Add Docker’s official GPG key
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \

  tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Update the package database
  log_info "Updating the package database..."
  if ! apt-get update; then
    log_error "Failed to update the package database."
    return "$NOK"
  fi

  # Install the latest version of Docker CE
  log_info "Installing Docker CE..."
  if ! install_package "docker-ce"; then
    log_error "Failed to install Docker CE."
    return "$NOK"
  fi

  return "$OK"
}

### Run Action for Docker CE Installation and Configuration
#
# Function..........: run_action_add_docker-ce
# Description.......: Secures the Docker installation by creating a new non-root user and adding them to the Docker 
#                     group. The function prompts for a new username and password, confirms the credentials with the user, 
#                     creates the new user with the provided credentials, and adds them to the Docker group. It also 
#                     ensures that the Docker group exists before adding the user to it.
# Parameters........: 
#               - None. The function uses interactive prompts to gather input for the new user's credentials.
# Returns...........: 
#               - 0 (OK): If a new user is successfully created and added to the Docker group.
#               - 1 (NOK): If any part of the process fails, such as user creation or adding the user to the Docker group.
##
run_action_add_docker-ce() {

  log_info "Securing the Docker installation..."

  local new_user
  local user_password
  local confirmation

  log_info "Adding a new user for Docker"

  # Ask for username approval and capture the returned username
  new_user=$(ask_for_username_approval)

  # Ask for password approval and capture the returned password
  user_password=$(ask_for_password_approval)

  while true; do
    
    # Is it safe to show credentials ? 
    echo "Please make sure you have recorded this information safely:"
    echo "Username: $new_user"
    echo "Password: $user_password"

    # Ask for confirmation
    read -p "Have you saved the username and password? (y/n): " confirmation
    if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then
      break
    else
      echo "Let's try again..."
    fi

  done

  # Create the user with the provided password
  log_info "Creating user $new_user..."
  # Use the useradd command to create the user without a password prompt
  adduser --gecos "" --disabled-password "$new_user"

  # Set the password for the user securely using chpasswd
  echo "$new_user:$user_password" | chpasswd

  # Add the new user to the Docker group
  # Create Docker user group, if not already exists
  if ! getent group docker > /dev/null; then
    groupadd docker
  fi

  # Add the confirmed or provided user to the Docker group
  if ! usermod -aG docker "$new_user"; then
    log_error "Failed to add $new_user to the Docker group."
    return "$NOK"
  fi

  log_info "User $new_user has been added to the Docker group successfully."

  return "$OK"
}

### Post-Installation Actions for Docker CE
#
# Function..........: post_actions_add_docker-ce
# Description.......: Verifies the Docker CE installation by running the 'hello-world' Docker container. This function 
#                     tests if Docker is correctly installed and operational by executing a simple, lightweight container. 
#                     The successful execution of the 'hello-world' container is a common method to confirm that Docker 
#                     can pull images from Docker Hub and run containers.
# Parameters........: 
#               - None. The function performs the verification without additional parameters.
# Returns...........: 
#               - 0 (OK): If the 'hello-world' container runs successfully, indicating a functional Docker setup.
#               - 1 (NOK): If the 'hello-world' container fails to run, suggesting an issue with the Docker installation.
##
post_actions_add_docker-ce() {

  log_info "Testing Docker installation with the hello-world image..."

  # Run the hello-world Docker container
  if ! docker run hello-world; then
    log_error "Failed to run the hello-world Docker container."
    return "$NOK"
  fi

  log_info "Docker hello-world container ran successfully. Docker is functioning correctly."

  return "$OK"
}

# Run the task to add_docker
task_add_docker-ce
#-------------- tool_util/net-tools.sh - mandatory
# shellcheck source=/dev/null

### Install Net-Tools
#
# Function..........: task_add_net-tools
# Description.......: Installs the net-tools package on the system. Net-tools includes important network utilities such as ifconfig, netstat, 
#                     route, and others. It's used for network troubleshooting and configuration. This function checks for root privileges, 
#                     executes the installation action, and handles any post-installation tasks.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If net-tools is successfully installed.
#               - 1 (NOK): If the installation fails.
#
###
task_add_net-tools() {
  
  local name="add_net-tools"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Net-tools installation failed."
    return "$NOK"
  fi

  log_info "Net-tools has been successfully installed."
  
  return "$OK"
}

### Install Net-Tools
#
# Function..........: run_action_add_net-tools
# Description.......: Installs the net-tools package. Net-tools includes a collection of programs for controlling and 
#                     monitoring network devices and traffic, such as ifconfig, netstat, route, and others. This function calls 
#                     install_package to handle the installation process of net-tools.
# Returns...........: 
#               - 0 (OK): If net-tools is successfully installed.
#               - 1 (NOK): If the installation fails.
#
###
run_action_add_net-tools() {

# install vim package
  if ! install_package "net-tools"; then
    return "$NOK"
  fi
}

# Run the task to add net_tools
task_add_net-tools
#-------------- scheduler/auto_update_upgrade.sh - mandatory
# shellcheck source=/dev/null

### Task for Setting Up Automatic System Update and Upgrade Scheduler
#
# Function..........: task_scheduler_auto_update_upgrade
# Description.......: Sets up a scheduler for automatically updating and upgrading the system at regular intervals. 
#                     This task automates the process of keeping the system up-to-date with the latest packages 
#                     and security updates.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement,
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If the scheduler is successfully set up.
#               - 1 (NOK): If setting up the scheduler fails.
#
###
task_sheduler_auto_update_upgrade() {

  local name="sheduler_auto_update_upgrade"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Failed to set up automatic update and upgrade scheduler."
    return "$NOK"
  fi

  log_info "Automatic update and upgrade scheduler successfully set up."
  
  return "$OK"
}

check_prerequisites_sheduler_auto_update_upgrade() {

  # install ssh package
  if ! install_package "unattended-upgrades"; then
    return "$NOK"
  fi

  return "$OK"
}

### Run Action to Configure Automatic System Update and Upgrade
#
# Function..........: run_action_scheduler_auto_update_upgrade
# Description.......: Configures the system to perform automatic updates and upgrades using unattended-upgrades. 
#                     This function first configures the necessary parameters in the unattended-upgrades 
#                     configuration file. It then sets up automatic update checks and enables automatic upgrades 
#                     by modifying the apt configuration. A backup of the original configuration files is created 
#                     before any changes are made. Additionally, the function performs a dry run to test the 
#                     configuration.
# Parameters........: None. The function uses predefined file paths and configurations.
# Returns...........: None directly. Outputs information about the configuration process and performs a dry run test.
#
###
run_action_sheduler_auto_update_upgrade() {

   # Create backup directory if it doesn't exist
    local backup_dir="/etc/apt/backup"
    if [ ! -d "$backup_dir" ]; then
        log_info "Creating backup directory at $backup_dir."
        mkdir -p "$backup_dir"
    fi

    # Configure unattended-upgrades
    log_info "Configuring automatic updates..."
    cp /etc/apt/apt.conf.d/50unattended-upgrades /etc/apt/backup/50unattended-upgrades.backup
    sed -i '/"${distro_id}:${distro_codename}-updates";/s/^\/\/ //' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i '/"${distro_id}:${distro_codename}-security";/s/^\/\/ //' /etc/apt/apt.conf.d/50unattended-upgrades

    # Enable automatic updates
    log_info "Activating automatic updates and upgrades..."
    cp /etc/apt/apt.conf.d/20auto-upgrades /etc/apt/backup/20auto-upgrades.backup
    echo 'APT::Periodic::Update-Package-Lists "1";' | tee -a /etc/apt/apt.conf.d/20auto-upgrades
    echo 'APT::Periodic::Unattended-Upgrade "1";' | tee -a /etc/apt/apt.conf.d/20auto-upgrades

    # Test the configuration
    log_debug "Testing the automatic update configuration..."
    unattended-upgrades --dry-run --debug &> /dev/null

    log_info "Configuration complete."
}

# Run the task to disable root account
task_sheduler_auto_update_upgrade
#-------------- scheduler/close_ssh_port.sh - mandatory

# shellcheck source=/dev/null

### Task for Closing SSH Port When Not in Use
#
# Function..........: task_close_ssh_port
# Description.......: Closes the SSH port if no active (ESTABLISHED) connections are found. 
#                     This task automates the process of enhancing security by closing unused SSH ports.
#                     It checks if the specified SSH port is in ESTABLISHED state, lists all iptables rules 
#                     for that port, and removes them if no active connections exist. The script is 
#                     scheduled to run every 5 minutes.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement, 
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If the SSH port is successfully closed or no action is needed.
#               - 1 (NOK): If the process of closing the SSH port fails.
#
###
task_close_ssh_port() {
  
  local name="close_ssh_port"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "close_ssh_port failed."
    return "$NOK"
  fi

  log_info "close_ssh_port has been successfully."
  
  return "$OK"
}

### Check Prerequisites for Closing SSH Port Task
#
# Function..........: check_prerequisites_close_ssh_port
# Description.......: Checks if the necessary prerequisites for the close_ssh_port task are met. 
#                     Currently, it checks if the Knock utility is installed on the system.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If all prerequisites are met.
#               - 1 (NOK): If any of the prerequisites are not met.
#
###
check_prerequisites_close_ssh_port() {

  # Check if Knock is installed
  if ! command -v knock >/dev/null 2>&1; then
    log_error "Knock is not installed. Please install Knock first."
    return "$NOK"
  fi

  return "$OK"
}

### Run Action for Closing SSH Port
#
# Function..........: run_action_close_ssh_port
# Description.......: Executes the necessary actions for setting up a script that closes the SSH port when 
#                     it is not in use. This includes creating and deploying the script, and setting up 
#                     a cron job to execute it periodically.
#                     The function checks if a log file exists and creates it if necessary, generates a new 
#                     script using create_close_ssh_port_script, sets the appropriate permissions, moves it to 
#                     /usr/local/sbin/, and schedules it in cron to run every 5 minutes.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If the script is successfully created, deployed, and scheduled.
#               - 1 (NOK): If any step in the process fails.
#
###
run_action_close_ssh_port() {

    local script_name="close_ssh_port.sh"
    local script_path="/usr/local/sbin/$script_name"
    local log_file="/var/log/close_ssh_port.log"

    # Check if the log file exists
    if [ ! -f "$log_file" ]; then
        touch "$log_file"
        chmod 600 "$log_file"
    fi

    # Create the script
    create_close_ssh_port_script "$script_name" "$log_file"

    # Make the script executable and move it
    chmod 700 "$script_name"
    chmod +x "$script_name"
    sudo mv "$script_name" "$script_path"

    # Add the cron task
    (crontab -l 2>/dev/null; echo "*/5 * * * * $script_path") | crontab -

    return "$OK"
}

### Create Script for Closing SSH Port
#
# Function..........: create_close_ssh_port_script
# Description.......: Generates a bash script that closes the SSH port if no ESTABLISHED connections are found. 
#                     The script checks the specified SSH port in the sshd_config file, lists all iptables rules 
#                     for that port, and removes them if no ESTABLISHED connections are detected. The function 
#                     writes the script to a specified file and logs the creation.
# Parameters........: 
#               - script_name: The name of the file where the script will be written.
#               - log_file: The file where log entries will be written.
# Returns...........: 
#               - No return value. The result is a created script file.
#
###
create_close_ssh_port_script() {

    local script_name="$1"
    local log_file="$2"

    # build script
    echo '#!/bin/bash' > "$script_name"
    cat >> "$script_name" <<EOF

sshd_conf="/etc/ssh/sshd_config"
PORT=\$(grep "^Port " "\$sshd_conf" | cut -d ' ' -f2)
IPTABLES=\$(which iptables)
NETSTAT=\$(which netstat)

# Check if the port is not in ESTABLISHED state
if ! \$NETSTAT -tna | grep ":\$PORT " | grep 'ESTABLISHED'; then

    # List the iptables rules for the specified port
    readarray -t rules < <(sudo \$IPTABLES -L INPUT -n --line-numbers | grep "tcp dpt:\$PORT" | awk '{print \$1}')

    # Remove the rules in reverse order
    for (( idx=\${#rules[@]}-1 ; idx>=0 ; idx-- )) ; do
        rule_number=\${rules[idx]}
        \$IPTABLES -D INPUT \$rule_number
        echo "\$(date) : Rule for port \$PORT removed, rule number \$rule_number" >> "$log_file"
    done

fi
EOF

    log_info "Script $script_name created."
}

# Run the task to close_ssh_port
task_close_ssh_port
#-------------- scheduler/aide_report_mail.sh - mandatory

# shellcheck source=/dev/null

task_aide_report_mail() {
  
  local name="aide_report_mail"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "aide_report_mail failed."
    return "$NOK"
  fi

  log_info "aide_report_mail has been successfully aide_report_mailx."
  
  return "$OK"
}

check_prerequisites_aide_report_mail() {

  # Check if AIDE is installed
  if ! command -v aide >/dev/null 2>&1; then
    log_error "AIDE is not installed. Please install AIDE first."
    return "$NOK"
  fi

  # Check if the system can send emails
  if ! command -v mail >/dev/null 2>&1; then
    log_error "Mail command is not available. Please install mailutils or a similar package."
    return "$NOK"
  fi

  return "$OK"
}

run_action_aide_report_mail() {

  local report_email

  # Ask for the email address and validate it
  while true; do
    read -p "Enter the email address for AIDE reports: " report_email

    # Basic email validation using regex
    if [[ "$report_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
      log_info "Email address validated."
      break
    else
      log_error "Invalid email address. Please enter a valid email."
    fi
  done

  # Add a new cron job for daily AIDE checks
  log_info "Adding a cron job for daily AIDE checks..."

  # Create a new cron job entry that checks for changes and sends an email if changes are detected
  local cron_job="0 0 * * * /usr/bin/aide --config /etc/aide/aide.conf --check | grep -q 'changed' && echo '$(date '+\%Y-\%m-\%d') - Changes detected by AIDE' | mail -s 'AIDE Report' $report_email"

  # Add the cron job to the crontab
  (crontab -l 2>/dev/null; echo "$cron_job") | crontab -

  # Check if the cron job was added successfully
  if crontab -l | grep -Fq "$cron_job"; then
    log_info "Cron job for daily AIDE checks added successfully."
    return "$OK"
  else
    log_error "Failed to add cron job for daily AIDE checks."
    return "$NOK"
  fi
  
}

# Run the task to aide_report_mail
task_aide_report_mail

#-------------- network/ssh_deactivate_root.sh - mandatory

# shellcheck source=/dev/null

### Task to Deactivate Root SSH Login
#
# Function..........: task_ssh_deactivate_root
# Description.......: Executes a series of steps to deactivate root SSH login. The function checks prerequisites, 
#                     executes the main action to modify SSH settings, and performs any necessary post-actions. 
#                     This task is crucial for enhancing the security of the SSH service.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement, 
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If all steps are successfully executed.
#               - 1 (NOK): If any step in the process fails.
#
###
task_ssh_deactivate_root() {

  # Deactivate root SSH login
  local name="ssh_deactivate_root"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "SSH root deactivation failed."
    return "$NOK"
  fi

  log_info "Root SSH login has been successfully deactivated."
  
  return "$OK"
}

### Check Prerequisites for Deactivating Root SSH
#
# Function..........: check_prerequisites_ssh_deactivate_root
# Description.......: Ensures that all prerequisites for deactivating root SSH login are met. This function primarily 
#                     checks for the installation of the SSH package and installs it if not already present.
# Returns...........: 
#               - 0 (OK): If the SSH package is installed or successfully installed.
#               - 1 (NOK): If the installation of the SSH package fails.
#
##
check_prerequisites_ssh_deactivate_root() {

  # install ssh package
  if ! install_package "ssh"; then
    return "$NOK"
  fi

  return "$OK"
}

### Run Action to Deactivate Root SSH Login
#
# Function..........: run_action_ssh_deactivate_root
# Description.......: Modifies the SSH daemon configuration to deactivate root login. It checks the current 
#                     setting of 'PermitRootLogin' in the sshd_config file. If it's set to 'yes', the function 
#                     changes it to 'no'. If the setting is absent or set to any other value, it adds 'PermitRootLogin no'.
#                     After modifying the configuration, it restarts the SSH service to apply changes.
# Parameters........: None. Relies on global variables such as 'sshd_config'.
# Returns...........: The return status of the 'execute_task' function, which executes the actions and configurations.
#
##
run_action_ssh_deactivate_root() {

  local sshd_config="/etc/ssh/sshd_config"

  log_info "Checking SSH configuration for PermitRootLogin setting."

  # Check if PermitRootLogin is set to 'no' or 'yes'
  if grep -q "^PermitRootLogin no" "$sshd_config"; then
      log_info "PermitRootLogin is already set to 'no'. No changes needed."
  elif grep -q "^PermitRootLogin yes" "$sshd_config"; then
      log_info "PermitRootLogin set to 'yes'. Changing to 'no'."
      # If it exists and is set to 'yes', replace it with 'no'
      sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' "$sshd_config"
  else
      log_info "PermitRootLogin is not set. Adding 'PermitRootLogin no'."
      # If 'PermitRootLogin' is not set to either 'yes' or 'no', add 'PermitRootLogin no' to the file
      echo 'PermitRootLogin no' | tee -a "$sshd_config"
  fi

  return "$OK"
}

### Post Actions for Deactivating Root SSH
#
# Function..........: post_actions_ssh_deactivate_root
# Description.......: Performs post-action tasks after modifying SSH configuration to deactivate root login.
#                     This primarily involves restarting the SSH service to apply the changes made to the configuration.
#                     It checks if the SSH service is active and then attempts to restart it.
# Returns...........: 
#               - 0 (OK): If the SSH service is successfully restarted.
#               - 1 (NOK): If the SSH service is not active or fails to restart.
#
##
post_actions_ssh_deactivate_root() {
  log_info "Restarting SSH service to apply changes."

  # Using systemctl to restart the SSH service
  if systemctl is-active --quiet ssh; then

    systemctl restart sshd

    if [ $? -eq 0 ]; then
      log_info "SSH service restarted successfully."
      
    else
      log_error "Failed to restart SSH service."
      return "$NOK"

    fi

  else
    log_error "SSH service is not active."
    return "$NOK"

  fi

  return "$OK"
}


# Run the task to deactivate root SSH login
task_ssh_deactivate_root
#-------------- system/disable_root.sh - mandatory

# shellcheck source=/dev/null

### Task for Disabling Root System Login
#
# Function..........: task_system_disable_root
# Description.......: Executes the process of disabling the root system login. This is done by executing
#                     a series of actions defined in the 'run_action_system_disable_root' function. 
#                     It ensures that root login is securely disabled to enhance system security.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement,
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If disabling root system login is successful.
#               - 1 (NOK): If the process fails.
#
###
task_system_disable_root() {

  local name="system_disable_root"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "System root login deactivation failed."
    return "$NOK"
  fi

  log_info "System root login has been successfully deactivated."
  
  return "$OK"
}

### Prerequisite Check for Disabling Root System Login
#
# Function..........: prerequisite_system_disable_root
# Description.......: Checks if there is at least one user with sudo privileges on the system. If no sudoers 
#                     are found, it prompts the user for confirmation before proceeding to disable the root 
#                     account. This is a safety measure to avoid locking out of administrative access.
# Returns...........: 
#               - 0 (OK): If there is at least one sudoer or the user confirms to proceed without a sudoer.
#               - 1 (NOK): If there are no sudoers and the user chooses not to proceed.
#
###
prerequisite_system_disable_root() {

    local sudoers_count

    sudoers_count=$(getent group sudo | cut -d: -f4 | tr ',' ' ' | wc -w)

    if [[ $sudoers_count -eq 0 ]]; then
        log_error "No users with sudo privileges found. Disabling root may lock out administrative access."
        return "$NOK"
    fi

    log_info "Sudoers available. Safe to proceed with root deactivation."

    return "$OK"
}


### Run Action to Disable Root System Login
#
# Function..........: run_action_system_disable_root
# Description.......: Disables the root system login by changing the root password to a random, 
#                     securely generated string. This enhances system security by making the root 
#                     account inaccessible via traditional login methods. The function uses OpenSSL 
#                     to generate a random base64-encoded password.
# Returns...........: None directly. Outputs to stdout and logs information upon successful completion.
#
###
run_action_system_disable_root() {

  log_info "Generating a random password for root and locking the account."

  # Generate a random password
  random_password=$(openssl rand -base64 48 | tr -d '\n')

  # Hash the password using SHA-256
  hashed_password=$(echo -n "$random_password" | sha256sum | awk '{print $1}')

  # Set the root password to the hashed value
  echo "root:$hashed_password" | chpasswd -e

  # Lock the root account
  passwd -l root >/dev/null 2>&1
  sed -i '/^root:/s#:/bin/bash#:/usr/sbin/nologin#' /etc/passwd

  log_info "Root account has been secured and direct login disabled."
  
  return "$OK"
}

# Run the task to disable root account
task_system_disable_root
#-------------- tool_report/chkrootkit.sh - mandatory

# shellcheck source=/dev/null

### Task for Installing and Running chkrootkit
#
# Function..........: task_add_chkrootkit
# Description.......: Performs the task of installing and running chkrootkit on the system. chkrootkit is a tool 
#                     that scans for rootkits, backdoors, and possible local exploits. This task involves checking 
#                     prerequisites, executing the chkrootkit scan, and performing any necessary post-actions.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement,
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If chkrootkit is successfully executed.
#               - 1 (NOK): If the process fails at any point.
##
task_add_chkrootkit() {
  
  local name="add_chkrootkit"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "chkrootkit failed."
    return "$NOK"
  fi

  log_info "chkrootkit has been successfully chkrootkitx."
  
  return "$OK"
}

### Check Prerequisites for chkrootkit Installation
#
# Function..........: check_prerequisites_add_chkrootkit
# Description.......: Checks and ensures that the prerequisites for installing chkrootkit are met. This primarily 
#                     involves the installation of the chkrootkit package. The function uses an `install_package` 
#                     utility to attempt installation.
# Parameters........: 
#               - None. The function directly checks for the presence of the chkrootkit package and attempts to install it.
# Returns...........: 
#               - 0 (OK): If the chkrootkit package is successfully installed or already present.
#               - 1 (NOK): If the installation fails.
##
check_prerequisites_add_chkrootkit() {
  # install chkrootkit package
  if ! install_package "chkrootkit"; then
    return "$NOK"
  fi

  return "$OK"
}

### Run Action for chkrootkit
#
# Function..........: run_action_add_chkrootkit
# Description.......: Executes the chkrootkit scan. This function is responsible for actually running the chkrootkit 
#                     tool, which scans the system for known rootkits, backdoors, and potentially harmful local exploits.
#                     The function logs the initiation of the scan and then executes the chkrootkit command.
# Parameters........: 
#               - None. The function directly executes the chkrootkit scan without any additional parameters.
# Returns...........: 
#               - 0 (OK): Always returns OK as it does not check the outcome of the chkrootkit scan.
##
run_action_add_chkrootkit() {
  # Run chkrootkit scan
  log_info "Running chkrootkit scan..."
  chkrootkit

  return "$OK"
}

### Post Actions for chkrootkit
#
# Function..........: post_actions_add_chkrootkit
# Description.......: Configures the chkrootkit to run daily checks. This function modifies the chkrootkit configuration 
#                     file to enable automated daily scans. It uses the `sed` command to change the configuration setting 
#                     `RUN_DAILY` from "false" to "true" in the `/etc/chkrootkit.conf` file. It then verifies if the change 
#                     was successful.
# Parameters........: 
#               - None. The function operates directly on the chkrootkit configuration file.
# Returns...........: 
#               - 0 (OK): If the daily chkrootkit check is successfully enabled.
#               - 1 (NOK): If the process of enabling the daily check fails.
##
post_actions_add_chkrootkit() {
  # Edit chkrootkit configuration to enable daily runs
  sed -i 's/RUN_DAILY="false"/RUN_DAILY="true"/' /etc/chkrootkit/chkrootkit.conf

  if grep -q 'RUN_DAILY="true"' /etc/chkrootkit/chkrootkit.conf; then
    log_info "Daily chkrootkit check has been enabled."
    return "$OK"
  else
    log_error "Failed to enable daily chkrootkit check."
    return "$NOK"
  fi

  return "$OK"
}

# Run the task to chkrootkit
task_add_chkrootkit

#-------------- tool_report/lynis.sh - mandatory

# shellcheck source=/dev/null

### Task for Installing and Configuring Lynis
#
# Function..........: task_add_lynis
# Description.......: Installs and configures Lynis, a security auditing tool, on the system. Lynis is used for 
#                     performing security checks, system audits, and compliance testing. The task involves executing 
#                     a series of steps: checking prerequisites, installing Lynis, and optionally running post-installation 
#                     actions.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement, 
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If Lynis is successfully installed and configured.
#               - 1 (NOK): If the installation or configuration process fails at any point.
##
task_add_lynis() {
  
  local name="add_lynis"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type="mandatory"

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "add_lynis failed."
    return "$NOK"
  fi

  log_info "add_lynis has been successfully add_lynisx."
  
  return "$OK"
}

### Check Prerequisites for Lynis Installation
#
# Function..........: check_prerequisites_add_lynis
# Description.......: Checks and ensures that the prerequisites for installing Lynis are met. This primarily 
#                     involves the installation of the Lynis package. The function uses an `install_package` 
#                     utility to attempt the installation of Lynis.
# Parameters........: 
#               - None. The function directly checks for the presence of the Lynis package and attempts to install it.
# Returns...........: 
#               - 0 (OK): If the Lynis package is successfully installed or already present.
#               - 1 (NOK): If the installation fails.
##
check_prerequisites_add_lynis() {
  # Install Lynis
  if ! install_package "lynis"; then
    log_error "Failed to install Lynis."
    return "$NOK"
  fi
  
  return "$OK"
}

### Run Action for Lynis Audit
#
# Function..........: run_action_add_lynis
# Description.......: Executes the Lynis audit process. This function is responsible for running the Lynis 
#                     command to perform a system-wide audit. It logs the initiation of the audit, executes the 
#                     `lynis audit system` command, and then assesses the outcome to ensure the audit completes 
#                     successfully.
# Parameters........: 
#               - None. The function executes the Lynis audit without additional parameters.
# Returns...........: 
#               - 0 (OK): If the Lynis audit is completed successfully.
#               - 1 (NOK): If there is a failure in the Lynis audit process.
##
run_action_add_lynis() {
  log_info "Running system audit..."

  # Run Lynis audit
  lynis audit system

  # Check the exit status of the Lynis command
  if [ $? -eq 0 ]; then
    log_info "Lynis audit completed successfully."
  else
    log_error "Lynis audit encountered issues."
    return "$NOK"
  fi

  return "$OK"
}

# Run the task to add_lynis
task_add_lynis
