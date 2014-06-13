# == Class: postgres_xc::database
#
# Regroup datanode, coordinator and GTM proxy on one node
# Installs init script, start the service
# Initialise database with each node declarations on it
# If enabled, installs a datanode_slave of the remote datanode
#
# === Parameters
#
# [*other_database_hostname*]
#   Hostname of the second database
#   No default value
#
# [*other_coordinator_node_name*]
#   Name of coordinator node which is on the opposite machine.
#   Default : ${other_database_hostname}_coord
#
# [*other_datanode_node_name*]
#   Name of datanode node which is on the opposite machine. Used in cluster definition.
#   Default : ${other_datanode_node_name}_datanode
#
# [*datanode_node_name*]
#   Name of datanode node which is on local machine. Used in cluster definition.
#   Default : ${datanode_node_name}_datanode
#
class postgres_xc::database
(
$other_database_hostname      = '',
$other_coordinator_node_name  = "${other_database_hostname}_coord",
$datanode_node_name           = "${::hostname}_datanode",
$other_datanode_node_name     = "${other_database_hostname}_datanode",

$gtm_hostname                 = $postgres_xc::params::gtm_hostname,
$gtm_standby_hostname         = $postgres_xc::params::gtm_standby_hostname,
$database_name                = $postgres_xc::params::database_name,
$super_user                   = $postgres_xc::params::super_user,
$user                         = $postgres_xc::params::user,
$password                     = $postgres_xc::params::password,
$datanode_slave               = $postgres_xc::params::datanode_slave,
$gtm_proxy                    = $postgres_xc::params::gtm_proxy,
)
inherits postgres_xc::params {

class { 'postgres_xc::datanode':
  other_database_hostname    => $other_database_hostname,
  datanode_node_name         => $datanode_node_name,
  other_datanode_node_name   => $other_datanode_node_name,
  datanode_slave             => $datanode_slave,  
  gtm_proxy                  => $gtm_proxy,
}
#  require postgres_xc::coordinator

class { 'postgres_xc::coordinator':
  gtm_proxy         => $gtm_proxy,
  gtm_hostname      => $gtm_hostname,
}

if ($gtm_proxy) {
  class { 'postgres_xc::gtm_proxy':
    gtm_hostname          => $gtm_hostname,
    gtm_standby_hostname  => $gtm_standby_hostname,
  }
}

file { '/etc/init.d/database':
  ensure    => 'present',
  owner     => 'root',
  group     => 'root',
  mode      => '0755',
  content   => template('postgres_xc/init_main_node.sh.erb'),
  }->

service { 'database':
  ensure      => 'running',
  enable      => true,
  hasrestart  => true,
  hasstatus   => false,
  start       => '/etc/init.d/database start',
  pattern     => 'postgres -C -D',
  require     => File['/etc/init.d/database'],
  }->

#Wait for the process start, otherwise followed exec while fail because puppet is faster than all process to start.
exec { 'wait_db_up':
  command => 'sleep 3',
  path    => [
    '/bin']
  }->

exec { 'initialisation cluster in DB':
  unless  => "psql -U ${super_user} -h ${datanode::datanode_hostname} -c \"select node_name from pgxc_node;\" | grep ${datanode_node_name}",
  command => "psql -U ${super_user} -h ${datanode::datanode_hostname} -c \"CREATE NODE ${other_coordinator_node_name} WITH (TYPE = 'coordinator', HOST = '${other_database_hostname}', PORT = ${coordinator_port}); CREATE NODE ${datanode_node_name} WITH (TYPE = 'datanode', HOST = '${datanode::datanode_hostname}', PORT = ${datanode_port} ); CREATE NODE ${other_datanode_node_name} WITH (TYPE = 'datanode', HOST = '${other_database_hostname}', PORT = ${datanode_port}); select pgxc_pool_reload();\"",

  path    => [
    '/usr/local/bin',
    '/usr/bin',
    '/bin'],
  }->

exec { 'createuser':
  command => "psql -U ${super_user} -h ${datanode::datanode_hostname} -c \"create user ${user} with password '${password}';\"",
  unless  => "psql -U ${super_user} -h ${datanode::datanode_hostname} -c \"select * from pg_roles;\" | grep ${user}",
  path    => [
    '/usr/local/bin',
    '/usr/bin',
    '/bin'],
  }->

exec { 'createdb':
  command => "psql -U ${super_user} -h ${datanode::datanode_hostname} -c \"create database ${database_name};\"",
  unless  => "psql -U ${super_user} -h ${datanode::datanode_hostname} -c \"select * from pg_database;\" | grep ${database_name}",
  path    => [
    '/usr/local/bin',
    '/usr/bin',
    '/bin'],
  }

if ($datanode_slave) {
  class { 'postgres_xc::datanode_slave':
    other_database_hostname    => $other_database_hostname,
    datanode_node_name         => $datanode_node_name,
    other_datanode_node_name   => $other_datanode_node_name,
    other_coordinator_node_name=> $other_coordinator_node_name,
    require                    => Exec ['wait_db_up'], 
  }
}
}

