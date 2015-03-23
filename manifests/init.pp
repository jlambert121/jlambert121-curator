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
  $ensure       = 'latest',
  $package_name = 'elasticsearch-curator',
  $provider     = 'pip',
) {

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
