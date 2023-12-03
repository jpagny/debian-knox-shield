#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

task_aide_report_mail() {
  
  local name="aide_report_mail"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "aide_report_mail failed."
    return "$NOK"
  fi

  log_info "aide_report_mail has been successfully aide_report_mailx."
  
  return "$OK"
}

check_prerequisites_aide_report_mail() {

  # Check if AIDE is installed
  if ! command -v aide >/dev/null 2>&1; then
    log_error "AIDE is not installed. Please install AIDE first."
    return "$NOK"
  fi

  # Check if the system can send emails
  if ! command -v mail >/dev/null 2>&1; then
    log_error "Mail command is not available. Please install mailutils or a similar package."
    return "$NOK"
  fi

  return "$OK"
}

run_action_aide_report_mail() {

  local report_email

  # Ask for the email address and validate it
  while true; do
    read -p "Enter the email address for AIDE reports: " report_email

    # Basic email validation using regex
    if [[ "$report_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
      log_info "Email address validated."
      break
    else
      log_error "Invalid email address. Please enter a valid email."
    fi
  done

  # Add a new cron job for daily AIDE checks
  log_info "Adding a cron job for daily AIDE checks..."

  # Create a new cron job entry that checks for changes and sends an email if changes are detected
  local cron_job="0 0 * * * /usr/bin/aide --config /etc/aide/aide.conf --check | grep -q 'changed' && echo '$(date '+\%Y-\%m-\%d') - Changes detected by AIDE' | mail -s 'AIDE Report' $report_email"

  # Add the cron job to the crontab
  (crontab -l 2>/dev/null; echo "$cron_job") | crontab -

  # Check if the cron job was added successfully
  if crontab -l | grep -Fq "$cron_job"; then
    log_info "Cron job for daily AIDE checks added successfully."
    return "$OK"
  else
    log_error "Failed to add cron job for daily AIDE checks."
    return "$NOK"
  fi
  
}

# Run the task to aide_report_mail
task_aide_report_mail
