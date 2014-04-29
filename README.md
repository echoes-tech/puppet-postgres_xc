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
6. [Development - How to contribute to the module](#development)

##Overview

Postgres-XC (PG-XC) module. Configures a basic cluster and manages PG-XC service.

##Module Description

This module does not install PG-XC. It configures a cluster on Debian system.
It adds service script.    
It adds bash scripts enabling high availability.

##Setup

###What postgres_xc affects

  * PG-XC configuration file
  * PG-XC service

###Setup Requirements

PG-XC should be downloaded and compiled from source.
  
PG-XC configures a cluster so it needs to be declared on many nodes.

This tutorial/module is designed for a 4 machines environment.
The 4 hostnames are database1, database2, gtm and gtm2.
GTM standby is installed on gtm2

To get High Availability the Postgres-xc documentation advises to install datanode, coordinator and gtm proxy process on the same server.
GTM and GTM standby have to be installed on two other machines.

I use "database" to indicate the node with coordinator, datanode and GTM proxy.

For more information, you should read [official PG-XC tutorial](http://postgresxc.wikia.com/wiki/Real_Server_configuration). This module configures the same cluster with a GTM standby. [(GTM standby doc)](http://postgresxc.wikia.com/wiki/GTM_Standby_Configuration)

##Usage

### Configuring database node

On database1 :

```puppet

    class { 'postgres_xc::database': 
      other_database_hostname => 'database2'  
      gtm_standby_name        => 'gtm2'
      gtm_name                => 'gtm'
    }
```

On database2 :

```puppet

    class { 'postgres_xc::database':
      other_database_hostname => 'database1'
      gtm_standby_name        => 'gtm2'
      gtm_name                => 'gtm'
    }
```
### Configuring GTM node

On gtm :

```puppet

    class { 'postgres_xc::gtm': }
```

### Configuring GTM standby node

On gtm2 :

```puppet

    class { 'postgres_xc::gtm': }
```

##Reference

###Classes

  * postgres_xc::database: Handles database node.
  * postgres_xc::gtm: Handles GTM node.
  * postgres_xc::gtm_standby: Handles GTM standby node.

  * postgres_xc::coordinator: Handles coordinator process.
  * postgres_xc::datanode: Handles datanode process.
  * postgres_xc::gtm_proxy: Handles GTM proxy process.

###Parameters

####`user`
   PG-XC processes will be launched under this user.
   default : postgres

####`group`
   User's group.
   default : postgres

####`home`
   User's home directory.

####`gtm_port`
   Listening port for gtm process.

####`gtm_proxy_port`
   Listening port for gtm_proxy process.
   default : 7777
####`datanode_port`
   Listening port of datanode process.
   default : 5555

####`coordinator_port`
   Listening port for coordinator process.
   default : 5432 (default postgre port)

####`gtm_directory`
   Directory where gtm will be initialise.
   default : "$home/gtm"

####`datanode_directory`
   Directory where datanode will be initialised.
   default : "$home/datanode"

####`coordinator_directory`
   Directory where coordinator will be initialised.
   default : "$home/coordinator"

####`gtm_proxy_directory`
   Directory where gtm proxy will be initialised.
   default : "$home/gtm_proxy"

####`gtm_standby_directory`
   Directory where gtm standby will be initialised.
   default : "$home/gtm_standby"

####`gtm_name`
   Name of GTM node in configuration file.
   default : gtm

####`gtm_standby_name`
   Name of GTM standby node in configuration file.

##Limitations

This module has been tested only on Debian sytems.

##Development

Bug can be reported on [Github issues tracker](https://github.com/echoes-tech/puppet-postgres_xc/issues)
