# == Definition: curator::job
#
# Schedules an elasticsearch curator maintainence job
#
#
define curator::job (
                                        $command,
                                        $ensure               = 'present',
                                        $sub_command          = 'indices',
                                        $bin_file             = $::curator::bin_file,

  # ES config
                                        $host                 = $::curator::host,
  Integer                               $port                 = $::curator::port,

  # Auth options
  Boolean                               $use_ssl              = $::curator::use_ssl,
  Boolean                               $ssl_validate         = $::curator::ssl_validate,
  Optional[String]                      $ssl_certificate_path = $::curator::ssl_certificate_path,
  Optional[Boolean]                     $http_auth            = $::curator::http_auth,
  Optional[String]                      $user                 = $::curator::user,
  Optional[String]                      $password             = $::curator::password,

  # Options for all indexes
                                        $prefix               = 'logstash-',
                                        $suffix               = undef,
                                        $regex                = undef,
  Variant[String, Array[String], Undef] $exclude              = undef,
  Variant[String, Array[String], Undef] $index                = undef,
  Variant[String, Array[String], Undef] $snapshot             = undef,
  Variant[Integer, Undef]               $older_than           = undef,
  Variant[Integer, Undef]               $newer_than           = undef,
                                        $time_unit            = 'days',
                                        $timestring           = '\%Y.\%m.\%d',
  Boolean                               $master_only          = false,
                                        $logfile              = $::curator::logfile,
                                        $log_level            = $::curator::log_level,
                                        $logformat            = $::curator::logformat,

  # Alias options
                                        $alias_name           = undef,
  Boolean                               $remove               = false,

  # Allocation options
                                        $rule                 = undef,

  # Delete options
  Variant[Integer, Undef]               $disk_space           = undef,

                                        # Optimize options
  Integer                               $delay                = 0,
  Integer                               $max_num_segments     = 2,
  Integer                               $request_timeout      = 218600,

                                        # Replicas options
  Integer                               $count                = 2,

                                        # Snapshot options
                                        $repository           = undef,

                                        # Cron params
                                        $cron_weekday         = '*',
                                        $cron_hour            = 1,
                                        $cron_minute          = 10,
){

  include ::curator

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

  $_timestring = "--timestring '${timestring}'"

  if !member(['days', 'hours', 'weeks', 'months'], $time_unit) {
    fail("curator::job[${name}] time_unit must be hours, days, weeks, or months")
  } else {
    $_time_unit = "--time-unit ${time_unit}"
  }

  if $exclude {
    $_exclude = inline_template("<%= Array(@exclude).map { |element| \"--exclude \'#{element}\'\" }.join(' ') %>")
  } else {
    $_exclude = undef
  }

  if $index {
    $_index = inline_template("<%= Array(@index).map { |element| \"--index #{element}\" }.join(' ') %>")
  } else {
    $_index = undef
  }

  if $snapshot {
    $_snapshot = inline_template("<%= Array(@snapshot).map { |element| \"--snapshot #{element}\" }.join(' ') %>")
  } else {
    $_snapshot = undef
  }

  if $older_than {
    $_older_than = "--older-than ${older_than}"
  } else {
    $_older_than = undef
  }

  if $newer_than {
    $_newer_than = "--newer-than ${newer_than}"
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
      if $remove {
        $_remove = '--remove'
      } else {
        $_remove = undef
      }

      $exec = join(delete_undef_values(["alias --name ${alias_name}", $_remove, 'indices']), ' ')
    }
    'allocation': {
      # allocation validations
      if !$rule {
        fail("curator::job[${name}] rule is required with allocation")
      }

      $exec = "allocation --rule ${rule} indices"
    }
    'close', 'open': {
      $exec = "${command} indices"
    }
    'delete': {
      # delete validations
      if !member(['indices', 'snapshots'], $sub_command) {
        fail("curator::job[${name}] delete command supports indices and snapshots sub_command")
      }
      if $disk_space {
        $_ds = "--disk-space ${disk_space}"
      } else {
        $_ds = undef
      }
      if $repository {
        $_repo = "--repository ${repository}"
      } else {
        $_repo = undef
      }

      $exec = join(delete_undef_values(['delete', $_ds, $sub_command, $_repo]), ' ')
    }
    'optimize': {
      # optimize validations
      $_delay    = " --delay ${delay}"
      $_segments = " --max_num_segments ${max_num_segments}"
      $_timeout  = " --request_timeout ${request_timeout}"

      $exec = "optimize${_delay}${_segments}${_timeout} indices"
    }
    'replicas': {
      $exec = "replicas --count ${count} indices"
    }
    'snapshot': {
      if !$repository {
        fail("curator::job[${name}] repository is required")
      }

      $exec = "snapshot --repository ${repository} indices"
    }
    default: {
      fail("curator::job[${name}]: command must be alias, allocation, close, delete, open, optimize, replicas, or snapshot")
    }
  }

  $mo_string = $master_only ? {
    true    => '--master-only',
    default => undef,
  }

  $ssl_string = $use_ssl ? {
    true    => '--use_ssl',
    default => undef,
  }

  if $use_ssl {
    if $ssl_validate {
      $ssl_no_validate = undef
    } else {
      $ssl_no_validate = '--ssl-no-validate'
    }
    if $ssl_certificate_path != undef {
      $ssl_certificate = "--certificate ${ssl_certificate_path}"
    } else {
      $ssl_certificate = undef
    }
  } else {
    $ssl_certificate = undef
    $ssl_no_validate = undef
  }

  if $http_auth {
    $auth_string = "--http_auth ${user}:${password}"
  } else {
    $auth_string = undef
  }

  $index_options = join(delete_undef_values([$_prefix, $_suffix, $_regex, $_time_unit, $_exclude, $_index, $_snapshot, $_older_than, $_newer_than, $_timestring]), ' ')
  $options = join(delete_undef_values([$mo_string, $ssl_string, $ssl_certificate, $ssl_no_validate, $auth_string]), ' ')

  cron { "curator_${name}":
    ensure  => $ensure,
    command => "${bin_file} --logfile ${logfile} --loglevel ${log_level} --logformat ${logformat} ${options} --host ${host} --port ${port} ${exec} ${index_options} >/dev/null",
    hour    => $cron_hour,
    minute  => $cron_minute,
    weekday => $cron_weekday,
  }

}
