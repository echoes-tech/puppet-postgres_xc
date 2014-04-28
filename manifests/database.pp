# == Class: postgrexc::database
#
# Regroup datanode, coordinator and GTM proxy on one node
# Installs init script, start the service
# Initialise database with each node declarations on it
#
# === Parameters
#
# [*other_database_hostname*]
#   Hostname of the second database
#   No default value
class echoes_postgrexc::database
(
$other_database_hostname   = '',
)
inherits echoes_postgrexc::params {
  require echoes_postgrexc::datanode
  require echoes_postgrexc::coordinator
  require echoes_postgrexc::gtm_proxy

file { '/etc/init.d/database':
  ensure    => 'present',
  owner     => 'root',
  group     => 'root',
  mode      => '0755',
  content   => template('echoes_postgrexc/init_main_node.sh.erb'),
  }->

service { 'database':
  ensure      => 'running',
  enable      => true,
  hasrestart  => true,
  hasstatus   => false,
  start       => '/etc/init.d/database start',
  pattern     => 'postgres -C -D',
  require     => File['/etc/init.d/database']
  }->

#Wait for the process start, otherwise followed exec while fail because puppet is faster than all process to start.
exec { 'sleep 5':
  path    => [
    '/bin']
  }->

exec { 'initialisation cluster in DB':
  unless  => "psql -U ${user} -h ${datanode::datanode_hostname} -c \"select node_name from pgxc_node;\" | grep datanode",
  command => "psql -U ${user} -h ${datanode::datanode_hostname} -c \"CREATE NODE ${other_database_hostname}_coord WITH (TYPE = 'coordinator', HOST = '${other_database_hostname}', PORT = ${coordinator_port}); CREATE NODE ${datanode::datanode_name} WITH (TYPE = 'datanode', HOST = '${datanode::datanode_hostname}', PORT = ${datanode_port} ); CREATE NODE ${other_database_hostname}_datanode WITH (TYPE = 'datanode', HOST = '${other_database_hostname}', PORT = ${datanode_port});\"",
  path    => [
    '/usr/local/bin',
    '/usr/bin',
    '/bin']
  }
}
