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

  # install software-properties-common package
  if ! install_package "software-properties-common"; then
    return "$NOK"
  fi

  # Add Docker’s official GPG key
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  # Verify the fingerprint
  local fingerprint=$(apt-key fingerprint 0EBFCD88 | grep -c "9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88")
  if [ "$fingerprint" -ne 1 ]; then
    log_error "The GPG key fingerprint is not valid."
    return "$NOK"
  fi

  # Set up the stable repository
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

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
# Description.......: Secures the Docker installation by adding a non-root user to the Docker group. This function 
#                     first attempts to find a non-root user with UID 1000 and asks for confirmation to add this user 
#                     to the Docker group. If the user declines or no such user exists, it prompts for a username 
#                     and adds the specified user to the Docker group, enhancing security by allowing Docker commands 
#                     to be run without root privileges.
# Parameters........: 
#               - None. The function interacts with the user for input when necessary.
# Returns...........: 
#               - 0 (OK): If a user is successfully added to the Docker group.
#               - 1 (NOK): If the process fails, including user not existing or issues in modifying the Docker group.
##
run_action_add_docker-ce() {

  log_info "Securing the Docker installation..."

  # Step 1: Get a new username
  local new_user=$(ask_for_username_approval)

  # Step 2: Get a password for the new user
  local user_password=$(ask_for_password_approval)

  # Step 3: Create the user with the provided password
  log_info "Creating user $new_user..."
  useradd -m -p "$(openssl passwd -1 "$user_password")" "$new_user"
  if [ $? -ne 0 ]; then
    log_error "Failed to create user $new_user."
    return "$NOK"
  fi

  # Step 4: Add the new user to the Docker group
  # Create Docker user group, if not already exists
  if ! getent group docker > /dev/null; then
    groupadd docker
  fi

  # Add the confirmed or provided user to the Docker group
  if ! usermod -aG docker "$docker_user"; then
    log_error "Failed to add $docker_user to the Docker group."
    return "$NOK"
  fi

  log_info "User $new_user has been added to the Docker group successfully."

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

  return "$OK"
}

# Run the task to add_docker
task_add_docker-ce