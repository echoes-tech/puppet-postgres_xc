# postgrexc

This is the postgrexc module.
It doesn't install Postgre-xc : you have to compile it your self.
Configure a database cluster with 2 database, 1 GTM and 1 GTM standby
To get more information : [Official postgre-xc wiki](http://postgresxc.wikia.com/wiki/Real_Server_configuration).
This module install the same configuration as this tutorial.

## Using postgre-xc

### Getting Started

First of all, you must download and compile Postgre-xc.
If you use custom parameters for configure script, take care to report this configuration on the module parameters : user, group, home
The default value of the module are the default value of configure script.

Then, install this module.
```bash
puppet module install echoes/postgrexc
```

Postgre-xc advise to install datanode, coordinator and gtm proxy process on the same server. GTM on an other one and then, GTM standby on a last one.
`echoes\_postgrexc::database` class include datanode, coordinator and GTM proxy. It has to be installed on the database servers.

This tutorial supposed you have got 4 machines. There hostname are database1, database2, gtm and gtm2.
We are going to install GTM standby on gtm2

#### Configuring database node

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
#### Configuring GTM node

On gtm :

```puppet

    class { 'echoes_potgrexc::gtm': }
```

#### Configuring GTM standby

On gtm2 :

```puppet

    class { 'echoes_potgrexc::gtm': }
```

###  

License
-------

Copyright (C) 2014 Echoes Technologies <contact@echoes-tech.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Contact
-------

<thibault.marquand [at] utt.fr>

Support
-------

