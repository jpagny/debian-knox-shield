# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Install Vim Text Editor
#
# Function..........: task_add_vim
# Description.......: Installs the Vim text editor on the system. Vim is a highly configurable text editor built to 
#                     enable efficient text editing. It is an improved version of the vi editor distributed with most UNIX systems.
#                     This function checks for root privileges, executes the installation action, and handles any post-installation tasks.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If Vim is successfully installed.
#               - 1 (NOK): If the installation fails.
#
###
task_add_vim() {
  
  local name="add_vim"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Vim installation failed."
    return "$NOK"
  fi

  log_info "Vim has been successfully installed."
  
  return "$OK"
}

### Install Vim Editor
#
# Function..........: run_action_add_vim
# Description.......: Installs the Vim text editor. Vim is a highly configurable, powerful, and popular text editor 
#                     that is an improved version of the vi editor. This function calls install_package to 
#                     handle the installation process of Vim.
# Returns...........: 
#               - 0 (OK): If Vim is successfully installed.
#               - 1 (NOK): If the installation fails.
#
###
run_action_add_vim() {

# install rsyslog package
  if ! install_package "vim"; then
    return "$NOK"
  fi
}

# Run the task to add vim
task_add_vim