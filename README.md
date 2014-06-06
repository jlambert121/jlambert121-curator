What is it?
===========

A puppet module for installing and configuring [elasticsearch-curator] (https://github.com/elasticsearch/curator).

Curator is used to manaage and clean up time-series elasticsearch indexes.


Installation
------------

Currently this package only supports installing curator via RPMs.  These can
easily be created by running
```
fpm -s python -t rpm urllib3
fpm -s python -t rpm elasticsearch
fpm -s python -t rpm elasticsearch-curator
```

Usage:
------

Generic curator install
<pre>
  class { 'curator': }
</pre>

Schedule a curator job to delete indexes oler than 90 days, close indexes
older than 30 days, and disable bloom filters and optimize older than two days.
```puppet
  curator::job { 'cleanup':
    delete_older    => 90,
    close_older     => 30,
    optimize_older  => 2
    bloom_older     => 2,
  }
```

Additional tuning and defaults are listed in the job.pp.


Known Issues:
-------------
Only tested on CentOS 6

TODO:
____
[ ] Allow using the pip package provider

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
