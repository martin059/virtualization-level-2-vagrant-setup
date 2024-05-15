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

    config.vm.graceful_halt_timeout = 300
    config.ssh.username = "root"

  end
end
