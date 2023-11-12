#!/bin/bash

# Debug mode
DEBUG_MODE=0

### Parse Arguments for Debug Mode
#
# Description.......: Parses script arguments to check if debug mode should be enabled.
#                     Sets the DEBUG_MODE variable to 1 if '--debug' is found among the arguments.
#                     This affects the behavior of functions that depend on the DEBUG_MODE 
#                     setting, enabling additional logging or verbose output.
# Parameters........: 
#               - $@: All arguments passed to the script.
# Effects...........: Modifies the global DEBUG_MODE variable.
# Note..............: Place this code at the beginning of the script or before any functions 
#                     that depend on the DEBUG_MODE setting are called.
#
###
for arg in "$@"; do

  if [ "$arg" = "--debug" ]; then
    DEBUG_MODE=1
    break
  fi

done

# Create STATUS_FILE if it doesn't exist
if [ ! -f "$STATUS_FILE" ]; then
    touch "$STATUS_FILE"
fi
