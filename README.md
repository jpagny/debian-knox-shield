# secure-post-install-debian

## Description
The `secure-post-install-debian` project provides a suite of scripts designed to automate the post-installation setup and configuration process for Debian-based systems. These scripts facilitate tasks such as system updates, user creation, and security configurations, ensuring a consistent and secure setup.

## Installation
To get started with `secure-post-install-debian`, follow these steps:

```bash
# Clone the repository
git clone https://github.com/yourrepository/secure-post-install-debian.git

# Navigate to the project directory
cd secure-post-install-debian

Functions
task_update_and_upgrade
Automatically updates and upgrades the system packages. This task is essential to keep the system up-to-date with the latest security patches and software updates.

execute_and_check
Executes given tasks with the option to mark them as 'mandatory' or 'optional'. In case of failure, 'mandatory' tasks will stop the script, while 'optional' tasks allow the script to continue.

append_scripts_from_config
Reads a configuration file and appends the specified scripts to a target script file, which can then be executed as a single, consolidated script.

append_scripts_from_directory
Combines all scripts from a specified directory into a single script file. This is useful for organizing multiple script files into a unified setup script.

Configuration
Configure your setup by modifying the config_file.txt. Each line in this file specifies a script to include in the build process, categorized as 'mandatory' or 'optional'.

Contributing
Contributions to secure-post-install-debian are welcome! Feel free to fork the repository, make changes, and submit pull requests.

License
This project is licensed under the MIT License - see the LICENSE.md file for details.

Acknowledgments
Special thanks to all contributors and users of the secure-post-install-debian project.

Contact Information
For support or queries, please open an issue in the GitHub repository: https://github.com/yourrepository/secure-post-install-debian

