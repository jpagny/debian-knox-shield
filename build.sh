#!/bin/bash

# Define the core and base directories
CORE_DIR="./core"
BASE_DIR="./base"
CUSTOM_DIR="./custom"
TARGET_SCRIPT="script.sh"

# Remove the existing script.sh if it exists
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

    if [ "$script_name" != "executor.sh" ]; then

      echo "Appending $script_name to $TARGET_SCRIPT..."

      # Append the script contents while excluding shebang and specific source lines
      sed '/^#!/d;/^# import/d;/^\s*source.*\(execute_task.sh\|logger.sh\|utils.sh\)/d' "$script" >> "$TARGET_SCRIPT"

      echo -e "\n" >> "$TARGET_SCRIPT" # Add a newline for separation
    fi

  done
}

echo "#!/bin/bash" >> "$TARGET_SCRIPT"

# Append core scripts
append_scripts_from_directory "$CORE_DIR"

# Append base scripts
append_scripts_from_directory "$BASE_DIR"

# Append custom scripts
append_scripts_from_directory "$CUSTOM_DIR"


echo "Build completed. All scripts are combined into $TARGET_SCRIPT."