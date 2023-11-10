#!/bin/bash

# import
source "logger.sh"
source "utils.sh"

### Execute Task Function
#
# Function..........: execute_task
# Description.......: Executes a task with optional prerequisites and configurations. Validates each step and handles errors.
# Parameters........: 
#              - $1: Name of the task.
#              - $2: Boolean indicating if root privileges are required.
#              - $3: Command string for prerequisites.
#              - $4: Command string for the main actions.
#              - $5: Command string for configurations.
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
  local configs="$5"

  log_info "### Name: $name"

  # 01 - Check for root privileges if required
  if [[ "$require_root" == "true" ]]; then
    if ! verify_root_privileges; then
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

  # 04 - Execute the configurations
  if [ -n "$configs" ]; then  # Check if 'configs' variable is not empty

      log_config "Executing configurations for $name..."

      if ! eval "$configs"; then
          log_error "Configurations failed"
          return 1  # Stop the script if configuration fails
      else
          log_info "Configurations completed successfully"
      fi

  fi

  log_info "Task $name execution completed successfully"
}



# import

### Execute scripts in directory
#
# Function..........: execute_scripts_in_directory
# Description.......: Executes all executable .sh scripts in a specified directory and its subdirectories, in order.
# Parameters........: 
#              - $1: The path of the directory containing the scripts to execute.
# Output............: Logs information about script execution progress and any errors encountered.
#
###
execute_scripts_in_directory() {

    local directory_path="$1"
    local directory_name="$(basename "$directory_path")"

    log_info "Executing scripts in the $directory_name directory and its subdirectories in order..."

    find "$directory_path" -type f -name "*.sh" -print0 | sort -z | while IFS= read -r -d '' script; do

        local relative_script_path="${script#$directory_path/}"

        if [[ -x "$script" ]]; then
            log_info "Running $relative_script_path..."
            "$script" || log_error "Failed to execute $relative_script_path."
        else
            log_error "$relative_script_path is not executable or not found."
        fi

    done
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
# Function..........: log_configuration
# Description.......: Logs a configuration message with light pink color.
# Parameters........: 
#              - $1: Message to log.
#
###
log_configuration() {
  echo -e "${LOG_COLOR_CONFIG}[CONFIG]: $1${LOG_COLOR_END}" >&2
}



# import

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

