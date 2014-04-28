# == Class: postgrexc::coordinator 
# 
# Initialise coordinator node if it was never done (based on $::coordinator_directory/postgresql.conf existence)
# Then configure coordinator
# 
# === Parameters
#
# [*coordinator_name*]
#   Name of the node. Has to be different from hostname.
#   Default : ${::hostname}_coord
#
# [*coordinator_hostname*]
#   Hostname of coordinator node
#   Default : ${::hostname}
class echoes_postgrexc::coordinator

(
$coordinator_name     = "${::hostname}_coord",
$coordinator_hostname = $::hostname
)

inherits echoes_postgrexc::params {

exec { 'initialisation coordinator':
  command => "/usr/bin/sudo -u ${user} initdb --nodename=${coordinator_name} -D ${home}/${coordinator_directory}",
  unless  => "test -s ${home}/${coordinator_directory}/postgresql.conf",
  path    => [
    '/usr/local/bin',
    '/usr/bin'],
  }->
file { 'coordinator postgresql.conf':
  ensure    => 'present',
  path      => "${home}/${coordinator_directory}/postgresql.conf",
  owner     => $user,
  group     => $group,
  mode      => '0640',
  content   => template('echoes_postgrexc/coordinator/postgresql.conf.erb'),
  }->

file { 'coord pg_hba.conf':
  ensure    => 'present',
  path      => "${home}/${coordinator_directory}/pg_hba.conf",
  owner     => $user,
  group     => $group,
  mode      => '0640',
  content   => template('echoes_postgrexc/coordinator/pg_hba.conf.erb'),
  require   => Exec ['initialisation coordinator'],
  }
}
