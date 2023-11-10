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
