# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Configure SSH Banner
#
# Function..........: ssh_add_banner
# Description.......: Configures the SSH service to display a custom login banner by setting the 'Banner' directive in the sshd_config file
#                     to point to a banner text file. This function ensures the banner text file exists, then updates the SSH
#                     configuration to reference it, and finally reloads the SSH service to apply the changes.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If the SSH banner is successfully configured.
#               - 1 (NOK): If the configuration process fails.
#
###
task_ssh_add_banner() {
  
  local name="add_ssh_banner"
  local isRootRequired=true
  local prereq=""
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "SSH banner configuration failed."
    return "$NOK"
  fi

  log_info "SSH banner has been successfully configured."
  
  return "$OK"
}

### Configure SSH to Use Banner
#
# Function..........: run_action_add_ssh_banner
# Description.......: Copies the specified banner file to an appropriate location, updates the sshd_config to use this
#                     banner file, and reloads the SSH service to apply the changes. Assumes the banner text is stored
#                     in 'config/banner.txt' relative to the script location.
# Returns...........: 
#               - 0 (OK): If the banner is successfully configured.
#               - 1 (NOK): If the process fails, such as if the file does not exist or the SSH service cannot reload.
#
###
run_action_add_ssh_banner() {
  local bannerSource="$(dirname "$0")/../config/banner.txt"
  local bannerDest="/etc/ssh/banner.txt"

  # Ensure the banner source file exists
  if [ ! -f "$bannerSource" ]; then
    log_error "Banner source file does not exist: $bannerSource"
    return "$NOK"
  fi

  # Copy the banner file to the destination
  cp "$bannerSource" "$bannerDest" || return "$NOK"

  # Update sshd_config to use the new banner file
  echo "Banner $bannerDest" >> /etc/ssh/sshd_config || return "$NOK"

  # Reload the SSH service to apply changes
  systemctl reload sshd || return "$NOK"

  return "$OK"  # Assumes successful execution
}

### Post-Configuration Actions for SSH Banner
#
# Function..........: post_actions_add_ssh_banner
# Description.......: Any required actions after the SSH banner has been configured, such as cleanup or additional logging.
# Returns...........: 
#               - 0 (OK): If post-configuration tasks are successfully completed.
#               - 1 (NOK): If there are issues completing post-configuration tasks.
#
###
post_actions_add_ssh_banner() {
  # Placeholder for any post-action tasks
  return "$OK"
}

# Execute the task to configure the SSH banner
task_ssh_add_banner
