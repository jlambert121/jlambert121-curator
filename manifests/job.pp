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
# [*separator*]
#   String.  Time unit separator.
#   Default: .
#
# [*time_unit*]
#   String.  Unit of time to reckon by: [days, hours]
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
  $path             = '/usr/bin/curator',
  $host             = 'localhost',
  $port             = 9200,
  $prefix           = 'logstash-',
  $separator        = '.',
  $time_unit        = 'days',
  $delete_older     = undef,
  $close_older      = undef,
  $bloom_older      = undef,
  $optimize_older   = undef,
  $allocation_older = undef,
  $alias_older      = undef,
  $snapshot_older   = undef,
  $disk_space       = undef,
  $alias_name       = undef,
  $repository       = undef,
  $rule             = undef,
  $max_num_segments = 2,
  $logfile          = '/var/log/curator.log',
  $cron_weekday     = '*',
  $cron_hour        = 1,
  $cron_minute      = 10,
){

  $commands = [ $delete_older, $disk_space, $close_older, $bloom_older, $optimize_older, $allocation_older, $alias_older, $snapshot_older ]
  $compacted = inline_template('<%= @commands.reject! { |e| e == :undef } %>')

  if size($commands) == 0 {
    fail('One of delete_older, disk_space, close_older, bloom_older, optimize_older, allocation_older, alias_older, or snapshot_older is required')
  }

  if size($commands) > 1 {
    if size($commands) == 0 {
      fail('Only one of delete_older, disk_space, close_older, bloom_older, optimize_older, allocation_older, alias_older, or snapshot_older is allowed')
    }
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

  if $disk_space and !(is_integer($disk_space)) {
    fail("curator::job(${name}) disk_space must be an integer")
  }

  # Wow that was a lot of validation
  if $delete_older {
    $d_string = " delete --older-than ${delete_older}"
  } else {
    $d_string = ''
  }

  if $disk_space {
    $g_string = " delete --disk-space ${disk_space}"
  } else {
    $g_string = ''
  }

  if $close_older {
    $c_string = " close --older-than ${close_older}"
  } else {
    $c_string = ''
  }

  if $bloom_older {
    $b_string = " bloom --older-than ${bloom_older}"
  } else {
    $b_string = ''
  }

  if $optimize_older {
    $o_string = " optimize --older-than ${optimize_older} --max_num_segments ${max_num_segments}"
  } else {
    $o_string = ''
  }

  if $allocation_older {
    $a_string = " allocation --older-than ${allocation_older} --rule ${rule}"
  } else {
    $a_string = ''
  }

  if $alias_older {
    $a2_string = " alias --older-than ${alias_older} --alias ${alias_name}"
  } else {
    $a2_string = ''
  }

  if $snapshot_older {
    $s_string = " snapshot --older-than ${snapshot_older} --repository ${repository}"
  } else {
    $s_string = ''
  }

  cron { "curator_${name}":
    command => "${path}${d_string}${c_string}${b_string}${o_string}${a_string}${a2_string}${s_string}${g_string} -T ${time_unit} --host ${host} --port ${port} -p '${prefix}' -s '${separator}' -l ${logfile}",
    hour    => $cron_hour,
    minute  => $cron_minute,
    weekday => $cron_weekday,
  }

}
