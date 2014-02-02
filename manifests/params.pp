# these parameters need to be accessed from several locations and
# should be considered to be constant
class kraken::params {

  case $::osfamily {
    'RedHat': {
      $http_service                = 'httpd'
      $httpd_config_file           = '/etc/httpd/conf.d/kraken.conf'
    }
    'Debian': {
      $http_service                = 'apache2'
      $httpd_config_file           = '/etc/apache2/conf.d/kraken.conf'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat and Debian")
    }
  }
}