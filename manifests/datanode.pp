# == Class: postgres_xc::datanode
#
# Initialise datanode node if it was never done (based on $::datanode_directory/postgresql.conf existence)
# Then configure datanode
#
# === Parameters
#
# [*datanode_name*]
#   Name of the node. Has to be different from hostname.
#   Default : ${::hostname}_datanode
#
# [*datanode_hostname*]
#   Hostname of datanode node
#   Default : ${::hostname}
class postgres_xc::datanode

(
$datanode_name      = "${::hostname}_datanode",
$datanode_hostname  = $::hostname,
)

inherits postgres_xc::params  {

exec { 'initialisation datanode':
  command => "sudo -u ${user} initdb --nodename=${datanode_name} -D ${home}/${datanode_directory}",
  unless  => "/usr/bin/test -s ${home}/${datanode_directory}/postgresql.conf",
  path    => [
    '/usr/local/bin',
    '/usr/bin']
  }->

file { 'datanode postgresql.conf':
  ensure    => 'present',
  path      => "${home}/${datanode_directory}/postgresql.conf",
  owner     => $user,
  group     => $group,
  mode      => '0640',
  content   => template('postgres_xc/datanode/postgresql.conf.erb'),
  }->

file { 'datanode pg_hba.conf':
  ensure    => 'present',
  path      => "${home}/${datanode_directory}/pg_hba.conf",
  owner     => $user,
  group     => $group,
  mode      => '0640',
  content   => template('postgres_xc/datanode/pg_hba.conf.erb'),
  }
}
