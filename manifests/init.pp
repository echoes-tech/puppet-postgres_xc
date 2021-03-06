class postgres_xc
(
  $database_name            = $postgres_xc::params::database_name,
  $super_user               = $postgres_xc::params::super_user,
  $user                     = $postgres_xc::params::user,
  $password                 = $postgres_xc::params::password,
  $acl_db                   = $postgres_xc::params::acl_db,

  $gtm_hostname             = $postgres_xc::params::gtm_hostname,
  $gtm_standby_hostname     = $postgres_xc::params::gtm_standby_hostname,
  $gtm                      = false,
  $database                 = false,
  $gtm_standby              = false,
  $other_database_hostname  = $postgres_xc::params::other_database_hostname,
  $other_database_ip        = $postgres_xc::params::other_database_ip,
  $datanode_slave           = $postgres_xc::params::datanode_slave, 
  $gtm_proxy                = $postgres_xc::params::gtm_proxy, 
) inherits postgres_xc::params
{
  user { "${super_user}":
    ensure    => present,
    home      => "${home}",
    managehome=> true,
  }

  if ($database) {
    class { 'postgres_xc::database': 
      other_database_hostname => $other_database_hostname,
      other_database_ip       => $other_database_ip,
      gtm_hostname            => $gtm_hostname,
      gtm_standby_hostname    => $gtm_standby_hostname,
      database_name           => $database_name,
      super_user              => $super_user,
      user                    => $user,
      password                => $password,
      gtm_proxy               => $gtm_proxy,
      datanode_slave          => $datanode_slave,
      acl_db                  => $acl_db,
    }
  }

  if ($gtm_standby) {
    class { 'postgres_xc::gtm_standby':
      gtm_hostname      => $gtm_hostname,
      user              => $user,
    }
  }

  if ($gtm) {
    class { 'postgres_xc::gtm': }
  }
}
