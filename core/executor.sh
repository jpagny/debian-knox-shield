#!/bin/bash

# import
source "logger.sh"

### Execute scripts in directory
#
# Function..........: execute_scripts_in_directory
# Description.......: Executes all executable .sh scripts in a specified directory and its subdirectories, in order.
# Parameters........: 
#              - $1: The path of the directory containing the scripts to execute.
# Output............: Logs information about script execution progress and any errors encountered.
#
###
execute_scripts_in_directory() {
    
    local directory_path="$1"
    local directory_name="$(basename "$directory_path")"

    log_info "Executing scripts in the $directory_name directory and its subdirectories in order..."

    find "$directory_path" -type f -name "*.sh" -print0 | sort -z | while IFS= read -r -d '' script; do

        local relative_script_path="${script#$directory_path/}"

        if [[ -x "$script" ]]; then
            log_info "Running $relative_script_path..."
            if ! "$script"; then
                log_error "Failed to execute $relative_script_path."
                return 1  # Stop the loop on failure
            fi
        else
            log_error "$relative_script_path is not executable or not found."
            return 1  # Stop the loop on failure
        fi

    done

    log_info "All scripts in $directory_name executed successfully."
}