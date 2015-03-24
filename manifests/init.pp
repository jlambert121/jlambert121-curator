# == Class: curator
#
# Installs elasticsearch-curator and provides a definition to schedule jobs
#
#
# === Parameters
#
# [*ensure*]
#   String.  Version of curator to be installed
#   Default: latest
#
# [*provider*]
#   String.  Name of the provider to install the package with.
#            If not specified will use system's default provider.
#   Default: undef
#
# === Examples
#
# * Installation:
#     class { 'curator': }
#
# * Installation with pip:
#     class { 'curator':
#       provider   => 'pip',
#       manage_pip => true,
#     }
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class curator (
  $ensure       = $::curator::params::ensure,
  $package_name = $::curator::params::package_name,
  $provider     = $::curator::params::provider,
  $bin_file     = $::curator::params::bin_file,
  $host         = $::curator::params::host,
  $port         = $::curator::params::port,
  $logfile      = $::curator::params::logfile,
  $log_level    = $::curator::params::log_level,
  $logformat    = $::curator::params::logformat,
) inherits curator::params {

  if ( $ensure != 'latest' or $ensure != 'absent' ) {
    if versioncmp($ensure, '3.0.0') < 0 {
      fail('This version of the module only supports version 3.0.0 or later of curator')
    }
  }

  package { $package_name:
    ensure   => $ensure,
    provider => $provider,
  }

}
