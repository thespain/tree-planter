# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  #config.vm.box = "genebean/centos6-64bit"
  config.vm.box = "puppetlabs/centos-5.11-64-nocm"
  config.vm.synced_folder ".",             "/vagrant"

  config.vm.network "forwarded_port", guest: 4567, host: 4567

  config.vm.provision "shell", inline: "rpm -ivh http://reflector.westga.edu/repos/Fedora-EPEL/epel-release-latest-5.noarch.rpm"
  config.vm.provision "shell", inline: "yum -y install multitail vim-enhanced nano git gcc gcc-c++ openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel"
  config.vm.provision "shell", inline: "su - vagrant -c 'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3'"
  config.vm.provision "shell", inline: "su - vagrant -c 'curl -sSL https://get.rvm.io | bash -s stable --ruby=2.1.5'"
  config.vm.provision "shell", inline: "su - vagrant -c 'cd /vagrant; gem update --system; gem install bundler --no-ri --no-rdoc'"
  config.vm.provision "shell", inline: "su - vagrant -c 'cd /vagrant; bundle install --jobs=3 --without development --path ~/vendor/bundle'"

end
