# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "genebean/centos-7-puppet"

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box
  end

  config.vm.network "forwarded_port", guest: 80,   host: 8080
  #config.vm.network "forwarded_port", guest: 3000, host: 3000
  #config.vm.network "forwarded_port", guest: 4567, host: 4567

  # Install needed packages, install gems, create config files, & make a place
  # for the deployed repos.
  config.vm.provision "shell", inline: <<-SHELL1
    yum -y install scl-utils git
    yum -y install https://www.softwarecollections.org/en/scls/rhscl/httpd24/epel-7-x86_64/download/rhscl-httpd24-epel-7-x86_64.noarch.rpm
    yum -y install httpd24 httpd24-httpd-devel gcc gcc-c++ libcurl-devel zlib-devel ruby-devel

    gem install --no-ri --no-rdoc passenger bundler

    cat /vagrant/exmaple-configs/apache/passenger.conf > /opt/rh/httpd24/root/etc/httpd/conf.d/passenger.conf
    cat /vagrant/exmaple-configs/apache/10-tree-planter.conf > /opt/rh/httpd24/root/etc/httpd/conf.d/10-tree-planter.conf
    echo '{ "base_dir": "/vagrant/trees" }' > /vagrant/config.json

    if [ ! -d "/vagrant/trees" ]; then
      mkdir /vagrant/trees
    fi
  SHELL1

  # Normally you would clone the app into /opt/tree-planter. This simulates that
  config.vm.provision "shell", inline: "ln -s /vagrant /opt/tree-planter"

  # The Passenger installer refuses to exit 0 so we hide it from Vagrant in a
  # script that always exits 0 thaks to the echo at the end.
  config.vm.provision "shell", path: "vagrant-config-files/passenger-scl.sh"

  # Prep the app for use
  config.vm.provision "shell", inline: "su - vagrant -c 'cd /vagrant; bundle install --jobs=3 --path ~/vendor/bundle'"

  # Fire up the app in Apache
  config.vm.provision "shell", inline: "systemctl restart httpd24-httpd; systemctl enable httpd24-httpd"
end
