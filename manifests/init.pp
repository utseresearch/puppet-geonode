# == Class: geonode
#
# A geonode setup
#
# === Parameters
#
# [*hostname*]
#   Intended host name for this server.
#
# === Examples
#
#  class { geonode:
#    hostname => 'blah@example.com',
#    geo_user => 'geonode',
#  }
#
# === Authors
#
# Paul Nguyen <Paul.Nguyen.Aus@gmail.com>
#
# === Copyright
#
# Copyright 2015 Paul Nguyen
#
class geonode (
    $hostname = $::geonode::params::hostname,
) inherits geonode::params {

    $tomcat_home = '/usr/share/tomcat'

    class { 'python':
        version    => 'system',
        dev        => true,
        virtualenv => true,
        # id dev not specified, module tries to get rid of it,
        # but is required for virtualenv
    }
    
    python::pip { 'geonode':
        ensure       => present,
        pkgname      => 'geonode',
        virtualenv   => '/home/geonode/git',
        install_args => ['-e /home/geonode/git'],
        owner        => 'geonode',
        timeout      => 1800,
        # remind me to specify these in a class so I can implement ordering
        require      => [
                            User['geonode'],
                            Package['libxml2-devel'],
                            Package['libxslt-devel']
                        ],
    }
    
    python::virtualenv { '/home/geonode/git':
        ensure  => present,
        version => 'system',
        owner   => 'geonode',
        systempkgs => true,
    }
    
    vcsrepo { '/home/geonode/git':
        ensure   => present,
        provider => git,
        source   => 'https://github.com/GeoNode/geonode.git',
        revision => '2.4b25',
        require  => User['geonode'],
    }
    
    ensure_resource('user', 'geonode', {
        managehome => true,
        home       => '/home/geonode',
        system     => true,
        ensure     => present,
    })
    
    file { '/home/geonode':
        mode => '0711',
    }

    class { 'java':
        distribution => 'jdk',
    }
    
    class { 'ant': }
    
    package { 'libxslt-devel': ensure => installed }
    package { 'libxml2-devel': ensure => installed }
    package { 'gdal-python': ensure => installed }
    package { 'proj-devel': ensure => installed }
    package { 'geos-devel': ensure => installed }
    package { 'postgis': ensure => installed }
    package { 'python-psycopg2': ensure => installed }
    
    class { 'tomcat':
      catalina_home       => $tomcat_home,
      install_from_source => false,
    }
  
    tomcat::war { 'geoserver.war':
      catalina_base => $tomcat_home,
      war_source    => 'http://build.geonode.org/geoserver/latest/geoserver.war',
    } ->
    tomcat::instance{ 'default':
      catalina_base => $tomcat_home,
      package_name  => 'tomcat',
    } ->
    tomcat::service { 'default': require => Python::Pip['geonode'] }

    #class { 'apache::mod::wsgi': 
    #}
    class { '::apache': }
    apache::vhost { $hostname:
        port                        => '80',
        docroot                     => '/home/geonode/git/geonode',
        docroot_owner               => 'geonode',
        docroot_group               => 'geonode',
        proxy_pass                  => [
            {
                'path' => '/geoserver',
                'url'  => 'http://localhost:8080/geoserver',
            }
        ],
        directories                 => [
            {   path           => '/home/geonode/git/geonode',
                options        => ['Indexes', 'FollowSymLinks'],
                allow_override => ['All'],
                index_options  => ['FancyIndexing'],
            }
        ],
        aliases                     => [
            {
                alias => '/static/',
                path  => '/home/geonode/git/geonode/static',
            },
            {
                alias => '/uploaded/',
                path  => '/home/geonode/git/geonode/uploaded',
            },
        ],
        proxy_preserve_host         => True,
        wsgi_daemon_process         => 'geonode python-path=/home/geonode/git/geonode:/home/geonode/git/lib/python2.7/site-packages',
        wsgi_daemon_process_options => {
            processes    => '2',
            threads      => '15',
            display-name => '%{GROUP}',
        },
        wsgi_process_group          => 'geonode',
        wsgi_script_aliases         => {
            '/' => '/home/geonode/git/geonode/wsgi.py',
        },
        wsgi_chunked_request        => 'On',
        require                     => User['geonode'],
    }
  


}
