# == Class: kraken::apache::wsgi
#
# Configures Apache WSGI for Kraken.
#
# === Parameters
#
#  [*docroot*]
#    Where the kraken files will reside
#
#  [*bind_address*]
#    Address to which the vhost will bind.
#
#  [*server_name*]
#    Hostname with which the vhost will be configured.
#
class kraken::apache::wsgi (
  $bind_address,
  $docroot,
  $server_name,
) {

  include ::apache
  include ::apache::mod::wsgi

  file { $::kraken::params::httpd_config_file:
    ensure  => present,
    content => template("${module_name}/kraken-vhost.erb")
  }

  File[$::kraken::params::httpd_config_file] ~> Service[$::kraken::params::http_service]

}