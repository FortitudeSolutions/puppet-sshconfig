
# SSHConfig
# Reads a user's ssh config file to
#   - if specified, move the user's sshconfig file in place
#   - create the ssh key
#   - distribute it to all the servers in the user's sshconfig file

class sshconfig ($check_server='', $password_file='') {

  $home_directory       = "/Users/${::boxen_user}"
  $script_copy_id       = '/usr/local/bin/ssh-copy-id'
  $tmpscript_distribute = '/tmp/distribute_ssh_keys'
  $sshpass              = '/usr/local/bin/sshpass'


#########################
# INSTALL SSHPASS
#########################
  file { '/usr/local/bin':
    ensure => 'directory'
  }

  file { $sshpass:
    ensure  => 'present',
    source  => 'puppet:///modules/sshconfig/sshpass',
    mode    => '0755',
    owner   => 'root',
    group   => 'wheel',
    backup  => false,
    require => File['/usr/local/bin']
  }

#########################
# SET UP SSH DIRECTORY
#########################

  file { "${home_directory}/.ssh":
    ensure => 'directory',
  }

  # install the user's ssh config file
  file { "${home_directory}/.ssh/config":
    source  => "puppet:///modules/people/${::github_login}/ssh_config",
    require => File["${home_directory}/.ssh"],
  }

  exec { 'create_key':
    command => "ssh-keygen -t rsa -C '${::boxen_user}@${fqdn}' -f ${home_directory}/.ssh/id_rsa ",
    unless  => "test -e ${home_directory}/.ssh/id_rsa",
  }

#########################
# SET UP SSH SCRIPTS
#########################

  file { $script_copy_id:
    ensure   => 'present',
    owner    => 'root',
    group    => 'wheel',
    mode     => '0755',
    source   => 'puppet:///modules/sshconfig/ssh-copy-id',
    backup   => false,
  }

  file { $tmpscript_distribute:
    ensure   => 'present',
    source   => 'puppet:///modules/sshconfig/distribute_ssh_keys',
    mode     => '0755',
    backup   => false,
  }

#########################
# DISTRIBUTE KEYS
#########################

  exec { 'distribute':
    command => "${tmpscript_distribute} ${password_file}",
    unless  => "ssh -o BatchMode=yes ${check_server}",
    require => [File["${sshpass}"],File["${script_copy_id}"],File["$tmpscript_distribute"]]
  }

}
