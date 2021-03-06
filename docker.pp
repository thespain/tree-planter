$appuser    = 'vagrant'
$appuseruid = '1000'

group { 'docker':
  ensure => 'present',
}

user { $appuser:
  ensure           => 'present',
  gid              => '1000',
  groups           => ['wheel', 'docker'],
  home             => "/home/${appuser}",
  password         => '$6$eVECWbuT$6PZ6cqTwG11jrwpgB0g1Q5GyV3Y.UvEiXfT/KR3XP8RfHhHvJsp1.zU1H0ljuhFnw39r.HoSQiXm/RxcqCBQ7/',
  password_max_age => '99999',
  password_min_age => '0',
  shell            => '/bin/zsh',
  uid              => $appuseruid,
  require          => Group['docker'],
}

# this is where your git repo(s) will live
file { "/home/${appuser}/trees":
  ensure => 'directory',
  group  => $appuser,    # generally the same as your app user
  mode   => '0755',      # adjust as needed
  owner  => $appuser,    # must be your app user
}

# this is so you can see the logs generated by Sinatra and Passenger
file { '/var/log/tree-planter':
  ensure => 'directory',
  group  => $appuser,
  mode   => '0755',
  owner  => $appuser,
}

class { 'docker':
  log_driver => 'journald',
}

docker::image { 'genebean/tree-planter':
  docker_dir => '/vagrant',
}

docker::run { 'johnny_appleseed':
  image           => 'genebean/tree-planter',
  ports           => '80:8080',
  volumes         => [
    "/home/${appuser}/.ssh/vagrant_priv_key:/home/user/.ssh/id_rsa",
    "/home/${appuser}/trees:/opt/trees",
    '/var/log/tree-planter:/var/www/tree-planter/log',
  ],
  env             => "LOCAL_USER_ID=${appuseruid}",
  restart_service => true,
  privileged      => false,
  require         => [
    User[$appuser],
    File["/home/${appuser}/trees"],
    File['/var/log/tree-planter'],
  ],
}
