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
# [*jobs*]
#
#   Hash. Manage your jobs in hiera (or manifest).
#   Default: {}
#
# [*manage_repo*]
#   Boolean. Enable repo management by enabling the official repositories.
#   Default: false
#
# [*provider*]
#   String.  Name of the provider to install the package with.
#            If not specified will use system's default provider.
#   Default: undef
#
# [*repo_version*]
#   String.  Elastic repositories  are versioned per major release (2, 3)
#            select here which version you want.
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
class curator (
                                                            $ensure               = $::curator::params::ensure,
  String                                                    $package_name         = $::curator::params::package_name,
  Optional[String]                                          $provider             = $::curator::params::provider,
  String                                                    $bin_file             = $::curator::params::bin_file,
  String                                                    $host                 = $::curator::params::host,
  Integer                                                   $port                 = $::curator::params::port,
  Boolean                                                   $use_ssl              = $::curator::params::use_ssl,
  Boolean                                                   $ssl_validate         = $::curator::params::ssl_validate,
  Optional[String]                                          $ssl_certificate_path = $::curator::params::ssl_certificate_path,
  Optional[Boolean]                                         $http_auth            = $::curator::params::http_auth,
  Optional[String]                                          $user                 = $::curator::params::user,
  Optional[String]                                          $password             = $::curator::params::password,
  Hash                                                      $jobs                 = $::curator::params::jobs,
  String                                                    $logfile              = $::curator::params::logfile,
  Enum['CRITICAL', 'ERROR', 'WARNING', 'INFO', 'DEBUG', ''] $log_level            = $::curator::params::log_level,
  String                                                    $logformat            = $::curator::params::logformat,
  Boolean                                                   $manage_repo          = $::curator::params::manage_repo,
  Variant[String, Boolean, Undef]                           $repo_version         = $::curator::params::repo_version,
) inherits curator::params {

  if ( $ensure != 'latest' or $ensure != 'absent' ) {
    if versioncmp($ensure, '3.0.0') < 0 {
      fail('This version of the module only supports version 3.0.0 or later of curator')
    }
  }

  case $manage_repo {
    true: {
      case $::osfamily {
        'Debian': {
          $_package_name = 'python-elasticsearch-curator'
          $_provider     = 'apt'
        }
        'RedHat': {
          $_package_name = 'python-elasticsearch-curator'
          $_provider     = 'yum'
        }
        default: {
          $_package_name = 'elasticsearch-curator'
          $_provider     = 'pip'
        }
      }
    }
    default: {
      $_package_name = $package_name
      $_provider     = $provider
    }
  }

  create_resources('curator::job', $jobs)

  if ($manage_repo == true) {
    # Set up repositories
    class { '::curator::repo': } ->
    package { $_package_name:
      ensure   => $ensure,
      provider => $_provider,
    }
  } else {
    package { $_package_name:
      ensure   => $ensure,
      provider => $_provider,
    }
  }
}
