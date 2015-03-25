[![Puppet Forge](http://img.shields.io/puppetforge/v/evenup/curator.svg)](https://forge.puppetlabs.com/evenup/curator)
[![Build Status](https://travis-ci.org/evenup/evenup-curator.png?branch=master)](https://travis-ci.org/evenup/evenup-curator)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with curator](#setup)
    * [What curator affects](#what-curator-affects)
    * [Beginning with curator](#beginning-with-curator)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Changelog/Contributors](#changelog-contributors)


## Overview

A puppet module for installing and configuring [elastic-curator](https://github.com/elastic/curator).

## Module Description

Curator is used to manage and clean up time-series elasticsearch indexes, this module manages curator.

NOTE: If you are using curator < 3.0.0 use a previous version of this module.


## Setup

### What curator affects

* curator package
* curator cron jobs

### Beginning with curator

Installation of the curator module:

```
  puppet module install evenup-curator
```

## Usage

Generic curator install via pip (requires pip is installed)
```puppet
  class { 'curator': }
```

Install via yum
```puppet
  class { 'curator':
    package_name => 'python-elasticsearch-curator',
    provider     => 'yum'
  }
```

Close indexes over 2 days old
```puppet
  curator::job { 'logstash_close':
    command     => 'close',
    older_than  => 2,
    cron_hour   => 7,
    cron_minute => 20,
  }
```

Delete marvel indexes older than a week
```puppet
  curator::job { 'marvel_delete':
    command      => 'delete',
    prefix       => '.marvel-',
    older_than   => 7,
    cron_hour    => 7,
    cron_minute  => 02
  }
```

Currently this package supports installing curator via pip or your local
package manager.  RPM packages can easly be created by running:

```
fpm -s python -t rpm urllib3
fpm -s python -t rpm elasticsearch
fpm -s python -t rpm click
fpm -s python -t rpm elasticsearch-curator
```


## Reference

### Public methods

#### Class: curator

Main class for installing Atlassian CLI by Bob Swift.

#####`ensure`

String.  Version to install

Default: latest

#####`package_name`

String.  Name of the package to install

Default: elasticsearch-curator

#####`provider`

String.  Package provider used to install $package_name

Default: pip

#####`bin_file`

String.  Location of the curator binary

Default: /bin/curator

#####`host`

String.  ES host.  Inherited/used by curator::job

Default: localhost

#####`port`

Integer.  Port ES is listening on.  Inherited/used by curator::job

Default: 9200

#####`logfile`

String.  Logfile to write the output log to.  Inherited/used by curator::job

Defalut: /var/log/curator.log

#####`log_level`

String.  Logging level.  Inherited/used by curator::job

Default: INFO

#####`logformat`

String.  Log format to write logs in.  Inherited/used by curator::job

Default: default

Valid values: default, logstash

#### Define: curator::job

Manages cron entires for curator jobs

#####`command`

String.  Curator command to run.

Valid options: alias, allocation, bloom, close, delete, open, optimize, replicas, or snapshot

#####`bin_file`

String.  Location of the curator binary.

Default: $::curator::bin_file

#####`host`

String.  Elasticsearch host

Default: localhost

#####`port`

Integer.  Elasticsearch port

Default: 9200

#####`prefix`

String.  Prefix for the indices. Indices that do not have this prefix are skipped.

Default: logstash-

#####`suffix`

String.  Suffix for the indices.  Indices that do not have this suffix are skipped.

Default: undef

#####`regex`

String.  Regular expression to match indices.  Indices that do not match this regexp are skipped.

Default: undef

#####`exclude`

String or Array of Strings.  Indices to skip.

Default: undef

#####`index`

String or Array of Strings.  Indices to explicitly include.

Default: undef

#####`snapshot`

String or Array of Strings.  Snapshot(s) to explicitly include.

Default: undef

#####`older_than`

Integer.  Indices older than this number of $time_units will be matched.

Default: undef

#####`newer_than`

Integer.  Indices newer than this number of $time_units will be matched.

Default: undef

#####`time_unit`

String.  Time unit used for age calculations.

Default: days

Valid options: hours, days, weeks, months

#####`timestring`

String.  Format of index time.

Default: undef

#####`master_only`

Boolean.  Only run command on elected master.

Default: false

#####`logfile`

String.  Logfile to write the output log to

Defalut: /var/log/curator.log

#####`log_level`

String.  Logging level

Default: INFO

#####`logformat`

String.  Log format to write logs in

Default: default

Valid values: default, logstash

#####`alias_name`

String.  Alias to add to indicies when using alias_order

Default: undef


#####`remove`

Boolean.  Remove alias reference instead of add

Default: false

#####`rule`

String.  Rule to apply for allocations

Default: undef

#####`disk_space`

Integer.  Size of index greater than to delete (GB)

Default: undef

#####`count`

Integer.  Number of replicas to set indices to

Default: 2

#####`repository`

String.  Respository to create snapshots in

Default: undef

#####`cron_weekday`

Cron.  Day of the week to schedule the cron entry

Default: *

#####`cron_hour`

Cron.  Hour of the day to schedule the cron entry

Default: 1

#####`cron_minute`

Cron.  Minute of the hour to schedule the cron entry

Default: 10


### Private classes

## Limitations

## Development

Improvements and bug fixes are greatly appreciated.  See the [contributing guide](https://github.com/evenup/evenup-curator/CONTRIBUTING.md) for
information on adding and validating tests for PRs.


## Changelog / Contributors

[Changelog](https://github.com/evenup/evenup-curator/blob/master/CHANGELOG)

[Contributors](https://github.com/evenup/evenup-curator/graphs/contributors)
