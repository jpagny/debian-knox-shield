#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

task_test2() {
  
  local name="test2"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "test2 failed."
    return "$NOK"
  fi

  log_info "test2 has been successfully test2x."
  
  return "$OK"
}


run_action_test2() {
    return "$OK"
}


# Run the task to test2
task_test2
