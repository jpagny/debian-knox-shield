#!/bin/bash

# Define the paths for the installation scripts
CORE_PATH="$(dirname "$0")/core"
BASE_PATH="$(dirname "$0")/base"
CUSTOM_PATH="$(dirname "$0")/custom"

# Source the core functions
source "$CORE_PATH/logger.sh"
source "$CORE_PATH/execute_task.sh"
source "$CORE_PATH/executor.sh"

# Execute all scripts in the /base directory
execute_scripts_in_directory "$BASE_PATH"

# Execute all scripts in the /custom directory
execute_scripts_in_directory "$CUSTOM_PATH"