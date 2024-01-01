#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task for Closing SSH Port When Not in Use
#
# Function..........: task_close_ssh_port
# Description.......: Closes the SSH port if no active (ESTABLISHED) connections are found. 
#                     This task automates the process of enhancing security by closing unused SSH ports.
#                     It checks if the specified SSH port is in ESTABLISHED state, lists all iptables rules 
#                     for that port, and removes them if no active connections exist. The script is 
#                     scheduled to run every 5 minutes.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement, 
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If the SSH port is successfully closed or no action is needed.
#               - 1 (NOK): If the process of closing the SSH port fails.
#
###
task_close_ssh_port() {
  
  local name="close_ssh_port"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions=""
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "close_ssh_port failed."
    return "$NOK"
  fi

  log_info "close_ssh_port has been successfully."
  
  return "$OK"
}

### Check Prerequisites for Closing SSH Port Task
#
# Function..........: check_prerequisites_close_ssh_port
# Description.......: Checks if the necessary prerequisites for the close_ssh_port task are met. 
#                     Currently, it checks if the Knock utility is installed on the system.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If all prerequisites are met.
#               - 1 (NOK): If any of the prerequisites are not met.
#
###
check_prerequisites_close_ssh_port() {

  # Check if Knock is installed
  if ! command -v knock >/dev/null 2>&1; then
    log_error "Knock is not installed. Please install Knock first."
    return "$NOK"
  fi

  return "$OK"
}

### Run Action for Closing SSH Port
#
# Function..........: run_action_close_ssh_port
# Description.......: Executes the necessary actions for setting up a script that closes the SSH port when 
#                     it is not in use. This includes creating and deploying the script, and setting up 
#                     a cron job to execute it periodically.
#                     The function checks if a log file exists and creates it if necessary, generates a new 
#                     script using create_close_ssh_port_script, sets the appropriate permissions, moves it to 
#                     /usr/local/sbin/, and schedules it in cron to run every 5 minutes.
# Parameters........: 
#               - None
# Returns...........: 
#               - 0 (OK): If the script is successfully created, deployed, and scheduled.
#               - 1 (NOK): If any step in the process fails.
#
###
run_action_close_ssh_port() {

    local script_name="close_ssh_port.sh"
    local script_path="/usr/local/sbin/$script_name"
    local log_file="/var/log/close_ssh_port.log"

    # Check if the log file exists
    if [ ! -f "$log_file" ]; then
        touch "$log_file"
        chmod 600 "$log_file"
    fi

    # Create the script
    create_close_ssh_port_script "$script_name" "$log_file"

    # Make the script executable and move it
    chmod 700 "$script_name"
    chmod +x "$script_name"
    sudo mv "$script_name" "$script_path"

    # Add the cron task
    (crontab -l 2>/dev/null; echo "*/5 * * * * $script_path") | crontab -

    return "$OK"
}

### Create Script for Closing SSH Port
#
# Function..........: create_close_ssh_port_script
# Description.......: Generates a bash script that closes the SSH port if no ESTABLISHED connections are found. 
#                     The script checks the specified SSH port in the sshd_config file, lists all iptables rules 
#                     for that port, and removes them if no ESTABLISHED connections are detected. The function 
#                     writes the script to a specified file and logs the creation.
# Parameters........: 
#               - script_name: The name of the file where the script will be written.
#               - log_file: The file where log entries will be written.
# Returns...........: 
#               - No return value. The result is a created script file.
#
###
create_close_ssh_port_script() {

    local script_name="$1"
    local log_file="$2"

    # build script
    echo '#!/bin/bash' > "$script_name"
    cat >> "$script_name" <<EOF

sshd_conf="/etc/ssh/sshd_config"
PORT=\$(grep "^Port " "\$sshd_conf" | cut -d ' ' -f2)
IPTABLES=\$(which iptables)
NETSTAT=\$(which netstat)

# Check if the port is not in ESTABLISHED state
if ! \$NETSTAT -tna | grep ":\$PORT " | grep 'ESTABLISHED'; then

    # List the iptables rules for the specified port
    readarray -t rules < <(sudo \$IPTABLES -L INPUT -n --line-numbers | grep "tcp dpt:\$PORT" | awk '{print \$1}')

    # Remove the rules in reverse order
    for (( idx=\${#rules[@]}-1 ; idx>=0 ; idx-- )) ; do
        rule_number=\${rules[idx]}
        \$IPTABLES -D INPUT \$rule_number
        echo "\$(date) : Rule for port \$PORT removed, rule number \$rule_number" >> "$log_file"
    done

fi
EOF

    log_info "Script $script_name created."
}

# Run the task to close_ssh_port
task_close_ssh_port