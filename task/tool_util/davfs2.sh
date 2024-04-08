# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Install davfs2
#
# Function..........: task_install_davfs2
# Description.......: Installs davfs2 on the system. davfs2 is a Linux file system driver that allows mounting a WebDAV
#                     resource as a local file system. It enables access to a remote web server in much the same way as a
#                     local file system. This function checks for root privileges, executes the installation action,
#                     and handles any post-installation tasks.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If davfs2 is successfully installed.
#               - 1 (NOK): If the installation fails.
#
###
task_install_davfs2() {
  
  local name="install_davfs2"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "$name failed."
    return "$NOK"
  fi

  log_info "$name has been successfully installed."
  
  return "$OK"
}

### Check prerequisites for davfs2 installation
#
# Function..........: check_prerequisites_install_davfs2
# Description.......: Checks if davfs2 is already installed to avoid reinstalling it. This step ensures that the
#                     installation process is only carried out when necessary.
# Returns...........: 
#               - 0 (OK): If davfs2 is not already installed or if the system is ready for installation.
#               - 1 (NOK): If davfs2 is already installed.
#
###
check_prerequisites_install_davfs2() {
  if command -v mount.davfs &> /dev/null; then
    log_info "davfs2 is already installed."
    return "$NOK"
  fi
  return "$OK"
}

### Run the installation of davfs2
#
# Function..........: run_action_install_davfs2
# Description.......: Executes the command to install davfs2 using the system's package manager. This is the core action
#                     that installs davfs2 onto the system.
# Returns...........: 
#               - 0 (OK): If davfs2 is successfully installed.
#               - 1 (NOK): If the installation process fails.
#
###
run_action_install_davfs2() {
  # Installs davfs2
  apt-get update && apt-get install -y davfs2
  return $?
}

# Executes the task to install davfs2
task_install_davfs2
