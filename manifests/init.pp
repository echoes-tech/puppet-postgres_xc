# == Class: postgrexc
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
# reconnect_daemon.sh (executed on GTM proxy) check if $gtm_port on GTM server
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
# [*gtm_standby_name*]
#   Name of GTM standby node in configuration file
#   Default : gtm2
#
# === Example 
#   On Database server 1:
#   class { 'echoes_postgrexc::database':
#     other_database_hostname => 'database2',
#     gtm_name                => 'gtm',
#     gtm_standby_name        => 'gtm2',
#   }
#
#   On Database server 2:
#   class { 'echoes_postgrexc::database':
#     other_database_hostname => 'database1',
#     gtm_name                => 'gtm',
#     gtm_standby_name        => 'gtm2',
#   }
#
#   On GTM server:
#   class { 'echoes_postgrexc::gtm': }
#     
#   On GTM standby server:
#   class { 'echoes_postgrexc::gtm_standby':}
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
class echoes_postgrexc
(
  $user                   = $echoes_postgrexc::params::user,
  $group                  = $echoes_postgrexc::params::group,
  $home                   = $echoes_postgrexc::params::home,

  $gtm_port               = $echoes_postgrexc::params::gtm_port,
  $gtm_proxy_port         = $echoes_postgrexc::params::gtm_proxy_port,
  $datanode_port          = $echoes_postgrexc::params::datanode_port,
  $coordinator_port       = $echoes_postgrexc::params::coordinator_port,

  $gtm_directory          = $echoes_postgrexc::params::gtm_directory,
  $datanode_directory     = $echoes_postgrexc::params::datanode_directory,
  $coordinator_directory  = $echoes_postgrexc::params::coordinator_directory,
  $gtm_proxy_directory    = $echoes_postgrexc::params::gtm_proxy_directory,
  $gtm_standby_directory  = $echoes_postgrexc::params::gtm_standby_directory,

  $gtm_name               = $echoes_postgrexc::params::gtm_name,
  $gtm_standby_name       = $echoes_postgrexc::params::gtm_standby_name,
)
{
exec { 'echo ""': }
}
