
#node-OS: precise
node 'ci-puppet-master.openstacklocal' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [4505, 4506, 8140],
    sysadmins                 => hiera('sysadmins', []),
    pin_puppet                => '3.6.',
  }
  class { 'openstack_project::puppetmaster':
    root_rsa_key => hiera('puppetmaster_root_rsa_key', 'XXX'),
    jenkins_api_user => hiera('jenkins_api_user', 'username'),
    jenkins_api_key  => hiera('jenkins_api_key', 'XXX'),
    update_cron => false
  }
}

node 'ci-zuul.openstacklocal' {
  class { 'openstack_project::zuul_prod':
    project_config_repo            => 'ssh://xivgit.xiv.ibm.com/git/host/devops/openstack_ci/project_config.git',
    gerrit_server                  => 'review.openstack.org',
    gerrit_user                    => 'ibm_storage_ci',
    gerrit_ssh_host_key            => hiera('gerrit_ssh_rsa_pubkey_contents'),
    zuul_ssh_private_key           => hiera('zuul_ssh_private_key_contents'),
    url_pattern                    => 'http://logs.openstack.org/{build.parameters[LOG_PATH]}',
    swift_authurl                  => 'https://identity.api.rackspacecloud.com/v2.0/',
    swift_user                     => 'infra-files-rw',
    swift_key                      => hiera('infra_files_rw_password', 'XXX'),
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

node 'ci-jenkins-master.openstacklocal' {
#  $group = "jenkins"
#  $zmq_event_receivers = ['logstash.openstack.org',
#                          'nodepool.openstack.org']
#  $iptables_rule = regsubst ($zmq_event_receivers,
#                             '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 8888 -s \1 -j ACCEPT')
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    iptables_rules6           => $iptables_rule,
    iptables_rules4           => $iptables_rule,
    sysadmins                 => hiera('sysadmins', []),
    puppetmaster_server       => 'ci-puppet-master.openstacklocal',
  }
#  class { 'openstack_project::jenkins':
#    project_config_repo     => 'https://git.openstack.org/openstack-infra/project-config',
#    jenkins_password        => hiera('jenkins_jobs_password'),
#    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
#    ssl_cert_file           => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
#    ssl_key_file            => '/etc/ssl/private/ssl-cert-snakeoil.key',
#    ssl_chain_file          => '',
#  }
}

