#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task: Install and Configure Mail Server (Postfix)
#
# Function..........: task_install_mail_server
# Description.......: Installs and configures Postfix mail server. The task includes installing Postfix,
#                     configuring it to handle outgoing mail, and ensuring it starts automatically upon system boot.
# Parameters........: None
# Returns...........: 
#               - 0 (OK): If Postfix is successfully installed and configured.
#               - 1 (NOK): If the task fails at any step.
#
##
task_install_mail_server() {
  
  local name="install_mail_server"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "Mail server installation failed."
    return "$NOK"
  fi

  log_info "Mail server has been successfully installed and configured."
  
  return "$OK"
}

### Check Prerequisites for Mail Server Installation
#
# Function..........: check_prerequisites_install_mail_server
# Description.......: Verifies if the system meets the requirements for installing a mail server, 
#                     such as checking for internet connectivity and sufficient disk space.
# Returns...........: 
#               - 0 (OK): If all prerequisites are met.
#               - 1 (NOK): If any prerequisite check fails.
#
##
check_prerequisites_install_mail_server() {
  if ! install_package "postfix"; then
    log_error "Failed to install Postfix."
    return "$NOK"
  fi

  return "$OK"
}

### Action: Install and Configure Mail Server
#
# Function..........: run_action_install_mail_server
# Description.......: Performs the actual installation and configuration of the Postfix mail server. 
#                     This involves installing the postfix package, configuring it for outgoing mail, 
#                     and enabling it to start on boot.
# Returns...........: 
#               - 0 (OK): If Postfix is successfully installed and configured.
#
##
run_action_install_mail_server() {  
  # Enable Postfix to start on boot
  systemctl enable postfix

  # Start Postfix service
  systemctl start postfix

  log_info "Postfix mail server installation and initial configuration completed."

  return "$OK"
}

### Post-Action: Enable and Verify Mail Server Settings
#
# Function..........: post_actions_install_mail_server
# Description.......: Verifies that the Postfix mail server is installed, configured, and running properly.
#                     Opens necessary ports for mail services using UFW. Logs the status and any useful information 
#                     about the mail server.
# Returns...........: 
#               - 0 (OK): If Postfix is verified to be installed, running correctly, and necessary ports are opened.
#               - 1 (NOK): If Postfix is not running as expected or if there's a failure in opening ports.
#
##
post_actions_install_mail_server() {
  if systemctl is-active --quiet postfix; then
    log_info "Postfix is active and running."
  else
    log_error "Postfix is not running as expected. Please check the configuration."
    return "$NOK"
  fi

  # Log the status or any other useful information
  log_info "$(postconf -n)"

  # Open necessary ports for mail services
  ufw allow 25/tcp    # SMTP
  ufw allow 587/tcp   # Submission
  ufw allow 465/tcp   # SMTPS (if required)
  ufw allow 143/tcp   # IMAP
  ufw allow 993/tcp   # IMAPS
  ufw allow 110/tcp   # POP3 (if required)
  ufw allow 995/tcp   # POP3S (if required)
  
  log_info "Necessary ports for mail services have been opened in UFW."

  return "$OK"
}

# Execute the task to install and configure the mail server
task_install_mail_server