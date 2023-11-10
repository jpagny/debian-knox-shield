#!/bin/bash

# Source the execute_task function from the core directory
source "$(dirname "$0")/../core/execute_task.sh"

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