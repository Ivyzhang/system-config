# == Class: openstack_project::users
#
class openstack_project::users {
  # Make sure we have our UID/GID account minimums for dynamic users set higher
  # than we'll use for static assignments, so as to avoid future conflicts.
  include ::openstack_project::params
  file { '/etc/login.defs':
    ensure => present,
    group  => 'root',
    mode   => '0644',
    owner  => 'root',
    source => $::openstack_project::params::login_defs,
  }
  User::Virtual::Localuser {
    require => File['/etc/login.defs']
  }

}
