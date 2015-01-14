What is it?
===========

A puppet module for installing and configuring [elasticsearch-curator](https://github.com/elasticsearch/curator).

Curator is used to manaage and clean up time-series elasticsearch indexes.

A good [blog post](http://www.elasticsearch.org/blog/curator-tending-your-time-series-indices/) on why and how curator.

NOTE: If you are using curator < 1.1.0 use version 0.0.1 of this module.


Installation
------------

Currently this package supports installing curator via pip or your local
package manager.  RPM packages can easly be created by running:
```
fpm -s python -t rpm urllib3
fpm -s python -t rpm elasticsearch
fpm -s python -t rpm elasticsearch-curator
```

Usage:
------

Generic curator install (local package manager)
```puppet
  class { 'curator': }
```

Install via pip
```puppet
  class { 'curator':
    provider => 'pip'
  }
```

Install in a virtualenv via pip
```puppet
  class { 'curator':
    provider        => 'virtualenv',
    virtualenv_path => '/opt/elasticsearch-curator',
  }
```
You'll need to use the include the
[stankevich/python](https://forge.puppetlabs.com/stankevich/python)
module in your manifests and ensure the **pip** and **virtualenv**
parameters are set to *true*.

Disable bloom filters on indexes over 2 days old
```puppet
  curator::job { 'logstash_bloom':
    bloom_older     => 2,
    cron_hour       => 7,
    cron_minute     => 20,
  }
```

Delete marvel indexes older than a week
```puppet
  curator::job { 'marvel_delete':
    prefix          => '.marvel-',
    delete_older    => 7,
    cron_hour       => 7,
    cron_minute     => 02
  }
```

Additional tuning and defaults are listed in the [job.pp](manifests/job.pp).


Known Issues:
-------------
Only tested on CentOS 6


License:
_______

Released under the Apache 2.0 licence


Contribute:
-----------
* Fork it
* Create a topic branch
* Improve/fix (with spec tests)
* Push new topic branch
* Submit a PR
