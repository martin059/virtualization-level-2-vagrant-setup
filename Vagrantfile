# -*- mode: ruby -*-
# vi: set ft=ruby :

# The following file defines the defaults values for the VM
require File.join(__dir__, 'defaults.rb')

Vagrant.configure("2") do |config|
  config.vm.box = $box


  config.vm.define :vagrant
  config.vm.provider :virtualbox do |v|

    vbox_version = VagrantPlugins::ProviderVirtualBox::Driver::Meta.new.version
    if Gem::Version.new(vbox_version.strip) < Gem::Version.new('7.0.8')
      abort "VirtualBox 7.0.8 or higher is required"
    end

    v.memory = $defaultMemory
    v.cpus = $defaultCPUs

  end
  
  config.vm.graceful_halt_timeout = 100
  # config.ssh.forward_x11 = true
  
  config.vm.provision :ansible_local do |ansible|
    ansible.compatibility_mode = "2.0"
    ansible.playbook_command = "ANSIBLE_LOG_PATH=/vagrant/ansible.log ANSIBLE_STDOUT_CALLBACK=yaml ansible-playbook"
    ansible.provisioning_path = "/vagrant/ansible"
    ansible.playbook = "playbook.yml"
    ansible.verbose = true
  end
end
