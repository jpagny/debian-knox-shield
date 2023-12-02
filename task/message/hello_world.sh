#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

task_hello_world() {
  
  local name="hello_world"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "hello_world failed."
    return "$NOK"
  fi

  log_info "hello_world has been successfully hello_worldx."
  
  return "$OK"
}

check_prerequisites_hello_world() {
    return "$OK"
}

run_action_hello_world() {
    return "$OK"
}

post_actions_hello_world() {
    return "$OK"
}

# Run the task to hello_world
task_hello_world
