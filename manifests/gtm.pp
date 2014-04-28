# == Class: postgrexc::gtm 
# 
# Initialise GTM node if it was never done (based on $::gtm_directory/gtm.conf existence)
# Then configure GTM
# Installs init script and start it.
#
# === Parameters
#
# [*gtm_name*]
#   Name of GTM node in configuration file
#   Used in templates files
#   Default : $::hostname
#
# [*gtm_hostname*]
#   Hostname of GTM server
#   Used in templates files
#   Default : $::hostname
#
class echoes_postgrexc::gtm
(
  $gtm_name       = $::hostname,
  $gtm_hostname   = $::hostname,
)
inherits echoes_postgrexc::params {

exec { 'Initialisation GTM':
  command => "sudo -u ${user} initgtm -Z gtm -D ${home}/${gtm_directory}",
  unless  => "test -s ${home}/${gtm_directory}/gtm.conf",
  path    => [
    '/usr/local/bin',
    '/usr/bin'],
  }

file { "${home}/${gtm_directory}/gtm.conf":
  ensure    => 'present',
  owner     => $user,
  group     => $group,
  mode      => '0640',
  content   => template('echoes_postgrexc/gtm/gtm.conf.erb'),
  require   => Exec['Initialisation GTM']
  }

file { '/etc/init.d/gtm':
  ensure    => 'present',
  owner     => 'root',
  group     => 'root',
  mode      => '0755',
  content   => template('echoes_postgrexc/gtm/init_script.erb'),
  }

service { 'gtm':
  ensure      => 'running',
  enable      => true,
  hasrestart  => true,
  hasstatus   => false,
  pattern     => "gtm -D ${home}/${gtm_directory}",
  require     => [ File['/etc/init.d/gtm'],Exec['Initialisation GTM'] ],
  }
}

