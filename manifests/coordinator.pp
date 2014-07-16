# == Class: postgres_xc::coordinator
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
class postgres_xc::coordinator

(
$acl_db               = $postgres_xc::params::acl_db,
$coordinator_name     = "${::hostname}_coord",
$coordinator_hostname = $::hostname,
$gtm_hostname         = $postgres_xc::params::gtm_hostname,
$gtm_proxy            = $postgres_xc::params::gtm_proxy
)

inherits postgres_xc::params {

exec { 'initialisation coordinator':
  command => "/usr/bin/sudo -u ${super_user} initdb --nodename=${coordinator_name} -D ${home}/${coordinator_directory}",
  unless  => "/usr/bin/test -s ${home}/${coordinator_directory}/postgresql.conf",
  path    => [
    '/usr/local/bin',
    '/usr/bin'],
  }->
file { 'coordinator postgresql.conf':
  ensure    => 'present',
  path      => "${home}/${coordinator_directory}/postgresql.conf",
  owner     => $super_user,
  group     => $group,
  mode      => '0640',
  content   => template('postgres_xc/coordinator/postgresql.conf.erb'),
  subscribe => Exec['reload_db'],
  }->

file { 'coord pg_hba.conf':
  ensure    => 'present',
  path      => "${home}/${coordinator_directory}/pg_hba.conf",
  owner     => $super_user,
  group     => $group,
  mode      => '0640',
  content   => template('postgres_xc/coordinator/pg_hba.conf.erb'),
  require   => Exec ['initialisation coordinator'],
  subscribe => Exec['reload_db'],
  }
}
