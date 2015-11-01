    secret_key          => hiera('grafana_secret_key'),
# Node-OS: trusty
node 'health.openstack.org' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'openstack_project::openstack_health_api':
    subunit2sql_db_host => hiera('subunit2sql_db_host', 'localhost'),
  }
}



# node-OS: precise
node 'ci-puppet-master.openstacklocal' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [4505, 4506, 8140],
    sysadmins                 => hiera('sysadmins', []),
    pin_puppet                => '3.6.',
  }
  class { 'openstack_project::puppetmaster':
    root_rsa_key => hiera('puppetmaster_root_rsa_key', 'XXX'),
  }
}

node 'ci-zuul.openstacklocal' {
    iptables_public_tcp_ports => [22],
  }
  class { 'openstack_project::subunit_worker':
                                   '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 9200:9400 -s \1 -j ACCEPT')
  $iptables_clients_rule = regsubst ($elasticsearch_clients,
                                     '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 9200:9400 -s \1 -j ACCEPT')
  $iptables_rule = flatten([$iptables_nodes_rule, $iptables_clients_rule])
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22],
    iptables_rules6           => $iptables_rule,
    iptables_rules4           => $iptables_rule,
  class { 'openstack_project::zuul_prod':
    project_config_repo            => 'https://git.openstack.org/openstack-infra/project-config',
    gerrit_server                  => 'review.openstack.org',
    gerrit_user                    => 'jenkins',
    gerrit_ssh_host_key            => hiera('gerrit_ssh_rsa_pubkey_contents'),
    zuul_ssh_private_key           => hiera('zuul_ssh_private_key_contents'),
    url_pattern                    => 'http://logs.openstack.org/{build.parameters[LOG_PATH]}',
    swift_authurl                  => 'https://identity.api.rackspacecloud.com/v2.0/',
    swift_user                     => 'infra-files-rw',
    swift_key                      => hiera('infra_files_rw_password'),
    swift_tenant_name              => hiera('infra_files_tenant_name', 'tenantname'),
    swift_region_name              => 'DFW',
    swift_default_container        => 'infra-files',
    swift_default_logserver_prefix => 'http://logs.openstack.org/',
    swift_default_expiry           => 14400,
    proxy_ssl_cert_file_contents   => '',
    zuul_url                       => 'http://zuul.openstack.org/p',
    sysadmins                      => hiera('sysadmins', []),
    statsd_host                    => 'graphite.openstack.org',
    gearman_workers                => [
      'nodepool.openstack.org',
    ],
  }  
}

  }
}

# Node-OS: trusty
node 'codesearch.openstack.org' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    sysadmins                 => hiera('sysadmins', []),
  }
  class { 'openstack_project::codesearch':
    project_config_repo => 'https://git.openstack.org/openstack-infra/project-config',