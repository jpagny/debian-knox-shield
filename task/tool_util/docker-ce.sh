#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

### Task for Installing Docker Community Edition (CE)
#
# Function..........: task_add_docker-ce
# Description.......: Installs Docker CE on the system and performs post-installation actions to ensure that 
#                     Docker is properly configured and operational. This includes checking prerequisites, 
#                     installing Docker, adding a user to the Docker group for secure operation, and verifying 
#                     the installation with a test container.
# Parameters........: 
#               - None directly. The function uses predefined local variables for task name, root requirement, 
#                     prerequisites, actions, post-actions, and task type.
# Returns...........: 
#               - 0 (OK): If Docker CE is successfully installed, configured, and verified.
#               - 1 (NOK): If the installation or configuration process fails at any point.
##
task_add_docker-ce() {
  
  local name="add_docker-ce"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "add_docker failed."
    return "$NOK"
  fi

  log_info "add_docker has been successfully add_dockerx."
  
  return "$OK"
}

### Check Prerequisites for Docker CE Installation
#
# Function..........: check_prerequisites_add_docker-ce
# Description.......: Prepares the system for Docker CE installation. This includes installing necessary 
#                     packages like apt-transport-https, ca-certificates, curl, and software-properties-common. 
#                     It also involves adding Docker's official GPG key, setting up the Docker repository, 
#                     updating the package database, and installing Docker CE.
# Parameters........: 
#               - None. The function handles all the steps necessary to prepare for Docker CE installation.
# Returns...........: 
#               - 0 (OK): If all prerequisites are successfully installed and configured, and Docker CE is 
#                          installed.
#               - 1 (NOK): If any step in the process fails, including package installation, repository setup, 
#                           or Docker CE installation.
##
check_prerequisites_add_docker-ce() {

  # Install jq package
  if ! install_package "jq"; then
    return "$NOK"
  fi

  # install pwgen package
  if ! install_package "pwgen"; then
    return "$NOK"
  fi

  # install apt-transport-https package
  if ! install_package "apt-transport-https"; then
    return "$NOK"
  fi

  # install ca-certificates package
  if ! install_package "ca-certificates"; then
    return "$NOK"
  fi

  # install curl package
  if ! install_package "curl"; then
    return "$NOK"
  fi

  # install gnupg package
  if ! install_package "gnupg"; then
    return "$NOK"
  fi

  install -m 0755 -d /etc/apt/keyrings

  # Add Docker’s official GPG key
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \

  tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Update the package database
  log_info "Updating the package database..."
  if ! apt-get update; then
    log_error "Failed to update the package database."
    return "$NOK"
  fi

  # Install the latest version of Docker CE
  log_info "Installing Docker CE..."
  if ! install_package "docker-ce"; then
    log_error "Failed to install Docker CE."
    return "$NOK"
  fi

  return "$OK"
}

### Run Action for Docker CE Installation and Configuration
#
# Function..........: run_action_add_docker-ce
# Description.......: Secures the Docker installation by creating a new non-root user and adding them to the Docker 
#                     group. The function prompts for a new username and password, confirms the credentials with the user, 
#                     creates the new user with the provided credentials, and adds them to the Docker group. It also 
#                     ensures that the Docker group exists before adding the user to it.
# Parameters........: 
#               - None. The function uses interactive prompts to gather input for the new user's credentials.
# Returns...........: 
#               - 0 (OK): If a new user is successfully created and added to the Docker group.
#               - 1 (NOK): If any part of the process fails, such as user creation or adding the user to the Docker group.
##
run_action_add_docker-ce() {

  log_info "Securing the Docker installation..."

  local configCredentials="$(dirname "$0")/../config/credentials.txt"
  local docker_user
  local docker_password
  local confirmation

  log_info "Adding a new user for Docker"

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "#task_add_docker-ce" ]]; then
      startProcessing=true
      continue
    elif [[ "$line" == "#task_"* && $startProcessing == true ]]; then
      break
    fi

    if $startProcessing; then
      if [[ "$line" =~ ^docker_username= ]]; then
        docker_user="${line#*=}"
      elif [[ "$line" =~ ^docker_password= ]]; then
        docker_password="${line#*=}"
      fi
    fi
  done < "$configCredentials"

  if [ -n "$docker_user" ] && [ -n "$docker_password" ]; then
    log_info "Using predefined Docker user credentials from credentials file."
  else
    log_info "Prompting for new Docker user credentials..."

    # Substitute these with your actual methods for collecting input
    docker_user=$(ask_for_username_approval)
    docker_password=$(ask_for_password_approval)
  fi

  # Create the user with the provided password
  log_info "Creating user $docker_user..."
  # Use the useradd command to create the user without a password prompt
  adduser --gecos "" --disabled-password "$docker_user"

  # Set the password for the user securely using chpasswd
  echo "$docker_user:$docker_password" | chpasswd

  # Add the new user to the Docker group
  # Create Docker user group, if not already exists
  if ! getent group docker > /dev/null; then
    groupadd docker
  fi

  # Add the confirmed or provided user to the Docker group
  if ! usermod -aG docker "$docker_user"; then
    log_error "Failed to add $docker_user to the Docker group."
    return "$NOK"
  fi

  log_info "User $docker_user has been added to the Docker group successfully."

  return "$OK"
}

### Post-Installation Actions for Docker CE
#
# Function..........: post_actions_add_docker-ce
# Description.......: Verifies the Docker CE installation by running the 'hello-world' Docker container. This function 
#                     tests if Docker is correctly installed and operational by executing a simple, lightweight container. 
#                     The successful execution of the 'hello-world' container is a common method to confirm that Docker 
#                     can pull images from Docker Hub and run containers.
# Parameters........: 
#               - None. The function performs the verification without additional parameters.
# Returns...........: 
#               - 0 (OK): If the 'hello-world' container runs successfully, indicating a functional Docker setup.
#               - 1 (NOK): If the 'hello-world' container fails to run, suggesting an issue with the Docker installation.
##
post_actions_add_docker-ce() {

  log_info "Testing Docker installation with the hello-world image..."

  # Run the hello-world Docker container
  if ! docker run hello-world; then
    log_error "Failed to run the hello-world Docker container."
    return "$NOK"
  fi

  log_info "Docker hello-world container ran successfully. Docker is functioning correctly."

  # Enhancing security: enable User Namespaces
  setup_docker_user_namespaces

  return "$OK"
}

# Function..........: setup_docker_user_namespaces
# Description.......: Configures Docker to use User Namespaces for enhanced container isolation. 
#                     This function modifies the Docker daemon configuration to map container user and group IDs 
#                     to a separate range of IDs on the host, improving security by limiting the impact of a container 
#                     compromise.
# Parameters........: 
#               - None. The function updates the Docker daemon configuration without additional parameters.
# Returns...........: 
#               - 0 (OK): If the Docker daemon is successfully reconfigured and restarted.
#               - 1 (NOK): If there is an error in reconfiguring or restarting the Docker daemon.
##
setup_docker_user_namespaces() {

  log_info "Configuring Docker to use User Namespaces..."

  # Create or modify the Docker daemon configuration file
  DAEMON_CONFIG_FILE="/etc/docker/daemon.json"

  if [ ! -f "$DAEMON_CONFIG_FILE" ]; then
    echo '{}' > "$DAEMON_CONFIG_FILE"
  fi

  if ! jq '. + {"userns-remap": "default"}' "$DAEMON_CONFIG_FILE" > "$DAEMON_CONFIG_FILE.tmp" || 
     ! mv "$DAEMON_CONFIG_FILE.tmp" "$DAEMON_CONFIG_FILE"; then
    log_error "Failed to update Docker daemon configuration for User Namespaces."
    return "$NOK"
  fi

  # Restart the Docker service to apply the changes
  if ! systemctl restart docker; then
    log_error "Failed to restart Docker service after configuring User Namespaces."
    return "$NOK"
  fi

  log_info "Docker configured to use User Namespaces. Service restarted successfully."

  return "$OK"
}


# Run the task to add_docker
task_add_docker-ce