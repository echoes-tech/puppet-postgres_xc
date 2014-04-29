# == Class: postgres_xc::gtm_proxy 
# 
# Initialise GTM proxy node if it was never done (based on $::gtm_proxy_directory/gtm_proxy.conf existence)
# Then configure GTM proxy
# 
# === Parameters
# 
# [*gtm_proxy_name*]
#   Name of gtm_proxy node 
#   Used in templates files
#   Default : "${::hostname}_gtm_proxy"
# 
class postgres_xc::gtm_proxy
(
  $gtm_proxy_name = "${::hostname}_gtm_proxy",
)
inherits postgres_xc::params {

exec { 'initialisation gtm_proxy':
  command => "sudo -u ${user} initgtm -Z gtm_proxy -D ${home}/${gtm_proxy_directory}",
  unless  => "/usr/bin/test -s ${home}/${gtm_proxy_directory}/gtm_proxy.conf",
  path    => [
    '/usr/local/bin',
    '/usr/bin'],
  }->

file { "${home}/${gtm_proxy_directory}/gtm_proxy.conf":
  ensure    => 'present',
  owner     => $user,
  group     => $group,
  mode      => '0640',
  content   => template('postgres_xc/gtm_proxy/gtm_proxy.conf.erb'),
  }->

package { 'nmap':
  ensure    => 'present',
  }->

file { "${home}/reconnect_daemon.sh":
  ensure    => 'present',
  owner     => $user,
  group     => $group,
  mode      => '0750',
  content   => template('postgres_xc/gtm_proxy/reconnect_daemon.sh.erb'),
  }->

exec { 'reconnect_daemon health check du GTM':
  command   => "${home}/reconnect_daemon.sh &",
  require   => Package ['nmap'],
  unless    => 'ps aux | grep \'[r]econnect_daemon.sh\' > /dev/null',
  path      => [
    '/bin'],
  }
}
