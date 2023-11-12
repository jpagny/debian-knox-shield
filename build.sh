#!/bin/bash

# Define the core and base directories
CORE_DIR="./core"
BASE_DIR="./base"
TARGET_SCRIPT="secure-post-install-debian.sh"

# Remove the existing secure-post-install-debian.sh if it exists
if [[ -f "$TARGET_SCRIPT" ]]; then
    echo "Removing existing $TARGET_SCRIPT file..."
    rm "$TARGET_SCRIPT"
fi

# Function to append scripts from a directory and its subdirectories to the target script
append_scripts_from_directory() {

  local directory="$1"

  # Find all shell scripts in the directory and its subdirectories
  find "$directory" -type f -name "*.sh" | while read -r script; do

    local script_name=$(basename "$script")

    echo -e "#-------------- $script_name" >> "$TARGET_SCRIPT"
    echo "Appending $script_name to $TARGET_SCRIPT..."

    # Append the script contents while excluding shebang and specific source lines
    sed '/^#!/d;/^# import/d;/^\s*source.*\(variable_global.sh\|execute_task.sh\|logger.sh\|utils.sh\)/d' "$script" >> "$TARGET_SCRIPT"

    echo -e "\n" >> "$TARGET_SCRIPT" # Add a newline for separation

  done
}

append_scripts_from_config() {

  local config_file="$1"
  local target_script="secure-post-install-debian.sh"
  local task_directory="task"

  while IFS='|' read -r script_type script_name || [ -n "$script_name" ]; do

    echo "Lecture: $script_type | $script_name"

    local script_path="$PWD/$task_directory/$script_name"

    if [[ -f "$script_path" ]]; then
      echo "Appending script: $script_name to $target_script"
    
      echo -e "\n#-------------- $script_name - $script_type" >> "$target_script"

      # Append the script contents while excluding shebang and specific source lines
      sed '/^#!/d;/^# import/d;/^\s*source.*\(variable_global.sh\|execute_task.sh\|logger.sh\|utils.sh\)/d' "$script_path" >> "$target_script"
    else
      echo "Script not found: $script_path"
    fi

    echo -e "\n" >> "$TARGET_SCRIPT" # Add a newline for separation

  done < "$config_file"
}



echo "#!/bin/bash" >> "$TARGET_SCRIPT"

# Append core scripts
append_scripts_from_directory "$CORE_DIR"

# Append base scripts
append_scripts_from_config "config/script_config.txt"

echo "Build completed. All scripts are combined into $TARGET_SCRIPT."