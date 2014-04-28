# == Class: postgrexc::gtm_standby 
# 
# Initialise GTM standby node if it was never done (based on $::gtm_standby_directory/gtm.conf existence)
# Then configure GTM proxy
# Install nmap which is used in my script to check opened port.
# Installs init script of GTM standby and promote_daemon script
# Start the service
#
# === Parameters
#
# [*gtm_standby_name*]
#   Name of GTM standby node in configuration file
#   Used in templates files
#   Default : $::hostname
#
# [*gtm_standby_hostname*]
#   Hostname of GTM standby server
#   Used in templates files
#   Default : $::hostname
#
class echoes_postgrexc::gtm_standby
(
  $gtm_standby_name       = $::hostname,
  $gtm_standby_hostname   = $::hostname,
)
inherits echoes_postgrexc::params 
{

exec { "sudo -u ${user} initgtm -Z gtm -D ${home}/${gtm_standby_directory}":
  unless  => "test -s ${home}/${gtm_standby_directory}/gtm.conf",
  before  => Exec['promote_daemon health check GTM'],
  path    => [
    '/usr/local/bin',
    '/usr/bin'],
  }->
file { "${home}/${gtm_standby_directory}/gtm.conf":
  ensure    => 'present',
  owner     => $user,
  group     => $group,
  mode      => '0640',
  content   => template('echoes_postgrexc/gtm_standby/gtm.conf.erb'),
  }->
file { '/etc/init.d/gtm_standby':
  ensure    => 'present',
  owner     => 'root',
  group     => 'root',
  mode      => '0755',
  content   => template('echoes_postgrexc/gtm_standby/init_script.erb'),
  }->


##
# Failover
##
file { "${home}/promote_daemon.sh":
  ensure    => 'present',
  owner     => $user,
  group     => $group,
  mode      => '0750',
  content   => template('echoes_postgrexc/gtm_standby/promote_daemon.sh.erb'),
  }->
package { 'nmap':
  ensure    => 'present',
  }->
exec { 'promote_daemon health check GTM':
  command   => "${home}/promote_daemon.sh &",
  require   => Package ['nmap'],
  unless    => 'ps aux | grep \'[p]romote_daemon.sh\' > /dev/null',
  path      => [
    '/bin'],
  }->

service { 'gtm_standby':
  ensure      => 'running',
  enable      => true,
  hasrestart  => true,
  hasstatus   => false,
  pattern     => "gtm -D ${home}/${gtm_standby_directory}"
  }
}
