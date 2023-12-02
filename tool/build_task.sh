#!/bin/bash

if [ $# -ne 4 ]; then
  echo "Usage: $0 <task_name> <folder_name> <need_prerequisites> <need_post_action>"
  exit 1
fi

task_name="$1"
folder_name="$2"
need_prerequisites="$3"
need_post_action="$4"

# Define the task directory path
task_dir="task/$folder_name"

# Create the task directory if it doesn't exist
mkdir -p "$task_dir"

# Define the full path to the task script
task_script_path="$task_dir/${task_name}.sh"

# Check if the task script already exists
if [ -e "$task_script_path" ]; then
  echo "The task script '${task_name}.sh' already exists in the '$task_dir' directory. Aborting."
  exit 1
fi

BASE_DIR=$(cd "$BASE_DIR"; pwd)
TEMPLATE_PATH="$BASE_DIR/tool/template/task.sh"
DEST_PATH="$BASE_DIR/$task_script_path"

# Copy the template to the destination
cp "$TEMPLATE_PATH" "$DEST_PATH"

# Replace occurrences of "xxxx" with the task name
sed -i "s/xxxx/$task_name/g" "$task_script_path"

# Customize the need_prerequisites and need_post_action variables
if [ "$need_prerequisites" = true ]; then
  prerequisites="check_prerequisites_${task_name}"
else
  prerequisites=""
  # Set prereq to an empty string if prerequisites are not needed
  sed -i "s/local prereq=\"check_prerequisites_\$name\"/local prereq=\"\"/" "$task_script_path"
# Remove the check_prerequisites function and its content if post action is not needed
  sed -i '/check_prerequisites_.*() {/,/}/d' "$task_script_path"

fi

if [ "$need_post_action" = true ]; then
  post_action="post_action_${task_name}"
else
  post_action=""
  # Set postActions to an empty string if post action is not needed
  sed -i "s/local postActions=\"post_actions_\$name\"/local postActions=\"\"/" "$task_script_path"
  # Remove the post_actions function and its content if post action is not needed
  sed -i '/post_actions_.*() {/,/}/d' "$task_script_path"
fi

# Replace occurrences of "need_prerequisites" and "need_post_action" with the custom variables
sed -i "s/need_prerequisites/$prerequisites/g" "$task_script_path"
sed -i "s/need_post_action/$post_action/g" "$task_script_path"

echo "The task script '${task_name}.sh' has been created in the '$task_dir' directory and customized."
