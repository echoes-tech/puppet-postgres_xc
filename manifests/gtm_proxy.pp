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
  $gtm_proxy_name         = "${::hostname}_gtm_proxy",
  $gtm_hostname           = $postgres_xc::params::gtm_hostname,
  $gtm_standby_hostname   = $postgres_xc::params::gtm_standby_hostname,
)
inherits postgres_xc::params {

exec { 'initialisation gtm_proxy':
  command => "sudo -u ${super_user} initgtm -Z gtm_proxy -D ${home}/${gtm_proxy_directory}",
  unless  => "/usr/bin/test -s ${home}/${gtm_proxy_directory}/gtm_proxy.conf",
  path    => [
    '/usr/local/bin',
    '/usr/bin'],
  }->

file { "${home}/${gtm_proxy_directory}/gtm_proxy.conf":
  ensure    => 'present',
  owner     => $super_user,
  group     => $group,
  mode      => '0640',
  content   => template('postgres_xc/gtm_proxy/gtm_proxy.conf.erb'),
  }->

package { 'nmap':
  ensure    => 'present',
  }->

file { "${home}/reconnect_gtm_proxy.sh":
  ensure    => 'present',
  owner     => $super_user,
  group     => $group,
  mode      => '0750',
  content   => template('postgres_xc/gtm_proxy/reconnect_gtm_proxy.sh.erb'),
  }->

exec { 'reconnect_gtm_proxy health check du GTM':
  command   => "${home}/reconnect_gtm_proxy.sh &",
  require   => Package ['nmap'],
  unless    => 'ps aux | grep \'[r]econnect_gtm_proxy.sh\' > /dev/null',
  path      => [
    '/bin'],
  }
}
