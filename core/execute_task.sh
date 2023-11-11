#!/bin/bash

# import
source "logger.sh"
source "utils.sh"

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
