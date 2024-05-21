# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

$box = "almalinux/9"

begin
  custom = YAML::load_file(File.join(__dir__, 'ansible/group_vars/all/custom'))
  $install_docker = custom['install_docker'] == true
  $install_nodejs = custom['install_nodejs'] == true
  $install_vscode = custom['install_vscode'] == true
  $install_postman = custom['install_postman'] == true
  $install_pgadmin = custom['install_pgadmin'] == true
  $install_ghcli = custom['install_ghcli'] == true
rescue
  $install_docker = true
  $install_nodejs = true
end

$defaultCPUs = 4
$defaultMemory = 4 * 1024
