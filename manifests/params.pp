# == Class: postgres_xc::params
#
# Module to configure Postgre-xc replication based on PostgreSQL.
# This module do not handle with the compilation of PGXC.
# This module will install 2 Database, 1 GTM and 1 GTM standby.
# so it needs 4 computers.
# Database is constituted of datanode, coordinator and gtm proxy.
#
# I improve High availability of PGXC with bash script :
# promote_daemon.sh (executed on standby) check if $gtm_port is open on GTM server
#   if not : promote standby as GTM
# reconnect_gtm_proxy.sh (executed on GTM proxy) check if $gtm_port on GTM server
#   if not : reconnect gtm proxy to the new GTM
#
# This module also install init script for the three types of machine : database, GTM stanby and GTM.
# GTM standby will start if $gtm_port on GTM server is open
#   if not : GTM standby changes its configuration and become a GTM
# Database will not start until one GTM is up : first try $gtm_port on GTM server then try $gtm_port GTM standby
#
# === Parameters
#
# [*user*]
#   PGXC processes will be launch under this user
#   default = postgres
#
# [*group*]
#   user's group
#   default : postgres
#
# [*home*]
#   User'sHome directory
#
# [*gtm_port*]
#   listening port for gtm process
#
# [*gtm_proxy_port*]
#   listening port for gtm_proxy process
#   default = 7777
# [*datanode_port*]
#   Listening port of datanode process
#   default = 5555
#
# [*coordinator_port*]
#   Listening port for coordinator process
#   Default = 5432 (default postgre port)
#
# [*gtm_directory*]
#   Directory where gtm will be initialise
#   Default = "$home/gtm"
#
# [*datanode_directory*]
#   Directory where datanode will be initialise
#   Default = "$home/datanode"
#
# [*coordinator_directory*]
#   Directory where coordinator will be initialise
#   Default = "$home/coordinator"
#
# [*gtm_proxy_directory*]
#   Directory where gtm proxy will be initialise
#   Default = "$home/gtm_proxy"
#
# [*gtm_standby_directory*]
#   Directory where gtm standby will be initialise
#   Default = "$home/gtm_standby"
#
# [*gtm_name*]
#   Name of GTM node in configuration file
#   Default : gtm
#
# [*gtm_hostname*]
#   Hostame of machine where GTM is.
#   Default : gtm
#
# [*gtm_standby_name*]
#   Name of GTM standby node in configuration file
#   Default : gtm2
#
# [*gtm_standby_hostname*]
#   Hostname of machine where GTM standby is
#   Default : gtm2
#
# === Example 
#   On Database server 1:
#   class { 'postgres_xc::database':
#     other_database_hostname => 'database2',
#     gtm_hostname                => 'gtm',
#     gtm_standby_hostname        => 'gtm2',
#   }
#
#   On Database server 2:
#   class { 'postgres_xc::database':
#     other_database_hostname => 'database1',
#     gtm_hostname                => 'gtm',
#     gtm_standby_hostname        => 'gtm2',
#   }
#
#   On GTM server:
#   class { 'postgres_xc::gtm': }
#     
#   On GTM standby server:
#   class { 'postgres_xc::gtm_standby':}
#
# Requires:
#   Download and compile yourself PGXC (module made and tested with PGXC 1.0.4)
#
# === Authors
#
# Thibault Marquand <thibault.marquand@utt.fr>
#
# === Copyright
#
# Copyright 2014 Echoes Technologies.
class postgres_xc::params {
  $user                     = 'echoes'
  $password                 = 'echoes'
  $database_name            = 'echoes'
  $super_user               = 'postgres'
  $group                    = 'postgres'
  $home                     = '/var/lib/postgresql'

  $gtm_port                 = '7777'
  $gtm_proxy_port           = '7777'
  $datanode_port            = '5555'
  $coordinator_port         = '5432'
  $datanode_slave_port      = '20010'

  $gtm_directory            = 'gtm'
  $datanode_directory       = 'datanode'
  $coordinator_directory    = 'coord'
  $gtm_proxy_directory      = 'gtm_proxy'
  $gtm_standby_directory    = 'gtm_standby'
  $datanode_slave_directory = 'datanode_slave'
  $datanode_wal_directory   = 'datanode_arclog'

  $gtm_hostname             = 'gtm'
  $gtm_name                 = "${gtm_hostname}"
  $gtm_standby_hostname     = 'gtm2'
  $gtm_standby_name         = "${gtm_standby_hostname}"
  
  $datanode_slave           = true
}
