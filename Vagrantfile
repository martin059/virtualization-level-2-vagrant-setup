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

#    config.vm.network :forwarded_port, guest: 80, host_ip: "127.0.0.1", host: 80, id: "PgAdmin"
#    config.vm.network :forwarded_port, guest: 3000, host_ip: "127.0.0.1", host: 3333, id: "Grafana"
#    config.vm.network :forwarded_port, guest: 3001, host_ip: "127.0.0.1", host: 3001, id: "App debug"
#    config.vm.network :forwarded_port, guest: 5001, host_ip: "127.0.0.1", host: 5001, id: "Python API"
#    config.vm.network :forwarded_port, guest: 5002, host_ip: "127.0.0.1", host: 5002, id: "Svelte App"
#    config.vm.network :forwarded_port, guest: 9090, host_ip: "127.0.0.1", host: 9090, id: "Prometheus"
    config.vm.network :forwarded_port, guest: 9090, host_ip: "127.0.0.1", host: 9091, id: "Prometheus"
#    config.vm.network :forwarded_port, guest: 9093, host_ip: "127.0.0.1", host: 9093, id: "Alert Manager"

  end
  
  config.vm.graceful_halt_timeout = 100
  config.ssh.forward_x11 = true
  
  config.vm.provision :ansible_local do |ansible|
    ansible.compatibility_mode = "2.0"
    ansible.playbook_command = "ANSIBLE_LOG_PATH=/vagrant/ansible.log ANSIBLE_STDOUT_CALLBACK=yaml ansible-playbook"
    ansible.provisioning_path = "/vagrant/ansible"
    ansible.playbook = "playbook.yml"
    ansible.verbose = true
  end
end
