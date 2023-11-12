#!/bin/bash

# Define the core and base directories
CORE_DIR="./core"
CONFIG_DIR="./config"
TASK_DIR="./task"
OUTPUT_DIR="./output"
STATUS_FILE=""

# Define the Command Line Arguments
CONFIG_FILE=""
OUTPUT_SCRIPT=""
CAPTURE_NEXT_ARG=""

# Process Command Line Arguments
for arg in "$@"; do

  if [ "$CAPTURE_NEXT_ARG" = "CONFIG" ]; then
    CONFIG_FILE="$arg"
    CAPTURE_NEXT_ARG=""

  elif [ "$CAPTURE_NEXT_ARG" = "OUTPUT" ]; then
    OUTPUT_SCRIPT="$arg"
    CAPTURE_NEXT_ARG=""

  elif [ "$arg" = "--config" ]; then
    CAPTURE_NEXT_ARG="CONFIG"

  elif [ "$arg" = "--output" ]; then
    CAPTURE_NEXT_ARG="OUTPUT"

  fi

done

# Provide default values if not specified
CONFIG_FILE=${CONFIG_FILE:-"default_config.txt"}
OUTPUT_SCRIPT=${OUTPUT_SCRIPT:-"default_output.sh"}

# Remove the existing secure-post-install-debian.sh if it exists
if [[ -f "$OUTPUT_DIR/$OUTPUT_SCRIPT" ]]; then
    echo "Removing existing $OUTPUT_DIR/$OUTPUT_SCRIPT file..."
    rm "$OUTPUT_DIR/$OUTPUT_SCRIPT"
fi

# Building script 
echo "#!/bin/bash" >> "$OUTPUT_DIR/$OUTPUT_SCRIPT"
echo -e "\n" >> "$OUTPUT_DIR/$OUTPUT_SCRIPT"

# Append core scripts
append_scripts_from_directory "$CORE_DIR" "$OUTPUT_DIR/$OUTPUT_SCRIPT"

# Append task scripts
append_scripts_from_config "$CONFIG_FILE" "$OUTPUT_DIR/$OUTPUT_SCRIPT"

echo "Build completed. All scripts are combined into $OUTPUT_SCRIPT."


####################### Functions #######################

### Append Scripts from Directory
#
# Function..........: append_scripts_from_directory
# Description.......: Searches for all shell scripts within a specified directory (and its subdirectories) 
#                     and appends their contents to a target script file. This function is useful for 
#                     consolidating multiple script files into a single aggregated script. It excludes 
#                     shebang lines and specific source lines to prevent redundancy in the final script.
# Parameters........: 
#               - $1: The directory path where shell scripts are located.
#               - $2: Name of the target script file to which the scripts will be appended.
# Side Effects......: Iterates through each shell script found in the specified directory, appending its 
#                     contents to the target script file. Excludes certain lines to avoid script conflicts. 
#                     If a script cannot be found or accessed, it is skipped with an error message.
# Usage.............: Ideal for scripts that require assembling various components (like initialization,
#                     configuration, utility functions) into a single executable script.
# 
###
append_scripts_from_directory() {

  local directory="$1"
  local target_script="$2"

  # Find all shell scripts in the directory and its subdirectories
  find "$directory" -type f -name "*.sh" | while read -r script; do

    local script_name=$(basename "$script")

    echo -e "#-------------- $script_name" >> "$target_script"
    echo "Appending $script_name to $target_script..."

    # Append the script contents while excluding shebang and specific source lines
    sed '/^#!/d;/^# import/d;/^\s*source.*\(variable_global.sh\|execute_task.sh\|logger.sh\|utils.sh\)/d' "$script" >> "$target_script"

    echo -e "\n" >> "$target_script" # Add a newline for separation

  done
}

### Append Scripts from Configuration File
#
# Function..........: append_scripts_from_config
# Description.......: Reads a configuration file listing script types and names, 
#                     and appends the contents of each specified script to a target script file. 
#                     The scripts are located based on the TASK_DIR and the relative paths provided 
#                     in the configuration file.
# Parameters........: 
#               - $1: Path to the configuration file which lists scripts with their types (mandatory/optional).
#               - $2: Name of the target script file to which the scripts will be appended.
# Side Effects......: Iterates through each line in the configuration file, attempting to append 
#                     the content of each specified script to the target script file. Excludes shebang lines 
#                     and specific source lines to avoid redundancy. If a script is not found at the expected 
#                     path, an error message is displayed.
# Usage.............: This function is ideal for scenarios where scripts need to be dynamically aggregated 
#                     based on a configuration file. It's useful in automated build or deployment processes.
# 
###
append_scripts_from_config() {
  local config_file="$1"
  local target_script="$2"

  local path_config_file="${CONFIG_DIR}/${config_file}"

  while IFS='|' read -r script_type script_name || [ -n "$script_name" ]; do
    local script_path="${TASK_DIR}/${script_name}"

    if [[ -f "$script_path" ]]; then
      echo "Appending script: $script_name to $target_script"
      echo -e "\n#-------------- $script_name - $script_type" >> "$target_script"

      # Append the script contents while excluding shebang and specific source lines
      sed '/^#!/d;/^# import/d;/^\s*source.*\(variable_global.sh\|execute_task.sh\|logger.sh\|utils.sh\)/d' "$script_path" >> "$target_script"
    else
      echo "Script not found: $script_path"
    fi
  done < "$path_config_file"
}
