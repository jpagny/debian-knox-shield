#!/bin/bash

# import
# shellcheck source=/dev/null
source "00_variable_global.sh"
source "01_logger.sh"

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
