# == Definition: curator::job
#
# Schedules an elasticsearch curator maintainence job
#
# === Parameters
#
# [*path*]
#   String.  Location of the curator binary
#   Default: /usr/bin/curator
#
# [*host*]
#   String.  Elasticsearch host
#   Default: localhost
#
# [*port*]
#   Integer.  Elasticsearch port
#   Default: 9200
#
# [*prefix*]
#   String.  Prefix for the indices. Indices that do not have this prefix are skipped.
#   Default: logstash-
#
# [*time_unit*]
#   String.  Unit of time to reckon by: [days, hours]
#
# [*timestring*]
#   String.  Format of index time.
#
# [*master_only*]
#   Boolean.  Only run command on elected master.
#   Default: false
#
# [*delete_older*]
#   Integer.  Delete indices older than n TIME_UNITs.
#
# [*close_older*]
#   Integer.  Close indicies older than n TIME_UNITs.
#
# [*bloom_older*]
#   Integer.  Disable bloom filter for indicies older than n TIME_UNITs
#
# [*optimize_older*]
#   Integer.  Optimize (Lucene forceMerge) indices older than n TIME_UNITs.
#
# [*allocation_older*]
#   Integer.  Allocate indices older than n TIME_UNITs based on rule.
#
# [*alias_older*]
#   Integer.  Add aliases to indices older than n TIME_UNITs.
#
# [*snapshot_older*]
#   Integer.  Snapshot indices older than n TIME_UNITs.
#
# [*snapshot_recent*]
#   Integer.  Snapshot indices most recent than n TIME_UNITs.
#
# [*snapshot_delete_older*]
#   Integer. Delete snapshot older than n TIME_UNITs.
#
# [*disk_space*]
#   Integer.  Delete indices beyond n GIGABYTES.
#
# [*alias_name*]
#   String.  Alias to add to indicies when using alias_order
#
# [*repository*]
#   String.  Respository to create snapshots in
#
# [*rule*]
#   String.  Rule to apply for allocations
#
# [*max_num_segments*]
#   Integer.  Maximum number of segments, post-optimize.
#   Default: 2
#
# [*logfile*]
#   String.  Logfile to write the output log to
#   Defalut: /var/log/curator.log
#
# [*cron_weekday*]
#   Cron.  Day of the week to schedule the cron entry
#   Default: *
#
# [*cron_hour*]
#   Cron.  Hour of the day to schedule the cron entry
#   Default: 1
#
# [*cron_minute*]
#   Cron.  Minute of the hour to schedule the cron entry
#   Default: 10
#
#
#
# === Examples
#
# Daily job that deletes all indicies over 30 days
#   curator::job { 'delete_job':
#     delete_older  => 30
#   }
#
# Daily job to perform "light" tasks, weekly job to optimize
#   curator::job { 'light_job':
#     delete_older  => 120,
#     close_older   => 30,
#     bloom_older   => 7,
#     cron_hour     => 23,
#     cron_minute   => 30,
#   }
#   curator::job { 'weekly_optimize':
#     optimize_older  => 7,
#     cron_weekday    => 6,
#     cron_hour       => 11
#   }
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
define curator::job (
  $command,
  $sub_command           = 'indices',
  $path                  = '/bin/curator',

  # ES config
  $host                  = 'localhost',
  $port                  = 9200,

  # Options for all indexes
  $prefix                = 'logstash-',
  $suffix                = undef,
  $regex                 = undef,
  $exclude               = undef,
  $index                 = undef,
  $snapshot              = undef,
  $older_than            = undef,
  $newer_than            = undef,
  $time_unit             = 'days',
  $timestring            = undef,
  $master_only           = false,
  $logfile               = '/var/log/curator.log',
  $log_level             = 'INFO',
  $logformat             = 'default',

  # Alias options
  $alias_name            = undef,
  $remove                = false,

  # Allocation options
  $rule                  = undef,

  # Delete options
  $disk_space            = undef,

  # Optimize options
  $delay                 = 0,
  $max_num_segments      = 2,
  $request_timeout       = 218600,

  # Replicas options
  $count                 = 2,

  # Snapshot options
  $repository            = undef,

  # Cron params
  $cron_weekday          = '*',
  $cron_hour             = 1,
  $cron_minute           = 10,
){

  # Validations and set index options

  if $prefix {
    $_prefix = "--prefix '${prefix}'"
  } else {
    $_prefix = undef
  }

  if $suffix {
    $_suffix = "--suffix '${suffix}'"
  } else {
    $_suffix = undef
  }

  if $regex {
    $_regex = "--regex '${regex}'"
  } else {
    $_regex = undef
  }

  if $timestring {
    $_timestring = "--timestring '${timestring}'"
  } else {
    $_timestring = ''
  }

  if !member(['days', 'hours', 'weeks', 'months'], $time_unit) {
    fail("curator::job[${name}] time_unit must be 'days' or 'hours'")
  } else {
    $_time_unit = "--time-unit ${time_unit}"
  }

  if !is_integer($port) {
    fail("curator::job[${name}] port must be integer")
  }

  if $exclude {
    if !is_string($exclude) and !is_array($exclude) {
      fail("curator::job[${name}]: exclude must be an array or array of strings")
    } else {
      $_exclude = inline_template("Array(@exclude).map { |element| \"--exclude #{element}\" }.join(' ')")
    }
  } else {
    $_exclude = undef
  }

  if $index {
    if !is_string($index) and !is_array($index) {
      fail("curator::job[${name}]: index must be an array or array of strings")
    } else {
      $_index = inline_template("Array(@index).map { |element| \"--exclude #{element}\" }.join(' ')")
    }
  } else {
    $_index = undef
  }

  if $snapshot {
    if !is_string($snapshot) and !is_array($snapshot) {
      fail("curator::job[${name}]: snapshot must be an array or array of strings")
    } else {
      $_snapshot = inline_template("Array(@snapshot).map { |element| \"--exclude #{element}\" }.join(' ')")
    }
  } else {
    $_snapshot = undef
  }

  validate_bool($master_only)

  if $older_than {
    if !is_integer($older_than) {
      fail("curator::job[${name}] older_than must be an integer")
    } else {
      $_older_than = "--older-than ${older_than}"
    }
  } else {
    $_older_than = undef
  }

  if $newer_than {
    if !is_integer($newer_than) {
      fail("curator::job[${name}] newer_than must be an integer")
    } else {
      $_newer_than = "--newer-than ${newer_than}"
    }
  } else {
    $_newer_than = undef
  }

  if !member(['default', 'logstash'], $logformat) {
    fail("curator::job[${name}] logformat must be default or logstash")
  }

  if !member(['INFO', 'WARN'], $log_level) {
    fail("curator::job[${name}] log_level must be INFO or WARN")
  }


  case $command {
    'alias': {
      # alias validations
      if !$alias_name {
        fail("curator::job[${name}] alias_name is required with alias")
      }
      validate_bool($remove)

      $exec = "alias --name ${alias_name} --remove ${remove} indices"
    }
    'allocation': {
      # allocation validations
      if !$rule {
        fail("curator::job[${name}] rule is required with allocation")
      }

      $exec = "allocation --rule ${rule} indicies"
    }
    'close', 'open': {
      $exec = $command
    }
    'delete': {
      # delete validations
      if !member(['indices', 'snapshots'], $sub_command) {
        fail("curator::job[${name}] delete command supports indices and snapshots sub_command")
      }
      if $disk_space {
        if !is_integer($disk_space) {
        } else {
          $_ds = " --disk-space ${disk_space}"
        }
      } else {
        $_ds = ''
      }

      $exec = "delete${_ds}"
    }
    'optimize': {
      # optimize validations
      if !is_integer($delay) {
        fail("curator::job[${name}] delay must be an integer")
      } else {
        $_delay = " --delay ${delay}"
      }

      if !is_integer($max_num_segments) {
        fail("curator::job[${name}] max_num_segments must be an integer")
      } else {
        $_segments = " --max_num_segments ${max_num_segments}"
      }

      if !is_integer($request_timeout) {
        fail("curator::job[${name}] request_timeout must be an integer")
      } else {
        $_timeout = " --request_timeout ${request_timeout}"
      }

      $exec = "optimize${_delay}${_segments}${_timeout} indices"
    }
    'replicas': {
      if !is_integer($count) {
        fail("curator::job[${name}] count must be an integer")
      }

      $exec = "replicas --count ${count} indices"
    }
    'snapshot': {
      if !$repository {
        fail("curator::job[${name}] repository is required")
      }

      $exec = "snapshot --repository ${repository}"
    }
    default: {
      fail("curator::job[${name}]: command must be alias, allocation, bloom, close, delete, open, optimize, replicas, or snapshot")
    }
  }

  $mo_string = $master_only ? {
    true    => ' --master-only',
    default => '',
  }

  $index_options = join(delete_undef_values([$_prefix, $_suffix, $_regex, $_time_unit, $_exclude, $_index, $_snapshot, $_older_than, $_newer_than, $_timestring]), ' ')

  cron { "curator_${name}":
    command => "${path}${mo_string} --host ${host} --port ${port} --logfile ${logfile} --loglevel ${log_level} --logformat ${logformat} ${exec} ${index_options}",
    hour    => $cron_hour,
    minute  => $cron_minute,
    weekday => $cron_weekday,
  }

}
