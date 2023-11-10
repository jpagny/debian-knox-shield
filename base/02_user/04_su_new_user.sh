#!/bin/bash

# import
source "$(dirname "$0")/../core/execute_task.sh"
source "$(dirname "$0")/../core/logger.sh"

# Command to run as the new user
command_to_run_as_new_user="echo 'Running as new user...'"

### Run with new user
#
# Description....: Runs a specified command as the new user.
# Parameters.....: None
# Returns........: None
#
task_run_with_new_user() {

  # You'll need to know the username, which you can pass as an argument or source from a file
  username=$(cat /tmp/user_credentials.txt | grep Username | cut -d ' ' -f 2)

  local name="Run command as new user"
  local isRootRequired=true
  local prereq=""
  local actions="su - $username -c \"$command_to_run_as_new_user\""
  local configs=""

  execute_task "$prereq" "$name" "$actions" "$configs"

  if ! execute_task "$name" $isRootRequired "$prereq" "$actions" "$configs"; then
    log_error "Failed to switch as the new user."
    return 1
  fi

  log_info "Successfully switched to the new user."
  return 0
}

# Run the function to execute a command run with new user
task_run_with_new_user
