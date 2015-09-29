
node-OS: precise
node 'ci-puppet-master' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [4505, 4506, 8140],
    sysadmins                 => hiera('sysadmins', []),
    pin_puppet                => '3.6.',
  }
  class { 'openstack_project::puppetmaster':
    root_rsa_key => hiera('puppetmaster_root_rsa_key', 'XXX'),
  }
}

