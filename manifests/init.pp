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
class geonode {

    class { 'python':
        version    => 'system',
        dev        => true,
        virtualenv => true,
        # id dev not specified, module tries to get rid of it, but is required for virtualenv
    }
    
    python::pip { 'geonode':
        ensure       => present,
        pkgname      => 'geonode',
        virtualenv   => '/home/geonode/git',
        install_args => ['-e /home/geonode/git'],
        owner        => 'geonode',
        timeout      => 1800,
        require      => [ User['geonode'], Package['libxml2-devel'], Package['libxslt-devel'] ],
    }
    
    python::virtualenv { '/home/geonode/git':
        ensure     => present,
        version    => 'system',
        owner      => 'geonode',
    }
    
    vcsrepo { '/home/geonode/git':
        ensure     => present,
        provider   => git,
        source     => 'https://github.com/GeoNode/geonode.git',
        revision   => '2.4b25',
        require    => User['geonode'],
    }
    
    ensure_resource('user', 'geonode', {
        managehome => true,
        home       => '/home/geonode',
        system     => true,
        ensure     => present,
    })
    
    class { 'java':
        distribution => 'jdk',
    }
    
    class { 'ant': }
    
    package { 'libxslt-devel': ensure => installed }
    package { 'libxml2-devel': ensure => installed }
    
    class { 'tomcat':
      catalina_home    => '/usr/share/tomcat',
      install_from_source => false,
    } 
  
    tomcat::war { 'geoserver.war':
      catalina_base    => '/usr/share/tomcat',
      war_source       => 'http://build.geonode.org/geoserver/latest/geoserver.war',
    } ->
    tomcat::instance{ 'default':
      catalina_base    => '/usr/share/tomcat',
      package_name        => 'tomcat',
    } ->
    tomcat::service { 'default': require => Python::Pip['geonode'] }


}
