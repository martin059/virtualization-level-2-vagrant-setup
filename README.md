# Second Virtualization level: Vagrant set up script

This project contains the required scripts for automatically deploying and provisioning a Virtual Machine (VM) capable of developing and running the Sample App made for the [1st virtualization level](https://github.com/martin059/vitualization-level-1-prototype-app).

The aim of this project is to provide a way to quickly create and configure lightweight, reproducible, and portable development and demo environments using [Ansible](https://www.ansible.com/) playbooks and roles. The environment can be brought up and managed using [Vagrant](https://www.vagrantup.com/).

The VM is built on top of the [AlmaLinux](https://almalinux.org/) 9's [official vagrant box](https://app.vagrantup.com/almalinux/boxes/9), using the _currently released version_.

A VM can be raised with the following software components:

 - [Ansible](https://www.ansible.com/)
 - [Docker](https://www.docker.com/) (including [Docker-Compose](https://docs.docker.com/compose/))
 - [NodeJs](https://nodejs.org/en) (including [npm](https://www.npmjs.com/))
 - [Git](https://git-scm.com/downloads) (including [GitHub CLI](https://cli.github.com/))
 - [X11 Fowarding](https://www.x.org/wiki/)
 - [PgAdmin](https://www.pgadmin.org/)
 - [Visual Studio Code](https://code.visualstudio.com/)
 - [Postman](https://www.postman.com/)
 - [Z Shell](https://www.zsh.org/) (including [Oh My Zsh](https://ohmyz.sh/))

Unless it is explicitly mentioned in the component's `Ansible` playbook, the latest stable version of each software component will be pulled from their respective repository, otherwise a specific version will be pulled instead (for example, latest stable `postman` v9.x is used instead of the current default v10.x). For more details, see the [Ansible playbook](#ansible-playbook) section.

Some of the aforementioned components are optional and can be skipped if the user wants to make their VM as light as possible with it having only the minimum required components, see [how to customize the solution](#how-to-customize-the-solution) section for more details.

## Getting Started

Before starting the actual process of raising the VM through `Vagrant`, the host machine must have all necessary dependencies to run `Vagrant` itself, `VirtualBox` and the VM proper.

**Note:** Although the standard Windows Command Prompt may be used, it is recommended to use either [Cygwin](https://cygwin.com) or [MSYS2](https://msys2.github.io) (Git Bash works as well) for proper terminal emulation through Mintty. `Vagrant` used to require a SSH binary installed on Windows, but version 2.0 onwards it is built-in.

1. Download and install [Vagrant](https://www.vagrantup.com/downloads.html). Latest version should be fine, in case an unexpected trouble appears, try version 2.4.1 which at the time of this writing is the latest confirmed working.

2. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads). Latest version should be fine, in case an unexpected trouble appears, try version 7.0.14 which at the time of this writing is the latest confirmed working.

3. Clone this repository (`git clone <url>`)
4. Go into the new directory (`cd virtualization-level-2-vagrant-setup`)
5. Optional steps: 
    - Configure the `Vagrantfile` file to modify any exposed ports, the VM's CPU and memory resources and other aspects.
    - Add personal `ssh` private and public keys (`id_*`) to `ssh` folder. The copied keys must have been added to the user's GitHub account. They will automatically be copied to the right location when provisioning the VM.
    - Create a `ansible/group_vars/all/custom` file (an example can be found in [`custom_example`](EXAMPLE_custom) at the root of the repository) with the desired customizations (read [this section](#customization) for more details).
6. Bring up the VM: (`vagrant up`). This will provision the VM the first time it is launched, including downloading and installing all components, so it might take some minutes to complete, please be patient.

Once these steps are done, skip to the [Working with Vagrant](#working-with-vagrant) section.

**Note:** During `vagrant up`, a port collision error will occur if the ports defined in the `Vagrantfile` conflict with a service already running on the host machine. To resolve this, change the port mappings in the `Vagrantfile`.

## Customization

The provisioning process may be customized to determine whether some components are installed or not, and also to make some environment customizations for the user such as the Git username/email configuration or whether to install certain components or tools.

**Note:** By default, the `Vagrantfile` and the `Ansible` playbook are configured to set up the "Minimum Viable Product (MVP) Vagrant". For more details read the [What is the MVP Vagrant?](#what-is-the-mvp-vagrant) section.

To customize the provisioning process, it is needed to create a `provision/ansible/group_vars/all/custom` file (an example can be found in [`custom_example`](EXAMPLE_custom) at the root of the repository).

In there the user can define some variables such as:

- `git_user_name` and `git_user_email`: To set the user's Git name and email automatically during VM's provisioning. Both parameters are empty by default.
- `git_user_signingkey_name`: Name of the user's private key that must be provided in the repository's `ssh` folder, this will automatically link the key to the user in Git's configuration. It is empty by default.
- `git_recommended_config`: To automatically apply some recommended Git configurations such as rebasing instead of merging by default when pulling or automatically stashing the changes before rebasing. This is applied by default, but can be skipped by setting it to `no`.
- Set the following parameters to `yes` to install them, or set them to `no` to skip them:
    - `install_nodejs`: To install `NodeJs` and `npm`. It is set to `yes` by default.
    - `install_docker`: To install `Docker` and `Docker-Compose`. It is set to `yes` by default.
    - `install_pgadmin`: To install `pgAdmin`. The `pgAdmin` component requires the installation of `Docker`. So if `install_pgadmin` is set to `yes`, it will override the `install_docker` parameter to be effectively also set to `yes`. It is set to `no` by default.
    - `install_vscode`: To install `Visual Studio Code`. It is set to `no` by default.
    - `install_postman`: To install `Postman`. It is set to `no` by default.
    - `install_ghcli`: To install `GitHub CLI`. It is set to `no` by default.
- `ghcli_token`: If `install_ghcli` is set to `yes`, the user can add their own [GitHub access token](https://docs.github.com/en/enterprise-server@3.12/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) so it can be automatically set during VM's provisioning. It is empty by default.

If the customization needs to be modified after the initial provisioning process and/or some depedencies have had a newer version released, this can be done automatically. For more details read the [How to re-provision an existing VM](#how-to-re-provision-an-existing-vm) section.

## Working with Vagrant

Once the VM is up and running, one can run `vagrant ssh` to log into it, or it can also be done manually with `ssh -p <port-number> vagrant@127.0.0.1` (the port number is usually _2222_, but it might change if multiple VMs are running at the same time). The appropriate SSH client configuration can be seen by running `vagrant ssh-config`. The default passwords for `root` and `vagrant` users is `vagrant` (as usual for Vagrant boxes).

**Note:** If the `vagrant ssh` command is being runned in Mintty (Cygwin/MSYS2/Git Bash terminal emulator) instead of the standard Windows console host, it is also needed to define the `VAGRANT_PREFER_SYSTEM_BIN` environment variable and set it to `1`, e.g. by adding `export VAGRANT_PREFER_SYSTEM_BIN=1` to the `~/.bashrc` file (`~/.zshrc` if using ZSH). Otherwise Vagrant will use its built-in SSH client which is meant for the Windows console and can cause trouble with other terminal implementations.

Afterwards, the VM is ready to be used as normal Linux machine that can be accessed through Secure Shell (SSH) protocol.

**Note:** In its current state, the `Ansible` playbook doesn't have the necessary commands to automatically provision a Desktop Environment(DE). Any applications that have their own Graphical User Interface (GUI), such as `Visual Studio Code` for example, can be accessed thanks to the `X11 Forwarding` functionality that is provisioned automatically the first time the VM is launched. For more details, read the [Ansible playbook](#ansible-playbook) section.

Finally, once the VM is no longer needed, or the user wants to "shut it down", they can do the following:

- Manage the VM through `VirtualBox`'s GUI as any other common VM.
- Use the command `vagrant halt` to shut it down (use `vagrant halt -f` to force it).
- Use the command `vagrant destroy` to undefine the VM entirely, also deleting any associated virtual drives it might have (use `vagrant destroy -f` to force it).

**Note:** The command `vagrant up` can also be used to re-start a previously shutdown vagrant VM.

### How to re-provision an existing VM

If the user wants `Vagrant` to re-run the `Ansible` playbook to check if any package and/or component can be updated or re-installed, it can be done with the command `vagrant provision`.

Also, if the user has made any changes to the `custom` file to install a new component as it is stated in the [customization](#customization) section, the user can execute the `vagrant provision` command to make these changes effective.

**Note:** Currently, the `Ansible` playbook lacks the commands to automatically uninstall any previously provisioned components that are no longer required.
**Note:** It is advised to close any SSH sessions that were opened before executing the `vagrant provision` command. Old SSH sessions may not have the newly set environment variables. For example, if a new GitHub access token is introduced via `vagrant provision`, it will not be available in any old session.

### What is the MVP Vagrant?

The Minimum Viable Product Vagrant, or MVP Vagrant, refers to the vagrant with the minimum required software to run the Sample App made for the [1st virtualization level](https://github.com/martin059/vitualization-level-1-prototype-app) plus a few light dependencies to improve the user-experience.

It includes:
- `Ansible`: as it is required to provision the VM itself.
- `Docker`, `Docker-Compose`, `NodeJs` and `npm`: as they are required for compiling and running the Sample App itself.
- `ZSH` and `OMZ`: Both are lightweight additional components that add color to the terminal.
- `x11 forwarding`: Lightweight components that can be very useful in the lack of a DE.
- `git`: Git is also installed but only with the `git_recommended_config` settings. The provision will lack the necessary elements to interact with any private GitHub repository unless the user goes through a login process and/or configures the Git authentication manually.

Also, the following ports are exposed by default:
- `80`: It is reserved for the optional `PgAdmin` app.
- `5001`: It is reserved for the Sample App's `Python API`.
- `5002`: It is reserved for the Sample App's `Svelte App`.

Those ports can be modified in the `Vagrantfile` as it is explained in the [Getting Started](#getting-started) section in the _Optional steps_ subsection.


## Ansible playbook

The Ansible playbook defines a set of tasks to be executed on the VM so it can be automatically configured and provisioned with the desired components. It has a list of roles that represent different responsibilities or functions.

In this particular case, the defined roles are:

- `vagrant`: Copies files from the Host's folder to the VM itself, specially things like `ssh` keys, `bash` scripts and `Ansible` scripts. It also sets the VM's time zone.
- `developer`: Sets the VM with useful development tools such as [Vim](https://www.vim.org/), [ack](https://linux.die.net/man/1/ack) or [curl](https://linux.die.net/man/1/curl) among others. And it also sets the Git's configuration.
- `zsh`: Provisions ZSH.
- `zsh-omz`: Provisions OMZ, sets it as the default shell and configures [ys](https://github.com/martin059/virtualization-level-2-vagrant-setup/blob/master/ansible/roles/zsh-omz/files/ys.zsh-theme) as the default theme.
- `ghcli`: Optionally provisions GH and configures it with the access token that the user provided.
- `docker`: Optionally provisions `Docker` and `Docker-Compose`. Then, it sets the `docker` service to start automatically with the VM and adds the `vagrant` user to its permissions group so it can execute `docker` commands without root privileges.
- `nodejs`: Optionally provisions `Nodejs` and `npm`.
- `x11`: Provisions all required dependencies and configurations for `X11 Forwarding` functionality.
- `pgadmin`: Optionally provisions `PgAdmin`. It depends on the previous provisioning of the `docker` role. If that role wasn't provisioned before, `Ansible` will trigger the provisioning of the dependency before continuing with `PgAdmin`. This component is exposed as a web service that can be accessed at http://localhost:80/ with the credentials: `user@domain.com`//`abc123.`.
- `vscode`: Optionally provisions `Visual Studio Code`. It requires the `x11` role was previously executed. Once installed, it can be invoked with the command `code`.
- `postman`: Optionally provisions `Postman`. It requires the `x11` role was previously executed. Once installed, it can be invoked with the command `postman` (ignore any error/warning messages that might appear on the terminal notifying that a graphic library is missing).

Optional roles are executed by enabling the specific roles through the [custom](#customization) file if they are not [enabled by default](#what-is-the-mvp-vagrant).

## Glossary

- VM: Virtual Machine
- MVP: Minimum Viable Product
- DE: Desktop Environment
- GUI: Graphical User Interface
- GH: GitHub CLI
- ZSH: Z Shell
- OMZ: Oh My Zsh
