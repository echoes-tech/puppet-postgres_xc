#postgres-xc

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with postgres_xc](#setup)
    * [What postgres_xc affects](#what-postgres_xc-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

Postgres-XC module. Configure a basic cluster and manage Postgres-XC service.

##Module Description

This module do not install postgres-XC. It configure a cluster on Debian system.
It adds service script and manage them.    

##Setup

###What postgres_xc affects

  * PG-XC configuration file
  * PG-XC service

###Setup Requirements

You have to download and compile PG-XC from source.
  
Postgres-XC configure a cluster so it needs to be declare on many nodes.

To achieve this tutorial it supposed you get 4 machines.
There hostname are database1, database2, gtm and gtm2.
We are going to install GTM standby on gtm2

To get High Availability Postgres-xc advise to install datanode, coordinator and gtm proxy process on the same server.
GTM and GTM standby has to be installed on two other machines.

I use "database" to indicate the node with coordinator, datanode and GTM proxy.

##Usage

### Configuring database node

On database1 :

```puppet

    class { 'echoes_potgrexc::database': 
      other_database_hostname => 'database2'  
      gtm_standby_name        => 'gtm2'
      gtm_name                => 'gtm'
    }
```

On database2 :

```puppet

    class { 'echoes_potgrexc::database':
      other_database_hostname => 'database1'
      gtm_standby_name        => 'gtm2'
      gtm_name                => 'gtm'
    }
```
### Configuring GTM node

On gtm :

```puppet

    class { 'echoes_potgrexc::gtm': }
```

### Configuring GTM standby node

On gtm2 :

```puppet

    class { 'echoes_potgrexc::gtm': }
```

##Reference

###Classes

  * postgres_xc::database: Handles database node.
  * postgres_xc::gtm: Handles GTM node.
  * postgres_xc::gtm_standby: Handles GTM standby node.

  * postgres_xc::coordinator: Handles coordinator process.
  * postgres_xc::datanode: Handles datanode process.
  * postgres_xc::gtm_proxy: Handles GTM proxy node.

###Parameters

####`user`
PGXC processes will be launch under this user.\n
Default = postgres

####`group`
   user's group.
   default : postgres

####`home`
   User's home directory.

####`gtm_port`
   listening port for gtm process.

####`gtm_proxy_port`
   listening port for gtm_proxy process.
   default = 7777
####`datanode_port`
   Listening port of datanode process.
  default = 5555

####`coordinator_port`
   Listening port for coordinator process.
   Default = 5432 (default postgre port)

####`gtm_directory`
   Directory where gtm will be initialise.
   Default = "$home/gtm"

####`datanode_directory`
   Directory where datanode will be initialise.
   Default = "$home/datanode"

####`coordinator_directory`
   Directory where coordinator will be initialise.
   Default = "$home/coordinator"

####`gtm_proxy_directory`
   Directory where gtm proxy will be initialise.
   Default = "$home/gtm_proxy"

####`gtm_standby_directory`
   Directory where gtm standby will be initialise.
   Default = "$home/gtm_standby"

####`gtm_name`
   Name of GTM node in configuration file.
   Default : gtm

####`gtm_standby_name`
   Name of GTM standby node in configuration file.

##Limitations

This module has been tested only on Debian sytems.

##Development

