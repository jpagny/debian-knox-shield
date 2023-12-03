#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

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

run_action_add_docker-ce() {

  log_info "Securing the Docker installation..."

  # Find the non-root user with UID 1000
  local docker_user=$(awk -F: '$3 == 1000 && $1 != "root" {print $1}' /etc/passwd)

  while true; do
    # Check if a user was found and confirm to add
    if [ -n "$docker_user" ]; then
      read -p "Add user $docker_user to the Docker group? [Y/n] " response
      case $response in
        [Nn]* ) docker_user="";;
          * ) break;;
        esac
      fi

      # Ask for a different user if initial user is not confirmed
      if [ -z "$docker_user" ]; then
        read -p "Enter the username to add to the Docker group: " docker_user
        if getent passwd "$docker_user" > /dev/null; then
          break
        else
          log_error "User $docker_user does not exist. Please try again."
          docker_user=""
        fi
      fi
    done

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