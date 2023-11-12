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

### Log Debug Message
#
# Function..........: log_debug
# Description.......: Logs a debug message if the DEBUG_MODE is enabled. The message is 
#                     printed in the color specified by LOG_COLOR_DEBUG. The function is 
#                     intended for use in scripts where conditional logging based on a debug 
#                     mode is required.
# Parameters........: 
#               - $1: The debug message to be logged.
# Side Effects......: Outputs a message to standard error (stderr) if DEBUG_MODE is set to 1.
#                     The message is colored based on the LOG_COLOR_DEBUG variable.
#
###
log_debug() {
  if [ "$DEBUG_MODE" -eq 1 ]; then
    echo -e "${LOG_COLOR_DEBUG}     [debug]: $1${LOG_COLOR_END}" >&2
  fi
}

### Log Information Message
#
# Function..........: log_info
# Description.......: Outputs an information message, prefixed with '[info]'. The message 
#                     is displayed in the color specified by LOG_COLOR_INFO. This function 
#                     is used for general informational logging within the script.
# Parameters........: 
#               - $1: The informational message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and an '[info]' prefix.
#
###
log_info() {
  echo -e "${LOG_COLOR_INFO}    [info]: $1${LOG_COLOR_END}" >&2
}

### Log Warning Message
#
# Function..........: log_warn
# Description.......: Outputs a warning message, prefixed with '[warn]'. The message 
#                     is displayed in the color specified by LOG_COLOR_WARN. This function 
#                     is used for logging warnings within the script, indicating potential 
#                     issues or important notices that are not critical errors.
# Parameters........: 
#               - $1: The warning message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and a '[warn]' prefix. The output is intended to draw 
#                     attention to potential issues or important information.
#
###
log_warn() {
  echo -e "${LOG_COLOR_WARN}    [warn]: $1${LOG_COLOR_END}" >&2
}

### Log Error Message
#
# Function..........: log_error
# Description.......: Outputs an error message, prefixed with '[error]'. The message 
#                     is displayed in the color specified by LOG_COLOR_ERROR. This function 
#                     is used for logging error messages within the script, indicating 
#                     issues or problems that need immediate attention or that have caused 
#                     a failure in the script's execution.
# Parameters........: 
#               - $1: The error message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and an '[error]' prefix. The output is intended to 
#                     highlight errors or critical problems in the script.
#
###
log_error() {
  echo -e "${LOG_COLOR_ERROR}     [error]: $1${LOG_COLOR_END}" >&2
}

### Log Task Message
#
# Function..........: log_task
# Description.......: Outputs a task message, prefixed with '[TASK]'. The message is 
#                     displayed in the color specified by LOG_COLOR_TASK. This function is 
#                     used for logging task-related messages within the script, providing a 
#                     clear indication of task executions or updates.
# Parameters........: 
#               - $1: The task message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and a '[TASK]' prefix. The output is intended to 
#                     highlight task-related activities or statuses in the script.
#
###
log_task() {
  echo -e "${LOG_COLOR_TASK}[TASK]: $1${LOG_COLOR_END}" >&2
}

### Log Prerequisite Message
#
# Function..........: log_prerequisite
# Description.......: Outputs a prerequisite message, prefixed with '[PREREQUISITE]'. The message 
#                     is displayed in the color specified by LOG_COLOR_PREREQUISITE. This function 
#                     is used for logging messages related to prerequisites within the script, 
#                     highlighting essential setup steps or requirements.
# Parameters........: 
#               - $1: The prerequisite message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and a '[PREREQUISITE]' prefix. The output is intended to 
#                     emphasize prerequisites or initial setup requirements in the script.
#
###
log_prerequisite() {
  echo -e "${LOG_COLOR_PREREQUISITE}  [PREREQUISITE]: $1${LOG_COLOR_END}" >&2
}

### Log Action Message
#
# Function..........: log_action
# Description.......: Outputs an action message, prefixed with '[ACTION]'. The message 
#                     is displayed in the color specified by LOG_COLOR_ACTION. This function 
#                     is used for logging messages related to specific actions taken or 
#                     to be taken within the script, aiding in tracking the script's operations.
# Parameters........: 
#               - $1: The action message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and an '[ACTION]' prefix. The output is intended to 
#                     highlight significant actions or steps in the script's execution.
#
###
log_action() {
  echo -e "${LOG_COLOR_ACTION}  [ACTION]: $1${LOG_COLOR_END}" >&2
}

### Log Post Action Message
#
# Function..........: log_post_actions
# Description.......: Outputs a post-action message, prefixed with '[POST ACTIONS]'. The message 
#                     is displayed in the color specified by LOG_COLOR_POST_ACTION. This function 
#                     is used for logging messages related to actions taken after the main 
#                     processing of the script, such as cleanup steps, summaries, or final status 
#                     updates.
# Parameters........: 
#               - $1: The post-action message to be logged.
# Side Effects......: Outputs the provided message to standard error (stderr), formatted 
#                     with a color and a '[POST ACTIONS]' prefix. The output is intended to 
#                     highlight actions or steps taken after the main execution of the script.
#
###
log_post_actions() {
  echo -e "${LOG_COLOR_POST_ACTION}  [POST ACTIONS]: $1${LOG_COLOR_END}" >&2
}
