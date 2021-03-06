# == Class: openstack_project::template
#
# A template host with no running services
#
class openstack_project::template (
  $iptables_public_tcp_ports = [],
  $iptables_public_udp_ports = [],
  $iptables_rules4           = [],
  $iptables_rules6           = [],
  $snmp_v4hosts              = [],
  $snmp_v6hosts              = [],
  $pin_puppet                = '3.',
  $install_users             = false,
  $install_resolv_conf       = false,
  $certname                  = $::fqdn,
  $ca_server                 = undef,
  $afs                       = false,
  $puppetmaster_server       = 'puppet-master-prod.openstacklocal',
  $afs_cache_size            = 500000,
  $sysadmins                 = [],
  $permit_root_login         = 'yes',
) {

  ###########################################################
  # Classes for all hosts

  include openstack_project::users

  if ( $afs ) {
    $all_udp = concat(
      $iptables_public_udp_ports, [7001])

    class { 'openafs::client':
      cell         => 'openstack.org',
      realm        => 'OPENSTACK.ORG',
      admin_server => 'kdc.openstack.org',
      cache_size   => $afs_cache_size,
      kdcs         => [
        'kdc01.openstack.org',
        'kdc02.openstack.org',
      ],
    }
  } else {
    $all_udp = $iptables_public_udp_ports
  }

  class { 'iptables':
    public_tcp_ports => $iptables_public_tcp_ports,
    public_udp_ports => $all_udp,
    rules4           => $iptables_rules4,
    rules6           => $iptables_rules6,
    snmp_v4hosts     => $snmp_v4hosts,
    snmp_v6hosts     => $snmp_v6hosts,
  }

  class {'openstack_project::users_install':
    install_users => $install_users
  }

  if ($::osfamily == 'Debian') {
    # NOTE(pabelanger): Puppetlabs only support Ubuntu Trusty and below,
    # anything greater will use the OS version of puppet.
    if ($::operatingsystemrelease < '15.04') {
      include ::apt
      apt::source { 'puppetlabs':
        location => 'http://apt.puppetlabs.com',
        repos    => 'main',
        key      => {
          'id'     =>'47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
          'server' => 'pgp.mit.edu',
        },
      }
    }

    file { '/etc/security/limits.d/60-nofile-limit.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///modules/openstack_project/debian_limits.conf',
      replace => true,
    }

    file { '/etc/apt/apt.conf.d/80retry':
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/80retry',
      replace => true,
    }

    file { '/etc/apt/apt.conf.d/90no-translations':
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/90no-translations',
      replace => true,
    }
  }

  if ($::operatingsystem == 'CentOS') {
    file { '/etc/yum.repos.d/puppetlabs.repo':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/centos7-puppetlabs.repo',
      replace => true,
    }
  }

  ###########################################################

}
