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
$other_database_hostname   = $postgres_xc::params::other_database_hostname,
$other_database_ip         = $postgres_xc::params::other_database_ip,
$other_datanode_node_name  = "${other_database_hostname}_datanode",
$datanode_node_name        = "${::hostname}_datanode",
$datanode_hostname         = $::hostname,
$datanode_slave            = $postgres_xc::params::datanode_slave,
$gtm_proxy                 = $postgres_xc::params::gtm_proxy,
)

inherits postgres_xc::params  {

exec { 'initialisation datanode':
  command => "sudo -u ${super_user} initdb --nodename=${datanode_node_name} -D ${home}/${datanode_directory}",
  unless  => "test -s ${home}/${datanode_directory}/postgresql.conf",
  path    => [
    '/usr/local/bin',
    '/usr/bin']
  }->

file { 'datanode postgresql.conf':
  ensure    => 'present',
  path      => "${home}/${datanode_directory}/postgresql.conf",
  owner     => $super_user,
  group     => $group,
  mode      => '0640',
  content   => template('postgres_xc/datanode/postgresql.conf.erb'),
  subscribe => Exec['reload_db'],
  }->

file { 'datanode pg_hba.conf':
  ensure    => 'present',
  path      => "${home}/${datanode_directory}/pg_hba.conf",
  owner     => $super_user,
  group     => $group,
  mode      => '0640',
  content   => template('postgres_xc/datanode/pg_hba.conf.erb'),
  subscribe => Exec['reload_db'],
  }
}
