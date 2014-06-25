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

  case $provider {
    pip: {
      package { 'elasticsearch-curator':
        ensure   => $ensure,
        provider => pip,
      }
    }
    default: {
      package { 'python-elasticsearch-curator': ensure => $ensure }
    }
  }

  if $manage_pip {
    package { 'python-pip': ensure => installed }
  }
}
