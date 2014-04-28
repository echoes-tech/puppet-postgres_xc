class echoes_postgrexc::params {
  $user                   = 'postgres'
  $group                  = 'postgres'
  $home                   = '/var/lib/postgresql'
  $network_address        = '192.168.0.0/24'

  $gtm_port               = '7777'
  $gtm_proxy_port         = '7777'
  $datanode_port          = '5555'
  $coordinator_port       = '5432'

  $gtm_directory          = 'gtm'
  $datanode_directory     = 'datanode'
  $coordinator_directory  = 'coord'
  $gtm_proxy_directory    = 'gtm_proxy'
  $gtm_standby_directory  = 'gtm_standby'

  $gtm_name               = 'gtm'
  $gtm_standby_name       = 'gtm2'
}
