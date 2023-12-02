# Debian knox shield

![Debian Knox Shield Logo](debian-knox-shield-logo.png)


## Description

**Secure your Debian server with ease**

Debian knox shield is a robust and modular tool designed to enhance the security of your Debian server. This build script empowers users to secure their server environments effectively, integrating a suite of customizable scripts and security measures. With Debian Knox Shield, fortify your server against vulnerabilities and tailor the security to your specific needs.

## Context

I developed Debian Knox Shield after subscribing to a VPS server and realizing the scarcity of repositories offering post-installation Debian security scripts that were either not very modular or didn't meet my specific needs. This project is a personal journey into enhancing server security while learning and evolving in the field.

## Installation

1. Clone the repository: `git clone https://github.com/jpagny/debian-knox-shield.git`
2. Make the build script executable: `chmod +x build.sh`
3. Execute the build script: `./build.sh`

## Project Structure

| Dossier   | Sous-Répertoire   | Description |
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



## Contributing

We welcome contributions to Debian Knox Shield! If you're interested in helping out, please follow these steps:

1. **Fork the Repository**: Create your own fork of the repository by clicking the "Fork" button on the GitHub page. This creates a copy of the project in your own GitHub account.

2. **Clone Your Fork**: Clone your fork to your local machine (use `git clone https://github.com/your-username/debian-knox-shield.git`, replacing `your-username` with your GitHub username).

3. **Create a New Branch**: Before making your changes, switch to a new branch in your local repository (e.g., `git checkout -b my-new-feature`).

4. **Make Your Changes**: Implement the changes you want to make in your branch.

5. **Commit Your Changes**: Commit your changes with descriptive commit messages (use `git commit -m "A brief description of the change"`).

6. **Push to Your Fork**: Push your changes to your fork on GitHub (`git push origin my-new-feature`).

7. **Submit a Pull Request**: Go to the original repository on GitHub, and you'll see a prompt to submit a pull request from your new branch. Click the "Compare & pull request" button and submit it with a clear description of your changes.

Please ensure your code adheres to the existing style of the project to make the review process faster.

Thank you for your contributions!


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.txt) file for details.
