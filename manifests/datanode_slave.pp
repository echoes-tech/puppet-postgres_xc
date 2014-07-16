# == Class: postgres_xc::datanode_slave
#
# Initialise datanode slave node if it was never done (based on $::datanode_slave_directory/postgresql.conf existence)
# Then configure datanode slave and base backup from master datanode
#
# === Parameters
#
# [*datanode_hostname*]
#   Hostname of datanode_slave node
#   Default : ${::hostname}
class postgres_xc::datanode_slave
(
$other_database_hostname      = '',
$other_datanode_node_name     = "${other_database_hostname}_datanode",
$other_coordinator_node_name  = "${other_database_hostname}_coord",
$datanode_hostname            = $::hostname,
$datanode_node_name           = "${datanode_hostname}_datanode",

$datanode_slave_directory     = $postgres_xc::params::datanode_slave_directory,
$datanode_wal_directory       = $postgres_xc::params::datanode_wal_directory,
)

inherits postgres_xc::params  {

file { 'datanode_wal_directory':
  ensure    => 'directory',
  path      => "${home}/${datanode_wal_directory}",
  owner     => $super_user,
  group     => $group,
  mode      => '0600',
}->

file { 'datanode_slave_directory':
  ensure    => 'directory',
  path      => "${home}/${datanode_slave_directory}",
  owner     => $super_user,
  group     => $group,
  mode      => '0600',
}->

exec { 'basebackup':
  command => "sudo -u ${super_user} pg_basebackup -p ${datanode_port} -h ${other_database_hostname} -D ${home}/${datanode_slave_directory}",
  onlyif  => "/usr/bin/test \"$(ls -A ${home}/${datanode_slave_directory}/)\" == \"\"",
  path    => [
    '/usr/local/bin',
    '/usr/bin',
    '/bin'],
  require => Exec ['wait_db_up']
}-> 

file { 'datanode_slave recovery.conf':
  ensure    => 'present',
  path      => "${home}/${datanode_slave_directory}/recovery.conf",
  owner     => $super_user,
  group     => $group,
  mode      => '0600',
  content   => template('postgres_xc/datanode_slave/recovery.conf.erb'),
  require   => Exec['basebackup'],
  subscribe => Exec['reload_db'],
}->

file { 'datanode_slave postgresql.conf':
  ensure    => 'present',
  path      => "${home}/${datanode_slave_directory}/postgresql.conf",
  owner     => $super_user,
  group     => $group,
  mode      => '0640',
  content   => template('postgres_xc/datanode_slave/postgresql.conf.erb'),
  require   => Exec['basebackup'],
  subscribe => Exec['reload_db'],
}->


# datanode_slave is also execute in database init script
# But his pre-requises (data and config files) can't be created without datanode started.
# And datanode_slave exit immediately if these files doesn't exist.
# So it executes it again after files and basebackup.
exec { 'datanode_slave':
  command => "sudo -u ${super_user} pg_ctl start -Z datanode -D ${home}/${datanode_slave_directory}",
  unless  => "ps a |grep \"[p]ostgres -X -D ${datanode_slave_directory}\"",
  path    => [
    '/usr/local/bin',
    '/usr/bin',
    '/bin'],
  require =>  File['datanode_slave postgresql.conf']
}

file { "promote_datanode.sh":
  ensure    => 'present',
  owner     => $super_user,
  group     => $group,
  path      => "${home}/promote_datanode.sh",
  mode      => '0740',
  content   => template('postgres_xc/datanode_slave/promote_datanode.sh.erb'),
  require   => Exec ['wait_db_up']
  }->

exec { 'promote_datanode.sh':
  command   => "${home}/promote_datanode.sh &",
  require   => Package ['nmap'],
  unless    => 'ps aux | grep \'[p]romote_datanode.sh\' > /dev/null',
  path      => [
    '/bin'],
  }
}
