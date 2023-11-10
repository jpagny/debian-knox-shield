#!/bin/bash

# Import logger functions
source "$(dirname "$0")/logger.sh"

# Function to execute scripts from a specified directory
execute_scripts_in_directory() {
    local directory_path="$1"
    local directory_name="$(basename "$directory_path")"

    log_info "Executing scripts in the $directory_name directory and its subdirectories in order..."

    # Trouver les scripts, les trier, et les exécuter
    find "$directory_path" -type f -name "*.sh" -print0 | sort -z | while IFS= read -r -d '' script; do
        local relative_script_path="${script#$directory_path/}"  # Obtenez le chemin relatif
        if [[ -x "$script" ]]; then
            log_info "Running $relative_script_path..."
            "$script" || log_error "Failed to execute $relative_script_path."
        else
            log_error "$relative_script_path is not executable or not found."
        fi
    done
}