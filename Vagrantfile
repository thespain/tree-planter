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

  # Install needed packages, install gems, create config files, & make a place
  # for the deployed repos.
  config.vm.provision "shell", inline: <<-SHELL1
    groupadd docker
    gpasswd -a vagrant docker
    yum -y install docker
    systemctl start docker
  SHELL1

  # Prep the app for use
  config.vm.provision "shell", inline: "cd /vagrant; docker build -t genebean/tree-planter ."
  config.vm.provision "shell", inline: "docker images"

  # Fire up the app
  config.vm.provision "shell", inline: "mkdir /home/vagrant/trees; chown vagrant:vagrant /home/vagrant/trees"
  config.vm.provision "shell", inline: "docker run -d -p 80:8080 --name planted_vagrant -v /home/vagrant/trees:/opt/trees -e LOCAL_USER_ID=`id -u vagrant` genebean/tree-planter"
  config.vm.provision "shell", inline: "docker ps"
  config.vm.provision "shell", inline: "docker exec planted_vagrant /bin/sh -c 'bundle exec rake test'"
  config.vm.provision "shell",
    inline: <<-EOF
      rm -rf /home/vagrant/trees/tree-planter*
      curl -H "Content-Type: application/json" -X POST -d '{"ref":"refs/heads/master", "repository":{"name":"tree-planter", "url":"https://github.com/genebean/tree-planter.git" }}' http://localhost:80/gitlab
      ls -ld /home/vagrant/trees/
      ls -l /home/vagrant/trees/
    EOF
end
