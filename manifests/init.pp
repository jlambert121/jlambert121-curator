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
# [*package_name*]
#   String.  Name of the package to be installed
#   Default: python-elasticsearch-curator
#
#
# === Examples
#
# * Installation:
#     class { 'curator': }
#
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
  $package_name = 'python-elasticsearch-curator',
){

  package { $package_name:
    ensure  => $ensure,
  }
}
