#!/bin/bash

### Process Command Line Arguments for Debug Mode
#
# Description.......: This script segment checks for the presence of the '--debug' flag in the command line arguments.
#                     If '--debug' is found, the script sets DEBUG_MODE to 1, enabling debug functionality.
#                     This is useful for turning on additional logging or diagnostic output in the script.
# Arguments.........: 
#               - --debug (optional): Flag to enable debug mode.
# Returns...........: None directly. Sets the global variable DEBUG_MODE to 1 if '--debug' is present.
# Usage.............: Place this snippet at the beginning of a script to enable debug mode based on command line input.
# 
# Example...........: `./script.sh --debug` will enable debug mode by setting DEBUG_MODE to 1.
#
###
DEBUG_MODE=0

for arg in "$@"; do

  if [ "$arg" = "--debug" ]; then
    DEBUG_MODE=1
  fi

done