#!/bin/bash

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
# Function..........: log_log_post_actionsconfiguration
# Description.......: Logs a post actions message with light pink color.
# Parameters........: 
#              - $1: Message to log.
#
###
log_post_actions() {
  echo -e "${LOG_COLOR_CONFIG}[POST ACTIONS]: $1${LOG_COLOR_END}" >&2
}
