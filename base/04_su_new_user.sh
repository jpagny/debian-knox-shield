#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

# You'll need to know the username, which you can pass as an argument or source from a file
username=$(cat /tmp/user_credentials.txt | grep Username | cut -d ' ' -f 2)

# Command to run as the new user
command_to_run_as_new_user="echo 'Running as new user...'"

# Function to run a command as the new user
run_as_new_user() {
  local prereq="Switching to new user"
  local name="Run command as new user"
  local actions="su - $username -c \"$command_to_run_as_new_user\""

  execute_task "$prereq" "$name" "$actions" ""
}

# Run the function to execute a command as the new user
run_as_new_user
