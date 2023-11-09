#!/bin/bash

# Define the paths for the installation scripts
BASE_PATH="$(dirname "$0")/base"
CUSTOM_PATH="$(dirname "$0")/custom"

# Source the core functions
source "$BASE_PATH/../core/logger.sh"
source "$BASE_PATH/../core/execute_task.sh"
source "$BASE_PATH/../core/executor.sh"

# Execute all scripts in the /base directory
execute_scripts_in_directory "$BASE_PATH"

# Execute all scripts in the /custom directory
execute_scripts_in_directory "$CUSTOM_PATH"