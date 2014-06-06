#
define curator::job (
  $path             = '/usr/bin/curator',
  $host             = 'localhost',
  $port             = 9200,
  $timeout          = 30,
  $prefix           = 'logstash-',
  $separator        = '.',
  $curation_style   = 'time',
  $time_unit        = 'days',
  $delete_older     = undef,
  $close_older      = undef,
  $bloom_older      = undef,
  $optimize_older   = undef,
  $disk_space       = undef,
  $max_num_segments = 2,
  $logfile          = '/var/log/curator.log',
  $cron_weekday     = '*',
  $cron_hour        = 1,
  $cron_minute      = 10,
){

  if !(member(['time', 'space'], $curation_style)) {
    fail("curator::job(${name}) curation_style must be 'time' or 'space'")
  }

  if !(member(['days', 'hours'], $time_unit) ){
    fail("curator::job(${name}) time_unit must be 'days' or 'hours'")
  }

  if !(is_integer($port)) {
    fail("curator::job(${name}) port must be integer")
  }

  if !(is_integer($timeout)) {
    fail("curator::job(${name}) timeout must be an integer (seconds)")
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

  if !($delete_older or $close_older or $bloom_older or $optimize_older) and $curation_style != 'space' {
    fail ("curator::job(${name}) delete_older, close_older, bloom_older, or optimize_older, or curation_style='space' is required")
  }

  if $curation_style == 'space' {
    if !(is_integer($disk_space)) {
      fail("curator::job(${name}) disk_space must be an integer when using curation_style='space'")
    }

    if $delete_older {
      fail("curator::job(${name}) cannot combine curation_style='space' and delete_older")
    }
  } elsif $disk_space and !(is_integer($disk_space)) {
    fail("curator::job(${name}) curation_style must be 'space' when setting disk_space")
  }

  if $optimize_older and $timeout < 3600 {
    warning("curator::job(${name}) optimize_older is set with a timeout of ${timeout}.  The minimum recommended timeout is 3600")
  }

  # Wow that was a lot of validation
  if $delete_older {
    $d_string = " -d ${delete_older}"
  } else {
    $d_string = ''
  }

  if $close_older {
    $c_string = " -c ${close_older}"
  } else {
    $c_string = ''
  }

  if $bloom_older {
    $b_string = " -b ${bloom_older}"
  } else {
    $b_string = ''
  }

  if $optimize_older {
    $o_string = " -o ${optimize_older} --max_num_segments ${max_num_segments}"
  } else {
    $o_string = ''
  }

  if $curation_style == 'space' {
    $g_string = " -g ${disk_space}"
  } else {
    $g_string = ''
  }

  cron { "curator_${name}":
    command => "${path} --host ${host} --port ${port} -t ${timeout} -p '${prefix}' -s '${separator}' -C ${curation_style} -T ${time_unit} -l ${logfile}${d_string}${c_string}${b_string}${o_string}${g_string}",
    hour    => $cron_hour,
    minute  => $cron_minute,
    weekday => $cron_weekday,
  }

}
