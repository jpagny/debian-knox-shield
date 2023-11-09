#!/bin/bash

# Source logger functions
source "$(dirname "$0")/logger.sh"

# Function to send an email report
send_email_report() {
  local logfile="$1"
  local credentialsfile="$2"
  local recipient="$3"
  local subject="Secure Debian Post-Install Report"
  
  # Check if the mail utility is available
  if ! command -v mail &> /dev/null; then
    log_error "The 'mail' command is not available. Please install it or configure a mail server."
    return 1
  fi

  if [[ -f "$logfile" && -f "$credentialsfile" ]]; then
    local report_content="Installation Report:\n\n$(cat "$logfile")\n\nCredentials:\n$(cat "$credentialsfile")"
    
    echo -e "$report_content" | mail -s "$subject" "$recipient"
    log_info "Email report sent to $recipient"
  else
    log_error "Log file or credentials file not found."
  fi
}