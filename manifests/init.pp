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
# [*manage_pip*]
#   Bool.  If true require the pip package. If false do nothing.
#   Default: false
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
#
# === Copyright
#
# Copyright 2014 EvenUp.
#
class curator (
  $ensure       = 'latest',
  $provider     = undef,
  $manage_pip   = false
) {

  if ( $ensure != 'latest' or $ensure != 'absent' ) {
    if versioncmp($ensure, '1.1.0') < 0 {
      fail('This version of the module only supports version 1.1.0 or later of curator')
    }
  }

  if $manage_pip {
    package { 'python-pip':
      ensure => installed,
      before => Package['elasticsearch-curator'],
    }
  }

  case $provider {
    pip: {
      package { 'elasticsearch-curator':
        ensure   => $ensure,
        provider => pip,
      }
    }
    default: {
      package { 'python-elasticsearch-curator':
        ensure => $ensure
      }
    }
  }

}
