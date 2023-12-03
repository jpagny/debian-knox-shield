# Debian knox shield

![Debian Knox Shield Logo](debian-knox-shield-logo.png)


## Description

**Secure your Debian server with ease**

Debian knox shield is a robust and modular tool designed to enhance the security of your Debian server. This build script empowers users to secure their server environments effectively, integrating a suite of customizable scripts and security measures. With Debian Knox Shield, fortify your server against vulnerabilities and tailor the security to your specific needs.

This software is primarily intended for personal servers, providing users with a powerful solution to protect their personal data and online services.

## Context

I developed Debian Knox Shield after subscribing to a VPS server and realizing the scarcity of repositories offering post-installation Debian security scripts that were either not very modular or didn't meet my specific needs. This project is a personal journey into enhancing server security while learning and evolving in the field.

## Project Structure

| Folder    | Under folder      | Description |
| --------- | ----------------- | ----------- |
| `config/` |                   | Contains default configuration files with tasks organized in the proper procedural order. |
| `core/`   |                   | The core of the project. Modify only if you are certain of the changes. |
| `output/` |                   | Contains the output script post-build, which should be executed on your server. |
| `task/`   |                   | Holds all the scripts. Users can choose which to use, and add their own scripts to the configuration. |
|           | `firewall/`       | Contains all tasks related to firewall management.  |
|           | `network/`        | Contains all tasks related to network management and configuration. |
|           | `scheduler/`      | Contains all tasks related to task scheduling and event management.|
|           | `system/`         | Contains all tasks related to overall system management and configuration. |
|           | `tool/`           | Contains all tools and utilities supporting script development and execution. |
|           | `tool_secure/`    | Contains all tools and utilities specifically designed for enhancing server security. |
|           | `user/`           | Contains all tasks and scripts related to user account management and permissions. |
| `tool/`   |                   | Tools to assist in rapid script development. |

## Installation

### Execution from Debian server

1. Clone the repository: `git clone https://github.com/jpagny/debian-knox-shield.git`
2. Make the build script executable: `chmod +x build.sh`
3. Execute the build script: `./build.sh`
4. Make the generated script executable: `chmod +x output/default_output.sh`
5. Execute the script with root privileges: `sudo ./output/default_output.sh`

### Execution from Local environment

1. Clone the repository: `git clone https://github.com/jpagny/debian-knox-shield.git`
2. Make the build script executable: `chmod +x build.sh`
3. Execute the build script: `./build.sh`
4. If generated from Windows, convert line endings: `dos2unix output/default_output.sh`
5. Transfer the generated script to your server
6. Make the script executable on the server: `chmod +x default_output.sh`
7. Execute the script with root privileges: `sudo ./default_output.sh`

## How it works

The `build.sh` script is designed to assemble all the tasks in the order specified in `conf/default_config.txt`. It reads the configuration file, identifies the tasks listed, and then concatenates them into a single executable script. This process ensures that each task is executed in the correct sequence as defined in the configuration, creating a streamlined and efficient workflow for securing your Debian server.


## How to create custom tasks and configuration

### 1. Creating a Task

To create a task, run the following command from the root of the project: 

```shell
tool/build_task.sh "task_name" "folder_name" "need_prerequisites" "need_post_action"
```

**For example:**

```shell
`tool/build_task.sh "hello_world" "message" true true`
```

This command will create a task in `task/message/hello_world.sh` with a ready-made template that includes prerequisite functions and post-action steps.


```shell
#!/bin/bash

# import
# shellcheck source=/dev/null
source "$(dirname "$0")/../core/00_variable_global.sh"
source "$(dirname "$0")/../core/01_logger.sh"
source "$(dirname "$0")/../core/02_execute_task.sh"
source "$(dirname "$0")/../core/03_utils.sh"

task_hello_world() {
  
  local name="hello_world"
  local isRootRequired=true
  local prereq="check_prerequisites_$name"
  local actions="run_action_$name"
  local postActions="post_actions_$name"
  local task_type=""

  if ! execute_and_check "$name" $isRootRequired "$prereq" "$actions" "$postActions" "$task_type"; then
    log_error "hello_world failed."
    return "$NOK"
  fi

  log_info "hello_world has been successfully hello_worldx."
  
  return "$OK"
}

check_prerequisites_hello_world() {
    # add your prerequisites here
    return "$OK"
}

run_action_hello_world() {
    # add your action here
    echo "hello world !"
    return "$OK"
}

post_actions_hello_world() {
    # add your post action here
    return "$OK"
}

# Run the task to hello_world
task_hello_world
```

The script generated by the `tool/build_task.sh` command will include or exclude certain functions based on the options you specify. 

For instance, if `need_prerequisites` and `need_post_action` are set to `false`, the functions `check_prerequisites_hello_world` and `post_actions_hello_world` will not be included in the script.


### 2. Adding the new task to the configuration

After creating a new task, you need to add it to the configuration file. This can be done either in the default configuration file or in a custom configuration file.

- **Default Configuration**: To add the task to the default configuration, simply insert the task's details into the `default_config.txt` file located in the `config/` directory.

- **Custom Configuration**: If you are using a custom configuration file, add the task's details to your custom file. Ensure that this custom configuration file is correctly referenced when executing your scripts.

</br>

**For example with hello_world task:**

To add the `hello_world` task under the `message` category, you would enter the following line in your configuration file:

```
#Manage message
optional|message/hello_world.sh
```

There are two types of tasks you can specify in the configuration:

- **mandatory**: If this task fails, the entire script execution will stop immediately. Format: `mandatory|path/to/task.sh`
  
- **optional**: If this task fails, the script will continue and proceed to the next task. Format: `optional|path/to/task.sh`

Be sure to follow the correct format and order in the configuration file for the tasks to be recognized and executed correctly.

### 3. Launching the build

Once you have added your new task to the configuration file, the next step is to launch the build script. This script will compile all the tasks and the core into a single executable script.

- **Using the default configuration**: If you are using the default configuration, simply run the command:

```
./build
```

- **Using a custom configuration**: 
If you have a custom configuration, specify the name of your configuration file with the `--config` option when running the build command:

```
./build --config <custom_config_file.txt>
```

Replace `<custom_config_file>` with the name of your custom configuration file.

- **Changing the output location**:
To change the output location, use the `--output` option:

```
./build --output <output_directory>
```
Replace `<output_directory>` with your desired output location.

These commands will use your specified settings to create the final script.

- **Combining options**:
Of course, you can also combine both the `--config` and `--output` options:

```
./build --config <custom_config_file> --output <output_directory>
```

This allows you to use a custom configuration and specify a different output location simultaneously.

These commands will use your specified settings to create the final script.

</br>

---

**⚠️ Caution:**
**be very careful when executing the script. Ensure you have noted down all necessary credentials before restarting or exiting the server. Failure to do so may result in losing access to the server, potentially requiring a complete reformat.**

---

</br>

## List of tasks

Below is a table of tasks included in the Debian Knox Shield project:

| Category  | Task Name | Purpose of Task |
|-----------|-----------|-----------------|
| `system`  | `task_configure_login_password.sh` | This task strengthens password security by updating encryption and password policies in the system's login configuration. |
| `system`  | `task_configure_password_quality.sh` | This task configures enhanced password quality requirements in the system's password management module. It sets criteria such as minimum length, character variety, and retry limits to ensure strong password standards. |
| `system`  | `task_system_disable_root.sh` | This task secures the root account by setting a random hashed password and disabling direct login, effectively enhancing the system's security. |
| `system`| `task_disable_uncommon_file_system` |This task increases system security by disabling several uncommon file systems. It updates the system configuration to prevent the use of these file systems, reducing potential vulnerabilities associated with them. |
| `system` | `task_disable_uncommon_firewire` | This task is designed to enhance system security by disabling certain FireWire drivers. It modifies the system configuration to prevent the use of these FireWire drivers, which are often unnecessary for most systems and can present security risks. |
| `system` | `run_action_disable_uncommon_input_drivers` | This task focuses on securing the system by disabling a variety of uncommon input drivers. The script modifies system configurations to block certain input-related drivers, such as joystick devices, PC speakers, and various sound sequence modules.  |
| `system` | `task_disable_uncommon_network_interfaces` | "This task is aimed at increasing the security of the system by disabling Bluetooth interfaces. The script updates the system configuration to prevent the use of Bluetooth, which is often not needed in a server environment and can pose a security risk. |
| `system` | `task_disable_uncommon_network_protocols` | This task enhances network security by disabling certain uncommon network protocols. The script configures the system to prevent the use of protocols such as DCCP, SCTP, RDS, and TIPC, which are generally not required for standard server operation. |
| `system` | `task_disable_uncommon_sound_drivers` | This task is designed to enhance system security by disabling a set of uncommon sound drivers. It updates the system configuration to block various USB-based sound drivers, which are typically unnecessary for server environments. |
| `system` | `task_harden_file_system_settings` | This task strengthens file system security by configuring enhanced protections for hardlinks and symlinks, thereby reducing vulnerability to certain types of attacks. |
| `system` | `task_harden_kernel_settings` | This task applies a series of security enhancements to the kernel settings. It ensures that crucial kernel parameters are configured to strengthen the system against various types of security threats and vulnerabilities. |
| `system` | `task_harden_network_settings` | This task secures the network configuration by applying various IPv4 security settings, enhancing the system's defense against network-related exploits and vulnerabilities. |
| `system` | `task_secure_sensible_file_permissions` | This task secures key system files by adjusting their ownership to root and setting strict permissions. It focuses on protecting configuration files, cron directories, user home directories, and other sensitive files, ensuring they are not accessible or modifiable by unauthorized users. |
| `system` | `task_update_and_upgrade` | This task automates the process of updating and upgrading the system. |
| `network` | `task_ssh_deactivate_root` | This task enhances SSH security by ensuring the 'PermitRootLogin' setting in the SSH configuration is set to 'no', thereby disabling direct SSH access for the root user. |
| `network` | `task_ssh_random_port` | This task increases SSH security by changing its listening port to a randomly selected port. The script generates a random port number and prompts the user for confirmation before applying the change to the SSH configuration. |
| `user` | `task_add_random_user_password_with_sudo_privileges` | This task creates a new user with sudo privileges. It prompts the user to approve a randomly generated username and password, ensuring these credentials are safely recorded before proceeding. The new user is added to the system with sudo access, enhancing administrative flexibility while maintaining security. |
| `firewall` | `task_ufw_settings` | This task configures the Uncomplicated Firewall (UFW) by setting default policies to deny incoming and outgoing traffic, while specifically allowing HTTP, HTTPS, DNS, and SSH (on the configured port). |
| `scheduler` | `task_sheduler_auto_update_upgrade` | This task sets up and configures automatic updates and upgrades for the system. |
| `tool_secure` | `task_add_fail2ban` | This task configures Fail2Ban with basic settings to protect against unauthorized access, particularly on the SSH service. |
| `tool_secure` | `task_add_knockd` | This task configures port knocking for enhanced SSH security using knockd. It generates random sequences for opening and closing SSH port access, and prompts for user approval of these sequences. Once approved, the sequences are applied to the knockd configuration, creating an additional security layer requiring specific 'knocks' to gain access. |
| `tool` | `task_delete_unnecessary_tools` | This task removes unnecessary or potentially insecure packages, improving system security by eliminating tools that could be exploited. |
| `tool` | `task_add_vim` | This task installs the Vim text editor on the system, providing a versatile and powerful tool for file editing. |


## Contributing

We welcome contributions to Debian Knox Shield! If you're interested in helping out, please follow these steps:

1. **Fork the repository**: Create your own fork of the repository by clicking the "Fork" button on the GitHub page. This creates a copy of the project in your own GitHub account.

2. **Clone your fork**: Clone your fork to your local machine (use `git clone https://github.com/your-username/debian-knox-shield.git`, replacing `your-username` with your GitHub username).

3. **Create a new branch**: Before making your changes, switch to a new branch in your local repository (e.g., `git checkout -b my-new-feature`).

4. **Make your changes**: Implement the changes you want to make in your branch.

5. **Commit your changes**: Commit your changes with descriptive commit messages (use `git commit -m "A brief description of the change"`).

6. **Push to your fork**: Push your changes to your fork on GitHub (`git push origin my-new-feature`).

7. **Submit a pull request**: Go to the original repository on GitHub, and you'll see a prompt to submit a pull request from your new branch. Click the "Compare & pull request" button and submit it with a clear description of your changes.

Please ensure your code adheres to the existing style of the project to make the review process faster.

Thank you for your contributions!


## Credits

A special thanks to:

- [Marek Beckmann](https://github.com/marekbeckmann/Secure-Debian-Script) for the Secure Debian Script.
- [imthenachoman](https://github.com/imthenachoman/How-To-Secure-A-Linux-Server#why-secure-your-server) for their comprehensive guide on securing a Linux server.
- ChatGPT for assistance in developing and documenting this project.

Their contributions and resources have been invaluable in the creation of Debian Knox Shield.


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.txt) file for details.
