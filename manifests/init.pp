# == Class: kraken
#
# Installs kraken ceph dashboard with Apache
#
# === Parameters
#
#  [*bind_address*]
#    (Optional) Address to which the vhost will bind. (Defaults to '*')
#
#  [*docroot*]
#    (Optional) Where the kraken files will reside. (Defaults to '/usr/share/krakendash')
#
#  [*endpoint*]
#    (Optional) The ceph-rest-api endpoint. (Defaults to 'http://127.0.0.1:5000/api/v0.1/')
#
#  [*server_name*]
#    (Optional) Hostname with which the vhost will be configured. (Defaults to $::fqdn)
#
#  [*repository*]
#    (Optional) Repository to clone krakendash from (Defaults to 'https://github.com/krakendash/krakendash.git')
#

class kraken(
  $bind_address = '*',
  $docroot      = '/usr/share/krakendash',
  $endpoint     = 'http://127.0.0.1:5000/api/v0.1/',
  $server_name  = $::fqdn,
  $repository   = 'https://github.com/krakendash/krakendash.git',
) {

  class { 'apt':
    always_apt_update => true,
  }

  Class['Apt']             -> Package <| |>
  Class['Apt::Update']     -> Package <| |>

  Exec <| title=='apt_update' |> {
    refreshonly => false,
  }

  include ::kraken::params

  package { [
    'python-dev',
    'python-pip',
    'libxml2-dev',
    'libxslt-dev',
    'git',
  ]:
    ensure  => present,
  }->

  package { [
    'python-cephclient',
    'django',
    'humanize',
  ]:
    ensure   => latest,
    provider => 'pip',
  }

  class { 'kraken::apache::wsgi':
    bind_address => $bind_address,
    docroot      => $docroot,
    server_name  => $server_name,
  }

  exec { 'Clone krakendash':
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => "git clone ${repository} ${docroot}",
    require => Package['git'],
    creates => $docroot
  }

  exec { 'Configure endpoint':
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => "sed -i -e \"/CEPH_BASE_URL =/ s,= .*,= '${endpoint}',\" ${docroot}/kraken/kraken/settings.py",
    require => Exec['Clone krakendash'],
    notify  => Service[$::kraken::params::http_service]
  }
}