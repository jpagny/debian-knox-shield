#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Configure Password Quality Standards
#
# Function..........: task_configure_password_quality
# Description.......: Executes a task to enhance the password quality standards on the system. 
#                     This task aims to set strict password policies to improve system security. 
#                     The function checks prerequisites, executes the main action to adjust password quality settings, 
#                     and handles any necessary post-action steps.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If the password quality standards are successfully configured.
#               - 1 (NOK): If the configuration process fails.
#
###
task_configure_password_quality() {
  
  local name="configure_password_quality"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Configuration of password quality standards failed."
    return "$NOK"
  fi

  log_info "Password quality standards have been successfully configured."
  
  return "$OK"
}

### Check Prerequisites for Configuring Password Quality
#
# Function..........: check_prerequisites_configure_password_quality
# Description.......: Verifies if the libpam-pwquality package is installed on the system. This package 
#                     is necessary for enforcing password quality policies. If the package is not installed,
#                     the script attempts to install it.
# Returns...........: 
#               - 0 (OK): If libpam-pwquality is already installed or successfully installed during the execution.
#               - 1 (NOK): If libpam-pwquality cannot be installed.
#
check_prerequisites_configure_password_quality() {
  # install libpam-pwquality package
  if ! install_package "libpam-pwquality"; then
    return "$NOK"
  fi

  return "$OK"
}

### Enhance Password Security
#
# Function..........: run_action_configure_password_quality
# Description.......: Configures password quality requirements using the pam_pwquality module. 
#                     This function sets various parameters to enforce strong password policies, 
#                     such as minimum length, character diversity, and complexity.
#                     It modifies the /etc/pam.d/common-password file to apply these settings.
# Parameters........: 
#               - None
# Local Variables...:
#               - retry: The number of attempts a user has to enter a compliant password.
#               - minLen: The minimum length required for the password.
#               - difok: The number of characters that must be different from the old password.
#               - ucredit: The requirement for uppercase characters in the password.
#               - lcredit: The requirement for lowercase characters in the password.
#               - dcredit: The requirement for numeric digits in the password.
#               - ocredit: The requirement for non-alphanumeric (special) characters in the password.
#               - maxrepeat: The maximum number of consecutive identical characters allowed in the password.
#               - gecoscheck: Enforces a check against the user's GECOS field to prevent using personal information in the password.
# Returns...........: 
#               - 0 (OK): If the password policy is successfully applied.
#
###
run_action_configure_password_quality() {

  local sshd_config="/etc/pam.d/common-password"

  # Define password quality parameters
  local enforcing=1              # Ensure the policy is enforced
  local retry=3                  # Number of retries for password entry
  local minLen=10                # Minimum length of the password
  local difok=3                  # Number of characters different from the old password
  local ucredit=-1               # Number of required uppercase characters
  local lcredit=-1               # Number of required lowercase characters
  local dcredit=-1               # Number of required digit characters
  local ocredit=-1               # Number of required special characters
  local maxrepeat=3              # Maximum number of consecutive identical characters
  local gecoscheck="gecoscheck"  # Check against the user's GECOS field

  # Form the new pam_pwquality line with the defined parameters
  local pam_pwquality_line="password required pam_pwquality.so enforcing=$enforcing enforce_for_root retry=$retry minlen=$minLen difok=$difok ucredit=$ucredit lcredit=$lcredit dcredit=$dcredit ocredit=$ocredit maxrepeat=$maxrepeat $gecoscheck"

  # Modify the common-password file based on the existence of pam_pwquality.so
  if grep -q "pam_pwquality.so" "$sshd_config"; then
    # Replace the existing pam_pwquality.so line
    sed -i "s/^password.*pam_pwquality.so.*/$pam_pwquality_line/" "$sshd_config"
  else
    # Insert the new line before pam_unix.so
    sed -i "/^password.*pam_unix.so.*/i $pam_pwquality_line" "$sshd_config"
  fi
}

# Run the task to configure password quality
task_configure_password_quality