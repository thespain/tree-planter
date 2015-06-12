# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "genebean/centos6-rvm193-64bit"
  config.vm.synced_folder ".",             "/vagrant"

  config.vm.network "forwarded_port", guest: 4567, host: 4567

  config.vm.provision "shell", inline: "yum -y install multitail vim nano git"

end
