#!/bin/bash

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

### Debug log
#
# Function..........: log_debug
# Description.......: Logs a debug message with cyan color.
# Parameters........: 
#               - $1: Message to log.
#
###
log_debug() {
  if [ "$DEBUG_MODE" -eq 1 ]; then
    echo -e "${LOG_COLOR_DEBUG}     [debug]: $1${LOG_COLOR_END}" >&2
  fi
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
  echo -e "${LOG_COLOR_INFO}    [info]: $1${LOG_COLOR_END}" >&2
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
  echo -e "${LOG_COLOR_WARN}    [warn]: $1${LOG_COLOR_END}" >&2
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
  echo -e "${LOG_COLOR_ERROR}     [error]: $1${LOG_COLOR_END}" >&2
}

### Task log
#
# Function..........: log_task
# Description.......: Logs a task message with magenta color.
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
# Description.......: Logs a prerequisite message with yellow color.
# Parameters........: 
#              - $1: Message to log.
#
###
log_prerequisite() {
  echo -e "${LOG_COLOR_PREREQUISITE}  [PREREQUISITE]: $1${LOG_COLOR_END}" >&2
}

### Action log
#
# Function..........: log_action
# Description.......: Logs an action message with yellow color.
# Parameters........: 
#              - $1: Message to log.
#
###
log_action() {
  echo -e "${LOG_COLOR_ACTION}  [ACTION]: $1${LOG_COLOR_END}" >&2
}

### Post action log
#
# Function..........: log_log_post_actionsconfiguration
# Description.......: Logs a post actions message with yellow color.
# Parameters........: 
#              - $1: Message to log.
#
###
log_post_actions() {
  echo -e "${LOG_COLOR_POST_ACTION}  [POST ACTIONS]: $1${LOG_COLOR_END}" >&2
}
