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

  log_task "$name"

  # 01 - Check if Task Previously Succeeded
  if check_task_failed_previously "$task_name"; then
    echo "La tâche $task_name a déjà réussi précédemment. Elle est sautée."
    return $OK
  fi

  # 02 - Check for root privileges if required
  if [[ "$require_root" == "true" ]]; then
    if ! verify_has_root_privileges; then
      log_error "Root privileges required for $task_name."
      return $NOK
    fi
  fi

  # 03 - Execute the prerequisite if provided
  if [ -n "$prereq" ]; then

    log_prerequisite "Executing prerequisites for $task_name..."
    
    if eval "$prereq"; then
      log_info "Prerequisites completed"
    else
      log_error "Prerequisites failed"
      return $NOK  # Stop the procedure if the prerequisite fails
    fi  

  fi

  # 04 - Execute the actions
  log_action "Executing actions for $task_name..."

  if eval "$actions"; then
    log_info "Actions completed"
  else
    log_error "Actions failed"
    return $NOK  # Optionally stop also if actions fail
  fi

  # 05 - Execute the post action
  if [ -n "$postActions" ]; then  # Check if 'postActions' variable is not empty

      log_post_actions "Executing post actions for $task_name..."

      if ! eval "$postActions"; then
          log_error "Post actions failed"
          return $NOK  # Stop the script if post actions fails
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

  execute_task "$task_name" $require_root "$prereq" "$actions" "$postActions"
  local status=$?

  if [$status -ne $OK ]; then

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

  return $OK
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
    return $NOK
}

### Mark Task as Successful
#
# Function..........: mark_task_ok
# Description.......: Marks a specified task as successful ('ok') in the STATUS_FILE. 
#                     If an entry for the task with a 'ko' status exists, it updates 
#                     the entry to 'ok'. If no such entry exists, it adds a new 'ok' 
#                     status entry for the task.
# Parameters........: 
#               - $1: The name of the task to be marked as successful.
# Returns...........: None.
# Side Effects......: Modifies the STATUS_FILE by updating or adding the status of the task.
#                     If the task had a 'ko' status, it is changed to 'ok'. If the task was 
#                     not previously listed, it is added with an 'ok' status.
###
mark_task_ok() {
  
    local task_name=$1

    if grep -q "^$task_name:ko$" "$STATUS_FILE"; then
      sed -i "/^$task_name:ko$/c\\$task_name:ok" "$STATUS_FILE"
    else
      echo "$task_name:ok" >> "$STATUS_FILE"
    fi
}

### Mark Task as Failed
#
# Function..........: mark_task_ko
# Description.......: Marks a specified task as failed ('ko') in the STATUS_FILE.
#                     Adds a new 'ko' status entry for the task. This function does not 
#                     check for existing entries of the task, it simply appends the failed 
#                     status to the file. 
# Parameters........: 
#               - $1: The name of the task to be marked as failed.
# Returns...........: None.
# Side Effects......: Modifies the STATUS_FILE by appending the status of the task.
#                     If the task was previously marked as successful ('ok') or failed ('ko'), 
#                     this function adds an additional 'ko' entry without modifying or 
#                     removing the existing entries.
###
mark_task_ko() {
    local task_name=$1
    echo "$task_name:ko" >> "$STATUS_FILE"
}


#-------------- 03_utils.sh


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
        return $NOK
    fi

    return $OK
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
    return $NOK
  fi

  if ! command -v $package &> /dev/null; then
    log_info "$package is not installed. Installing..."

    if apt-get update &> /dev/null && apt-get install -y $package &> /dev/null; then
      log_info "$package has been installed successfully."
      return $OK
    else
      log_error "Failed to install $package."
      return $NOK
    fi
  else
    log_info "$package is already installed."
    return $OK
  fi
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


#-------------- system/update_and_upgrade.sh - mandatory


### Execute and Check Task
#
# Function..........: execute_and_check
# Description.......: Executes a specified task and checks its completion status. It marks the task as failed 
#                     using 'mark_task_ko' if it does not complete successfully. If the task is marked as 
#                     'mandatory' and fails, the script terminates with an error message. If the task is marked 
#                     as 'optional' and fails, a warning is logged, and the script continues with a non-zero status.
# Parameters........: 
#               - $1: Task name.
#               - $2: Root requirement (true/false).
#               - $3: Prerequisites command or function.
#               - $4: Actions to perform in the task.
#               - $5: Post-actions to perform after the main actions.
#               - $6: Task type ('mandatory' or 'optional').
# Returns...........: 
#               - 0 (OK): If the task is successfully completed.
#               - 1 (NOK): If the task fails and is 'optional'.
#               - Exits the script: If the task fails and is 'mandatory'.
# Usage.............: This function should be used to execute tasks with a specific requirement on the outcome. 
#                     Use 'mandatory' for critical tasks whose failure should stop the script, and 'optional' for 
#                     tasks where failure does not impede the continuation of the script.
#
###
task_update_and_upgrade() {

    local name="System update && upgrade"
    local isRootRequired=true
    local prereq=""
    local actions="apt-get update &> /dev/null && apt-get upgrade -y &> /dev/null" 
    local postActions=""
    local task_type="mandatory"

    if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
        log_error "System upgrade failed."
        return $NOK
    fi

    log_info "System update and upgrade completed successfully."
    return $OK
}

# Run the update and upgrade function
task_update_and_upgrade
#-------------- user/add_user_sudo.sh - mandatory


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
  local task_type="mandatory"


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