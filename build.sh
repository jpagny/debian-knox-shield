#!/bin/bash

# Define the core and base directories
CORE_DIR="./core"
CONFIG_DIR="./config"
TASK_DIR="./task"
OUTPUT_DIR="./output"

STATUS_FILE=""
CONFIG_FILE=""
OUTPUT_SCRIPT=""
CAPTURE_NEXT_ARG=""

for arg in "$@"; do

  if [ "$CAPTURE_NEXT_ARG" = "CONFIG" ]; then
    CONFIG_FILE="$arg"
    CAPTURE_NEXT_ARG=""

  elif [ "$CAPTURE_NEXT_ARG" = "OUTPUT" ]; then
    OUTPUT_SCRIPT="$arg"
    CAPTURE_NEXT_ARG=""

  elif [ "$arg" = "--debug" ]; then
    DEBUG_MODE=1

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

### Append Scripts from Directory
#
# Function..........: append_scripts_from_directory
# Description.......: Appends all shell scripts found in a specified directory and its 
#                     subdirectories to a target script. This function is designed to 
#                     concatenate multiple script files into a single script, typically 
#                     used for aggregating core script components.
# Parameters........: 
#               - $1: The directory path where shell scripts are located.
# Returns...........: None.
# Side Effects......: The contents of each shell script in the specified directory are 
#                     appended to the global variable TARGET_SCRIPT. Shebang lines, import 
#                     statements, and specific source lines are excluded to prevent 
#                     redundancy and potential conflicts in the combined script.
# Usage.............: This function is specifically used for the core directory to compile 
#                     its shell scripts into a single executable script. It is a part of 
#                     a larger build or setup process where multiple scripts are consolidated.
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
# Description.......: Reads a configuration file listing scripts with their types (mandatory or optional)
#                     and appends the content of each script to a specified target script file. If no target 
#                     script is specified, a default script name is used.
# Parameters........: 
#               - $1: Path to the configuration file which lists scripts with their types.
#               - $2: Optional. Name of the target script file to which the scripts will be appended. 
#                     Defaults to 'secure-post-install-debian.sh' if not provided.
# Returns...........: None.
# Side Effects......: Reads the specified configuration file line by line, each containing a script type 
#                     and its relative path. For each script, the function appends its content to the 
#                     target script file, excluding shebang lines and specific source lines to prevent 
#                     redundancy and conflicts. If a script is not found, an error message is displayed.
# Usage.............: Useful in scenarios where a series of scripts need to be dynamically included in a 
#                     larger script based on a configuration, such as in automated setup or installation processes.
# 
# Example...........: To combine scripts listed in 'script_config.txt' into a specified script, use 
#                     `append_scripts_from_config "config/script_config.txt" "my_combined_script.sh"`.
#                     To use the default script name, use 
#                     `append_scripts_from_config "config/script_config.txt"`.
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



echo "#!/bin/bash" >> "$OUTPUT_DIR/$OUTPUT_SCRIPT"
echo -e "\n" >> "$OUTPUT_DIR/$OUTPUT_SCRIPT"

# Append core scripts
append_scripts_from_directory "$CORE_DIR" "$OUTPUT_DIR/$OUTPUT_SCRIPT"

# Append task scripts
append_scripts_from_config "$CONFIG_FILE" "$OUTPUT_DIR/$OUTPUT_SCRIPT"

echo "Build completed. All scripts are combined into $OUTPUT_SCRIPT."