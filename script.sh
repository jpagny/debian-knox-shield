#!/bin/bash

source "$(dirname "$0")/logger.sh"

# Function to execute tasks and validate the results
execute_task() {
  local name="$1"
  local prereq="$2"
  local actions="$3"
  local configs="$4"

  echo -e "x Prerequisite: $prereq"
  echo -e "x Name: $name"
  echo -e "[Actions]"
  if eval "$actions"; then
    log_info "Actions completed"
  else
    log_error "Actions failed"
  fi
  echo -e "[Configurations]"
  if eval "$configs"; then
    log_info "Configurations completed"
  else
    log_error "Configurations failed"
  fi
  echo "End\n"
}



# Import logger functions

# Function to execute scripts from a specified directory
execute_scripts_in_directory() {
    local directory_path="$1"
    local directory_name="$(basename "$directory_path")"

    log_info "Executing scripts in the $directory_name directory and its subdirectories in order..."

    # Trouver les scripts, les trier, et les exécuter
    find "$directory_path" -type f -name "*.sh" -print0 | sort -z | while IFS= read -r -d '' script; do
        local relative_script_path="${script#$directory_path/}"  # Obtenez le chemin relatif
        if [[ -x "$script" ]]; then
            log_info "Running $relative_script_path..."
            "$script" || log_error "Failed to execute $relative_script_path."
        else
            log_error "$relative_script_path is not executable or not found."
        fi
    done
}


# Define log level colors
LOG_COLOR_DEBUG='\033[0;36m' # Cyan for debug
LOG_COLOR_INFO='\033[0;32m'  # Green for info
LOG_COLOR_WARN='\033[0;33m'  # Yellow for warning
LOG_COLOR_ERROR='\033[0;31m' # Red for error
LOG_COLOR_END='\033[0m'      # End color

# Debug log function
log_debug() {
  echo -e "${LOG_COLOR_DEBUG}[DEBUG]: $1${LOG_COLOR_END}" >&2
}

# Information log function
log_info() {
  echo -e "${LOG_COLOR_INFO}[INFO]: $1${LOG_COLOR_END}" >&2
}

# Warning log function
log_warn() {
  echo -e "${LOG_COLOR_WARN}[WARN]: $1${LOG_COLOR_END}" >&2
}

# Error log function
log_error() {
  echo -e "${LOG_COLOR_ERROR}[ERROR]: $1${LOG_COLOR_END}" >&2
}


# Source logger functions

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

#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

# Function to update and upgrade the system
update_and_upgrade() {
  local name="System Update and Upgrade"
  local prereq="Updating package lists and upgrading installed packages"
  local actions="apt-get update -y"
  local configs="apt-get upgrade -y"

  execute_task "$name" "$prereq" "$actions" "$configs"
}

# Run the update and upgrade function
update_and_upgrade



# Source the execute_task function from the core directory

# Function to install sudo
install_sudo() {
  local name="Install sudo"
  local prereq=""
  local actions="apt-get install -y sudo"
  
  # Check if sudo is installed
  if ! command -v sudo &> /dev/null; then
    execute_task "$name" "$prereq"  "$actions" ""
  else
    log_info "sudo is already installed"
  fi
}

# Run the install sudo function
install_sudo


# Source the execute_task function from the core directory

# Function to install jq if it's not already present
install_jq() {
  local prereq="Checking for jq installation"
  local name="Install jq"
  local actions="apt-get install -y jq"
  
  # Check if jq is installed
  if ! command -v jq &> /dev/null; then
    execute_task "$prereq" "$name" "$actions" ":"
  else
    log_info "jq is already installed."
  fi
}

# Function to ask for username approval
ask_for_username_approval() {
  local user_data username approval="n"

  while [ "$approval" != "y" ]; do
    user_data=$(curl -s https://randomuser.me/api/)
    
    # Log the fetched JSON for debugging purposes
    log_info "Fetched JSON data: $user_data"

    username=$(echo "$user_data" | jq -r '.results[0].login.username')

    # Log the extracted username for debugging
    log_info "Extracted username: $username"

    if [ -z "$username" ]; then
      echo "No username was extracted. There might be an issue with the API or jq parsing."
      continue
    fi

    log_info "Generated username: $username"
    read -p "Do you like this username : $username ? (y/n): " approval
    
    if [ "$approval" != "y" ]; then
      log_info "Fetching a new username..."
    fi
  done

  echo "$username"
}


# Function to generate a new user with sudo privileges
add_user_with_sudo() {
  # Install jq as a prerequisite
  install_jq

  # Ask for username approval and capture the returned username
  local username=$(ask_for_username_approval)
  
  # Set your own password
  read -sp "Enter a new password for the user: " password
  echo # Move to a new line

  # Add the user to the system with the generated username and the provided password
  local prereq="Preparing to add new user with sudo privileges"
  local name="Add User"
  local actions="sudo adduser --gecos '' --disabled-password \"$username\""
  local configs="echo '$username:$password' | chpasswd; usermod -aG sudo \"$username\""

  execute_task "$prereq" "$name" "$actions" "$configs"

  # Save the credentials to a file
  echo "Username: $username" > /tmp/user_credentials.txt
  echo "Password: $password" >> /tmp/user_credentials.txt
}


# Run the function to add a new user with sudo
add_user_with_sudo


# Source the execute_task function from the core directory

# You'll need to know the username, which you can pass as an argument or source from a file
username=$(cat /tmp/user_credentials.txt | grep Username | cut -d ' ' -f 2)

# Command to run as the new user
command_to_run_as_new_user="echo 'Running as new user...'"

# Function to run a command as the new user
run_as_new_user() {
  local prereq="Switching to new user"
  local name="Run command as new user"
  local actions="su - $username -c \"$command_to_run_as_new_user\""

  execute_task "$prereq" "$name" "$actions" ""
}

# Run the function to execute a command as the new user
run_as_new_user



# Source the execute_task function from the core directory

# Function to install SSH
install_ssh() {
  local prereq="Installing OpenSSH server"
  local name="Install SSH"
  local actions="sudo apt-get install -y openssh-server"
  local configs=":"

  execute_task "$prereq" "$name" "$actions" "$configs"
}

# Run the function to install SSH
install_ssh



# Source the execute_task function and logger functions from the core directory

# Function to deactivate root SSH login
deactivate_root_ssh() {
  local prereq="Deactivating root SSH login"
  local name="Deactivate Root SSH"
  local sshd_config="/etc/ssh/sshd_config"
  local actions=""

  log_info "Checking SSH configuration for PermitRootLogin setting."

  # Check if PermitRootLogin exists in the sshd_config and is set to 'yes'
  if grep -q "^PermitRootLogin yes" "$sshd_config"; then
    log_info "PermitRootLogin set to 'yes'. Changing to 'no'."
    # If it exists and is set to 'yes', replace it with 'no'
    actions="sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' $sshd_config"
  else
    log_info "PermitRootLogin not set to 'yes' or does not exist. Adding 'PermitRootLogin no'."
    # If it doesn't exist or isn't set to 'yes', add 'PermitRootLogin no' to the file
    actions="echo 'PermitRootLogin no' | sudo tee -a $sshd_config"
  fi

  local configs="sudo service ssh restart"
  log_info "Restarting SSH service to apply changes."

  execute_task "$prereq" "$name" "$actions" "$configs"
}

# Run the function to deactivate root SSH login
deactivate_root_ssh



# Source the execute_task function from the core directory

# Function to set a random SSH port
set_random_ssh_port() {
  local prereq="Setting a random SSH port"
  local name="Random SSH Port"
  local random_port=$(shuf -i 1024-65535 -n 1) # Generate a random port between 1024 and 65535
  local actions="sudo sed -i 's/^#Port 22/Port $random_port/' /etc/ssh/sshd_config"
  local configs="sudo service ssh restart"

  execute_task "$prereq" "$name" "$actions" "$configs"

  # Save the new SSH port to a file for reference
  echo "SSH is now listening on port: $random_port" | sudo tee /etc/ssh/ssh_port_info.txt
}

# Run the function to set a random SSH port
set_random_ssh_port



# Source the execute_task function from the core directory

# Function to disable root account
disable_root_account() {
    local prereq="Disabling root account"
    local name="Disable Root"
    local random_password=$(openssl rand -base64 48) # Generate a complex password
    local actions="echo 'root:$random_password' | sudo chpasswd"
    local configs=":"

    execute_task "$prereq" "$name" "$actions" "$configs"

    log_info "Root account has been disabled."
}

# Run the function to disable root account
disable_root_account


# Source the execute_task function from the core directory

# Function to install UFW if it's not already installed
install_ufw() {
    local prereq="Checking for UFW installation"
    local name="Install UFW"
    local actions="sudo apt-get install -y ufw"
    local configs=":"

    # Check if UFW is installed
    if ! command -v ufw &> /dev/null; then
        execute_task "$prereq" "$name" "$actions" "$configs"
        log_info "UFW installed successfully."
    else
        log_info "UFW is already installed."
    fi
}

# Run the function to install UFW
install_ufw



# Source the execute_task function from the core directory

# Function to configure UFW
configure_ufw() {
    local ssh_port_file="/etc/ssh/ssh_port_info.txt"
    local ssh_port

    # Check if a custom SSH port has been set, otherwise use the default port 22
    if [[ -f "$ssh_port_file" ]]; then
        ssh_port=$(cat "$ssh_port_file" | grep -oP '(?<=SSH is now listening on port: )\d+')
    else
        ssh_port=22  # Default SSH port
    fi

    local prereq="Configuring UFW"
    local name="Configure UFW"
    local actions="sudo ufw allow $ssh_port/tcp && sudo ufw --force enable"
    local configs=":"

    execute_task "$prereq" "$name" "$actions" "$configs"
    log_info "UFW has been configured to allow only SSH port $ssh_port."
}

# Run the function to configure UFW
configure_ufw


# Source the execute_task function from the core directory

# Function to create and schedule update script
create_and_schedule_update() {
    local update_script="/usr/local/bin/update_system.sh"
    local cron_job="0 2 * * * $update_script"

    # Create the update script
    echo "Creating the update script at $update_script..."
    echo "#!/bin/bash" | sudo tee $update_script
    echo "sudo apt-get update" | sudo tee -a $update_script
    echo "sudo apt-get upgrade -y" | sudo tee -a $update_script
    sudo chmod +x $update_script

    # Add the script to crontab
    echo "Adding the update script to crontab..."
    (sudo crontab -l 2>/dev/null; echo "$cron_job") | sudo crontab -

    log_info "Update script created and scheduled."
}

# Run the function to create and schedule the update task
create_and_schedule_update


# Source the execute_task function from the core directory

# Function to install and configure Fail2Ban
install_and_configure_fail2ban() {
    local prereq_install="Installing Fail2Ban"
    local name_install="Install Fail2Ban"
    local actions_install="sudo apt-get install -y fail2ban"
    local configs_install=":"

    # Install Fail2Ban
    execute_task "$prereq_install" "$name_install" "$actions_install" "$configs_install"

    local prereq_config="Configuring Fail2Ban"
    local name_config="Configure Fail2Ban"
    local jail_local="/etc/fail2ban/jail.local"
    local actions_config="echo '[DEFAULT]' | sudo tee $jail_local"
    actions_config+=" && echo 'bantime = 10m' | sudo tee -a $jail_local"  # Example configuration
    actions_config+=" && echo 'findtime = 10m' | sudo tee -a $jail_local"
    actions_config+=" && echo 'maxretry = 5' | sudo tee -a $jail_local"
    local configs_config="sudo systemctl restart fail2ban"

    # Configure Fail2Ban
    execute_task "$prereq_config" "$name_config" "$actions_config" "$configs_config"

    log_info "Fail2Ban has been installed and configured."
}

# Run the function to install and configure Fail2Ban
install_and_configure_fail2ban



# Source the execute_task function from the core directory

# Function to install Lynis
install_lynis() {
    local prereq="Installing Lynis"
    local name="Install Lynis"
    local actions="sudo apt-get update && sudo apt-get install -y lynis"
    local configs=":"

    # Install Lynis
    execute_task "$prereq" "$name" "$actions" "$configs"

    log_info "Lynis has been installed successfully."
}

# Run the function to install Lynis
install_lynis


# Source the execute_task function from the core directory

# Function to install ClamAV
install_clamav() {
    local prereq="Installing ClamAV"
    local name="Install ClamAV"
    local actions="sudo apt-get update && sudo apt-get install -y clamav clamav-daemon"
    local configs="sudo freshclam"

    # Install ClamAV and update virus database
    execute_task "$prereq" "$name" "$actions" "$configs"

    log_info "ClamAV has been installed and virus database updated."
}

# Run the function to install ClamAV
install_clamav

