#
class curator (
  $ensure       = 'latest',
  $package_name = 'python-elasticsearch-curator',
){

  package { $package_name:
    ensure  => $ensure,
  }
}
