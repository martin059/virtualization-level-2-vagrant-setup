# Second and Third virtualization levels

This repository contains two of the main project's three levels. The first level, which is stored in a separate repository, is not included here. Each virtualization level has its own specific role.

This section of the project is based on a [Vagrant](https://www.vagrantup.com/) virtual machine (VM) provisioned with an [Ansible](https://www.ansible.com/) playbook.

## Table of Contents

- [Second and Third virtualization levels](#second-and-third-virtualization-levels)
  - [Table of Contents](#table-of-contents)
- [1. Second Virtualization level: Vagrant set up script](#1-second-virtualization-level-vagrant-set-up-script)
  - [1.1. Ansible playbook for second level](#11-ansible-playbook-for-second-level)
- [2. Third Virtualization level: Resource monitoring](#2-third-virtualization-level-resource-monitoring)
  - [2.1. Ansible playbook for third level](#21-ansible-playbook-for-third-level)
- [3. Working with the project](#3-working-with-the-project)
  - [3.1. Getting Started](#31-getting-started)
  - [3.2. Customization](#32-customization)
    - [3.2.1. Customization for the second level](#321-customization-for-the-second-level)
    - [3.2.2. Customization for the third level](#322-customization-for-the-third-level)
  - [3.3. Working with Vagrant](#33-working-with-vagrant)
    - [3.3.1. How to re-provision an existing VM](#331-how-to-re-provision-an-existing-vm)
    - [3.3.2. What is the MVP Vagrant?](#332-what-is-the-mvp-vagrant)
  - [3.4. Known issues](#34-known-issues)
  - [3.5. Fixes and Workarounds](#35-fixes-and-workarounds)
- [4. Glossary](#4-glossary)


# 1. Second Virtualization level: Vagrant set up script

This section of the project contains the necessary scripts for automatically deploying and provisioning a virtual machine (VM) capable of developing and running the Sample App for the [first virtualization level](https://github.com/martin059/vitualization-level-1-prototype-app).

The second level's role is to provide a way to quickly create and configure lightweight, reproducible, and portable development and demo environments using [Ansible](https://www.ansible.com/) playbooks and roles. The environment can be brought up and managed using [Vagrant](https://www.vagrantup.com/).

The VM is built on top of the [AlmaLinux](https://almalinux.org/) 9's [official vagrant box](https://app.vagrantup.com/almalinux/boxes/9), using the _currently released version_.

A VM can be raised with the following software components:

 - [Ansible](https://www.ansible.com/)
 - [Docker](https://www.docker.com/) (including [Docker-Compose](https://docs.docker.com/compose/))
 - [NodeJs](https://nodejs.org/en) (including [npm](https://www.npmjs.com/))
 - [Git](https://git-scm.com/downloads) (including [GitHub CLI](https://cli.github.com/))
 - [X11 Forwarding](https://www.x.org/wiki/)
 - [PgAdmin](https://www.pgadmin.org/)
 - [Visual Studio Code](https://code.visualstudio.com/)
 - [Postman](https://www.postman.com/)
 - [Z Shell](https://www.zsh.org/) (including [Oh My Zsh](https://ohmyz.sh/))

**Note:** There are more roles but those will be mentioned in the [Third level](#21-ansible-playbook-for-third-level).

Unless explicitly mentioned in the component's Ansible playbook, the latest stable version of each software component will be pulled from their respective repositories. Otherwise, a specific version will be pulled (for example, the latest stable Postman v9.x is used instead of the current default v10.x). For more details, see the [Ansible playbook](#11-ansible-playbook-for-second-level) section.

Some of the aforementioned components are optional and can be skipped if the user wants to make their VM as light as possible, including only the minimum required components. For more details on customization, see the [Customization for the second level](#321-customization-for-the-second-level) section.

## 1.1. Ansible playbook for second level

The Ansible playbook defines a set of tasks to be executed on the VM to automatically configure and provision it with the desired components. It includes a list of roles, each representing a different responsibility or function.

In this case, the defined roles are:

- `vagrant`: Copies files from the Host's folder to the VM itself, specially things like `ssh` keys, `bash` scripts and `Ansible` scripts. It also sets the VM's time zone.
- `developer`: Sets the VM with useful development tools such as [Vim](https://www.vim.org/), [ack](https://linux.die.net/man/1/ack) or [curl](https://linux.die.net/man/1/curl) among others. And it also sets the `git`'s configuration.
- `zsh`: Provisions `ZSH`.
- `zsh-omz`: Provisions `OMZ`, sets it as the default shell and configures [ys](https://github.com/martin059/virtualization-level-2-vagrant-setup/blob/master/ansible/roles/zsh-omz/files/ys.zsh-theme) as the default theme.
- `ghcli`: Optionally provisions `GH` and configures it with the access token that the user provided.
- `docker`: Optionally provisions `Docker` and `Docker-Compose`. Then, it sets the `docker` service to start automatically with the VM and adds the `vagrant` user to its permissions group so it can execute `docker` commands without root privileges.
- `nodejs`: Optionally provisions `Nodejs` and `npm`.
- `x11`: Provisions all required dependencies and configurations for `X11 Forwarding` functionality.
- `pgadmin`: Optionally provisions `PgAdmin`. It depends on the previous provisioning of the `docker` role. If that role was not provisioned before, Ansible will trigger the provisioning of the dependency before continuing with `PgAdmin`. This component is exposed as a web service that can be accessed at http://localhost:80/ with the credentials: `user@domain.com`//`abc123`.
- `vscode`: Optionally provisions `Visual Studio Code`. It requires the `x11` role was previously executed. Once installed, it can be invoked with the command `code`.
- `postman`: Optionally provisions `Postman`. It requires the `x11` role was previously executed. Once installed, it can be invoked with the command `postman` (there is a known issue with the graphical library dependencies, for more details read the [known issues](#34-known-issues) section).

Optional roles are executed by enabling the specific roles through the [custom](#32-customization) file if they are not [enabled by default](#332-what-is-the-mvp-vagrant).

# 2. Third Virtualization level: Resource monitoring

This section of the project contains the necessary Ansible playbooks for automatically provisioning a [Prometheus](https://prometheus.io/) (with [Node Exporter](https://github.com/prometheus/node_exporter)) service on a VM. Prometheus is used to monitor the VM's resource utilization, such as CPU load. The project also includes a [Grafana](https://grafana.com/) instance. The Grafana instance uses the data provided by the Prometheus service to populate a dashboard. This dashboard can display resource utilization data and Grafana can send customizable alerts.

The third level's role is to provide a way to register, monitor, and control a machine's resource utilization. This can be useful in cases where the consumption of these resources incurs a cost, such as a VM running in a cloud service or a continuous deployment node that should not remain blocked for an extended period of time.

In the default use case of this project, Grafana monitors the Vagrant VM's CPU load and alerts an external service like [Slack](https://slack.com/intl/en-gb/) if the load exceeds 20% for at least 20 seconds.

## 2.1. Ansible playbook for third level

This level includes the following Ansible roles, which build upon those described in the [Second level's section](#11-ansible-playbook-for-second-level):

- `prometheus`: Optionally provisions a `Prometheus` service. It downloads, installs and configures the service to start when the VM boots. It also downloads, installs and configures `Node Exporter`.
- `grafana`: Optionally provisions a `Grafana` instance tries to configure it with base configuration file. It depends on the previous provisioning of the `docker` role. If that role was not provisioned before, Ansible will trigger the provisioning of the dependency before continuing with `Grafana`. This component is exposed as a web service that can be accessed at http://localhost:3334/ with the credentials: `admin`//`admin`.

Optional roles are executed by enabling the specific roles through the [custom](#32-customization) file if they are not [enabled by default](#332-what-is-the-mvp-vagrant).

# 3. Working with the project

## 3.1. Getting Started

Before starting the actual process of raising the VM through `Vagrant`, the host machine must have all necessary dependencies to run `Vagrant` itself, `VirtualBox` and the VM proper.

**Note:** Although the standard Windows Command Prompt may be used, it is recommended to use either [Cygwin](https://cygwin.com) or [MSYS2](https://msys2.github.io) (Git Bash works as well) for proper terminal emulation through Mintty. `Vagrant` used to require a SSH binary installed on Windows, but for version 2.0 onwards it is built-in.

1. Download and install [Vagrant](https://www.vagrantup.com/downloads.html). Latest version should be fine, in case an unexpected trouble appears, try version 2.4.1 which at the time of this writing is the latest confirmed working.

2. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads). Latest version should be fine, in case an unexpected trouble appears, try version 7.0.14 which at the time of this writing is the latest confirmed working.

3. Clone this repository (`git clone <url>`)
4. Go into the new directory (`cd virtualization-level-2-vagrant-setup`)
5. Optional steps: 
    - Configure the `Vagrantfile` file to modify any exposed ports, the VM's CPU and memory resources and other aspects.
    - Add personal `ssh` private and public keys (`id_*`) to `ssh` folder. The copied keys must have been added to the user's GitHub account. They will automatically be copied to the right location when provisioning the VM.
    - Create a `ansible/group_vars/all/custom` file (an example can be found in [`custom_example`](EXAMPLE_custom) at the root of the repository) with the desired customizations (read [this section](#32-customization) for more details).
6. Bring up the VM: (`vagrant up`). This will provision the VM the first time it is launched, including downloading and installing all components, so it might take some minutes to complete, please be patient.

Once these steps are done, skip to the [Working with Vagrant](#33-working-with-vagrant) section.

**Note:** During `vagrant up`, a port collision error will occur if the ports defined in the `Vagrantfile` conflict with a service already running on the host machine. To resolve this, change the port mappings in the `Vagrantfile`.

## 3.2. Customization

The provisioning process may be customized to determine whether some components are installed or not, and also to make some environment customizations for the user such as the Git username/email configuration or whether to install certain components or tools.

**Note:** By default, the `Vagrantfile` and the `Ansible` playbook are configured to set up the "Minimum Viable Product (MVP) Vagrant". For more details read the [What is the MVP Vagrant?](#332-what-is-the-mvp-vagrant) section.

To customize the provisioning process, it is needed to create a `provision/ansible/group_vars/all/custom` file (an example can be found in [`custom_example`](EXAMPLE_custom) at the root of the repository).

### 3.2.1. Customization for the second level

For the functionality related to the second level's role, the user can define the following variables:

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

If the customization needs to be modified after the initial provisioning process and/or some dependencies have had a newer version released, this can be done automatically. For more details read the [How to re-provision an existing VM](#331-how-to-re-provision-an-existing-vm) section.

### 3.2.2. Customization for the third level

For the functionality related to the third level's role, the user can define the following variables:

- `install_prometheus`: To install `Prometheus` and `Node Exporter`. It is set to `yes` by default.
- `install_grafana`: To install `Grafana` and its pre-made configuration. It is set to `yes` by default.
- `grafana_config_pwd`: Secret password that the will be used to decipher the encrypted zip file that contains the pre-made configuration for `Grafana` which contains a private Slack webhook in it. It is empty by default.

**Note:** Currently, there is a known issue for the provisioning of the `Grafana` configuration. If the user wants to install it but does not provide the correct password in `grafana_config_pwd` the Ansible playbook will fail and leave the Grafana instance with the default settings of a brand new instance. For more details, read the [known issues](#34-known-issues) section.

If the customization needs to be modified after the initial provisioning process and/or some dependencies have had a newer version released, this can be done automatically. For more details read the [How to re-provision an existing VM](#331-how-to-re-provision-an-existing-vm) section.

## 3.3. Working with Vagrant

Once the VM is up and running, one can run `vagrant ssh` to log into it, or it can also be done manually with `ssh -p <port-number> vagrant@127.0.0.1` (the port number is usually _2222_, but it might change if multiple VMs are running at the same time). The appropriate SSH client configuration can be seen by running `vagrant ssh-config`. The default passwords for `root` and `vagrant` users is `vagrant` (as usual for Vagrant boxes).

**Note:** If the `vagrant ssh` command is being executed in Mintty (Cygwin/MSYS2/Git Bash terminal emulator) instead of the standard Windows console host, it is also needed to define the `VAGRANT_PREFER_SYSTEM_BIN` environment variable and set it to `1`, e.g. by adding `export VAGRANT_PREFER_SYSTEM_BIN=1` to the `~/.bashrc` file (`~/.zshrc` if using ZSH). Otherwise Vagrant will use its built-in SSH client which is meant for the Windows console and can cause trouble with other terminal implementations.

Afterwards, the VM is ready to be used as normal Linux machine that can be accessed through Secure Shell (SSH) protocol.

**Note:** In its current state, the Ansible playbook doesn't have the necessary commands to automatically provision a Desktop Environment (DE). Any applications that have their own Graphical User Interface (GUI), such as _Visual Studio Code_ for example, can be accessed thanks to the `X11 Forwarding` functionality that is provisioned automatically the first time the VM is launched. For more details, read the [Ansible playbook](#11-ansible-playbook-for-second-level) section.

Finally, once the VM is no longer needed, or the user wants to "shut it down", they can do the following:

- Manage the VM through `VirtualBox`'s GUI as any other common VM.
- Use the command `vagrant halt` to shut it down (use `vagrant halt -f` to force it).
- Use the command `vagrant destroy` to undefine the VM entirely, also deleting any associated virtual drives it might have (use `vagrant destroy -f` to force it). This is **irreversible** and all information on the VM's drive will be lost.

**Note:** The command `vagrant up` can also be used to re-start a previously shutdown vagrant VM.

### 3.3.1. How to re-provision an existing VM

If the user wants Vagrant to re-run the Ansible playbook to check if any package and/or component can be updated or re-installed, it can be done with the command `vagrant provision`.

Also, if the user has made any changes to the `custom` file to install a new component as it is described in the [customization](#32-customization) section, the user can execute the `vagrant provision` command to make these changes effective.

**Note:** Currently, the Ansible playbook lacks the commands to automatically uninstall any previously provisioned components that are no longer required. All uninstall processes should be done manually by the user for predictable results.

**Note:** It is advised to close any SSH sessions that were opened before executing the `vagrant provision` command. Old SSH sessions may not have the newly set environment variables. For example, if a new GitHub access token is introduced via `vagrant provision`, it will not be available in any old session.

### 3.3.2. What is the MVP Vagrant?

The Minimum Viable Product Vagrant, or MVP Vagrant, refers to the vagrant with the minimum required software to run:

- The Sample App made for the [first virtualization level](https://github.com/martin059/vitualization-level-1-prototype-app) 
- A instance coupled with Prometheus to monitor the Vagrant VM's CPU usage.
- A Few dependencies to improve the user-experience.

It includes:
- `Ansible`: as it is required to provision the VM itself.
- `Docker`, `Docker-Compose`, `NodeJs` and `npm`: as they are required for compiling and running the Sample App itself.
- `ZSH` and `OMZ`: Both are lightweight additional components that add color to the terminal.
- `x11 Forwarding`: Lightweight components that can be very useful in the lack of a DE.
- `git`: Git is also installed but only with the `git_recommended_config` settings. The provision will lack the necessary elements to interact with any private GitHub repository unless the user goes through a login process and/or configures the Git authentication manually.
- `Prometheus`, `Node Exporter` and `Grafana`: they are required for monitoring the VM resource consumption.

Also, the following ports are exposed by default:
- `80`: It is reserved for the optional PgAdmin app.
- `5001`: It is reserved for the Sample App's Python API.
- `5002`: It is reserved for the Sample App's Svelte App.
- `3334`: It is reserved for the Grafana's instance.
- `9091`: It is reserved for the Prometheus GUI.
- `9191`: It is reserved for the Node Exporter GUI.

Those ports can be modified in the `Vagrantfile` as it is explained in the [Getting Started](#31-getting-started) section in the _Optional steps_ subsection.

## 3.4. Known issues

This section contains all currently known issues for the second and third levels of the project. Each have their respective GitHub issue opened in the repository with the `bug` tag.

Most of them have manual fixes and/or workarounds which are described in the [Fixes and Workarounds](#35-fixes-and-workarounds) section.

- **Postman's GUI issue**: the postman app will not be capable of importing an internal collection due to a graphical bug were the file explorer windows that window cannot be interacted with. Related issue: https://github.com/martin059/virtualization-level-2-vagrant-setup/issues/37.
- **Grafana might be unreachable after provisioning**: Sometimes when Ansible provisions the configuration for the Grafana container instance, the service is left in a bad state and keeps restarting over and over unless manually stopped. Related issue: https://github.com/martin059/virtualization-level-2-vagrant-setup/issues/54.
- **Missing default pre-made grafana configuration**: The Ansible playbook's task that provisions the Grafana configuration will fail if a correct password is not given to decrypt the pre-made configuration. Related issue: https://github.com/martin059/virtualization-level-2-vagrant-setup/issues/55.

## 3.5. Fixes and Workarounds

This section contains the currently known manual fixes and/or workarounds for the [known issues](#34-known-issues).

- **Workaround for Postman's GUI issue**, which prevents the importing an internal collection:
  1. In the import menu: instead of `File`, select the `Link` tab.
  2. Copy the URL to the **raw** file of the postman collection from [its repository](https://github.com/martin059/virtualization-level-1-prototype-app/blob/master/postman_testing_requests/testing-postman-collection.json).
  3. Click on `Continue`
- **Manual fix for Grafana being unreachable**, starting from a newly established SSH session to the `vagrant` user, execute the following commands in order:
  1. `cd grafana/`
  2. `docker compose down -v`
  3. `sudo rm -f initialConfig/grafana.db` (This is to prevent a prompt asking confirmation to  rewrite the file)
  4. `docker compose up -d`
  5. `sudo bash /home/vagrant/utils/grafanaUtils/restoreConfig.sh /home/vagrant/grafana/initialConfig/ <grafana_config_pwd>`
- **Missing default pre-made grafana configuration**: The user will have to manually configure Grafana through its GUI.

# 4. Glossary

- VM: Virtual Machine
- MVP: Minimum Viable Product
- DE: Desktop Environment
- GUI: Graphical User Interface
- GH: GitHub CLI
- ZSH: Z Shell
- OMZ: Oh My Zsh
