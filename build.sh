#!/bin/bash

# Define the core and base directories
CORE_DIR="./core"
BASE_DIR="./base"
TARGET_SCRIPT="script.sh"

# Remove the existing script.sh if it exists
if [[ -f "$TARGET_SCRIPT" ]]; then
    echo "Removing existing $TARGET_SCRIPT file..."
    rm "$TARGET_SCRIPT"
fi

# Function to append scripts from a directory to the target script
append_scripts_from_directory() {
  local directory="$1"
  local first_file=true

  for script in "$directory"/*.sh; do
    if [[ -f "$script" ]]; then
      echo "Appending $(basename "$script") to $TARGET_SCRIPT..."

      # If it's the first file, keep the shebang, otherwise remove it
      if [ "$first_file" = true ]; then
        cat "$script" >> "$TARGET_SCRIPT"
        first_file=false
      else
        # Append the script contents while excluding shebang and specific source lines
        sed '/^#!/d;/^\s*source.*\(execute_task.sh\|logger.sh\)/d' "$script" >> "$TARGET_SCRIPT"
      fi

      echo -e "\n" >> "$TARGET_SCRIPT" # Add a newline for separation
    fi
  done
}

# Append core scripts
append_scripts_from_directory "$CORE_DIR"

# Append base scripts
append_scripts_from_directory "$BASE_DIR"

echo "Build completed. All scripts are combined into $TARGET_SCRIPT."