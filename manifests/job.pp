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
# === Copyright
#
# Copyright 2014 EvenUp.
#
define curator::job (
  $path                  = '/usr/bin/curator',
  $host                  = 'localhost',
  $port                  = 9200,
  $prefix                = 'logstash-',
  $time_unit             = 'days',
  $timestring            = undef,
  $master_only           = false,
  $delete_older          = undef,
  $close_older           = undef,
  $bloom_older           = undef,
  $optimize_older        = undef,
  $allocation_older      = undef,
  $alias_older           = undef,
  $snapshot_older        = undef,
  $snapshot_recent       = undef,
  $snapshot_delete_older = undef,
  $disk_space            = undef,
  $alias_name            = undef,
  $repository            = undef,
  $rule                  = undef,
  $max_num_segments      = 2,
  $logfile               = '/var/log/curator.log',
  $cron_weekday          = '*',
  $cron_hour             = 1,
  $cron_minute           = 10,
){

  if $curator::provider == 'virtualenv' {
    $path = "source ${curator::virtualenv_path}/bin/activate && ${curator::virtualenv_path}/bin/curator"
    $cron_environment = 'SHELL=/usr/bin/env bash'
  } else {
    $cron_environment = undef
  }

  $commands = delete_undef_values([$delete_older, $disk_space, $close_older, $bloom_older, $optimize_older, $allocation_older, $alias_older, $snapshot_older])

  if size($commands) == 0 {
    fail('One of delete_older, disk_space, close_older, bloom_older, optimize_older, allocation_older, alias_older, or snapshot_older is required')
  }

  if !(member(['days', 'hours'], $time_unit) ){
    fail("curator::job(${name}) time_unit must be 'days' or 'hours'")
  }

  if !(is_integer($port)) {
    fail("curator::job(${name}) port must be integer")
  }

  if !(is_integer($max_num_segments)) {
    fail("curator::job(${name}) max_num_segments must be an integer")
  }

  validate_bool($master_only)

  if $delete_older and !(is_integer($delete_older)) {
    fail("curator::job(${name}) delete_older must be an integer")
  }

  if $close_older and !(is_integer($close_older)) {
    fail("curator::job(${name}) close_older must be an integer")
  }

  if $bloom_older and !(is_integer($bloom_older)) {
    fail("curator::job(${name}) bloom_older must be an integer")
  }

  if $optimize_older and !(is_integer($optimize_older)) {
    fail("curator::job(${name}) optimize_older must be an integer")
  }

  if $allocation_older and !(is_integer($allocation_older)) {
    fail("curator::job(${name}) allocation_older must be an integer")
  }

  if $alias_older and !(is_integer($alias_older)) {
    fail("curator::job(${name}) alias_older must be an integer")
  }

  if $snapshot_older and !(is_integer($snapshot_older)) {
    fail("curator::job(${name}) snapshot_older must be an integer")
  }

  if $snapshot_recent and !(is_integer($snapshot_recent)) {
    fail("curator::job(${name}) snapshot_recent must be an integer")
  }

  if $snapshot_delete_older and !(is_integer($snapshot_delete_older)) {
    fail("curator::job(${name}) snapshot_delete_older must be an integer")
  }

  if $disk_space and !(is_integer($disk_space)) {
    fail("curator::job(${name}) disk_space must be an integer")
  }

  if $delete_older and $disk_space {
    fail("curator::jon(${name}) specify either delete_older or disk_space")
  }

  # Wow that was a lot of validation
  $mo_string = $master_only ? {
    true    => ' --master-only',
    default => '',
  }

  $time_string = $timestring ? {
    undef   => "--time-unit ${time_unit}",
    default => "--time-unit ${time_unit} --timestring '${timestring}'",
  }

  $jobs = [
    $delete_older ? {
      undef   => '',
      default => "delete --older-than ${delete_older}",
    },
    $disk_space ? {
      undef   => '',
      default => "delete --disk-space ${disk_space}",
    },
    $close_older ? {
      undef   => '',
      default => "close --older-than ${close_older}",
    },
    $bloom_older ? {
      undef   => '',
      default => "bloom --older-than ${bloom_older}",
    },
    $optimize_older ? {
      undef   => '',
      default => "optimize --older-than ${optimize_older} --max_num_segments ${max_num_segments}",
    },
    $allocation_older ? {
      undef   => '',
      default => "allocation --older-than ${allocation_older} --rule ${rule}",
    },
    $alias_older ? {
      undef   => '',
      default => "alias --older-than ${alias_older} --alias ${alias_name}",
    },
    $snapshot_older ? {
      undef   => '',
      default => "snapshot --older-than ${snapshot_older} --repository ${repository}",
    },
    $snapshot_delete_older ? {
      undef   => '',
      default => "snapshot --delete-older-than ${snapshot_delete_older} --repository ${repository}",
    },
    $snapshot_recent ? {
      undef   => '',
      default => "snapshot --most-recent ${snapshot_recent} --repository ${repository}",
    },
  ]

  cron { "curator_${name}":
    command     => join(suffix(prefix(reject($jobs, '^\s*$'), "${path}${mo_string} --host ${host} --port ${port} --logfile ${logfile} "), " ${time_string} --prefix '${prefix}'"), ' && '),
    environment => $cron_environment,
    hour        => $cron_hour,
    minute      => $cron_minute,
    weekday     => $cron_weekday,
  }

}
