# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Install Net-Tools
#
# Function..........: task_add_net-tools
# Description.......: Installs the net-tools package on the system. Net-tools includes important network utilities such as ifconfig, netstat, 
#                     route, and others. It's used for network troubleshooting and configuration. This function checks for root privileges, 
#                     executes the installation action, and handles any post-installation tasks.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If net-tools is successfully installed.
#               - 1 (NOK): If the installation fails.
#
###
task_add_net-tools() {
  
  local name="add_net-tools"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Net-tools installation failed."
    return "$NOK"
  fi

  log_info "Net-tools has been successfully installed."
  
  return "$OK"
}

### Install Net-Tools
#
# Function..........: run_action_add_net-tools
# Description.......: Installs the net-tools package. Net-tools includes a collection of programs for controlling and 
#                     monitoring network devices and traffic, such as ifconfig, netstat, route, and others. This function calls 
#                     install_package to handle the installation process of net-tools.
# Returns...........: 
#               - 0 (OK): If net-tools is successfully installed.
#               - 1 (NOK): If the installation fails.
#
###
run_action_add_net-tools() {

# install vim package
  if ! install_package "net_tools"; then
    return "$NOK"
  fi
}

# Run the task to add net_tools
task_add_net-tools