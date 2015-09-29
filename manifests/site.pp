
# node-OS: precise
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

node 'ci-zuul' {
  $iptables_rules = regsubst ($gearman_workers, '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 4730 -s \1 -j ACCEPT')
  $gerrit_ssh_host_key = hiera('upstream_gerrit_ssh_rsa_pubkey_contents', 'XXX')
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443, 5666], # http=80, https=443, nrpe=5666
    iptables_rules6           => $iptables_rules,
    iptables_rules4           => $iptables_rules,
    sysadmins                 => hiera('sysadmins'),
  }
}
