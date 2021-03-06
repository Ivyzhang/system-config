#
# Default: should at least behave like an openstack server
#
node default {
  class { 'openstack_project::server':
    sysadmins => hiera('sysadmins', []),
  }
}

#node-OS: precise
node 'puppet-master-prod.openstacklocal' {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [8140],
    sysadmins                 => hiera('sysadmins', []),
    pin_puppet                => '3.6.',
  }
  class { 'openstack_project::puppetmaster':
    root_rsa_key        => hiera('puppetmaster_root_rsa_key'),
    jenkins_api_user    => hiera('jenkins_api_user', 'username'),
    jenkins_api_key     => hiera('jenkins_api_key'),
    puppetmaster_update_cron_interval => hiera('cron_interval'),
    update_cron => hiera('update_cron')
  }
}

node 'zuul-prod.openstacklocal' {
  class { 'openstack_project::zuul_prod':
    project_config_repo            => 'https://gitlabhost.rtp.raleigh.ibm.com/ocata/project-config.git',
    gerrit_server                  => 'review.openstack.org',
    gerrit_user                    => 'ibm_storage_ci',
    gerrit_ssh_host_key            => hiera('gerrit_ssh_rsa_pubkey_contents'),
    zuul_ssh_private_key           => hiera('zuul_ssh_private_key_contents'),
    url_pattern                    => 'http://dal05.objectstorage.softlayer.net/v1/AUTH_0bd27569-6310-44fc-8a8d-36a112cac4ec/IBM-STORAGE-CI/{job.name}/{build.number}',
    swift_authurl                  => 'https://identity.api.rackspacecloud.com/v2.0/',
    swift_user                     => 'infra-files-rw',
    swift_key                      => hiera('infra_files_rw_password', 'XXX'),
    swift_tenant_name              => hiera('infra_files_tenant_name', 'tenantname'),
    swift_region_name              => 'DFW',
    swift_default_container        => 'infra-files',
    swift_default_logserver_prefix => 'http://logs.openstack.org/',
    swift_default_expiry           => 14400,
    proxy_ssl_cert_file_contents   => hiera('zuul_ssl_cert_file_contents'),
    proxy_ssl_key_file_contents    => hiera('zuul_ssl_key_file_contents'),
    proxy_ssl_chain_file_contents  => hiera('zuul_ssl_chain_file_contents'),
    zuul_url                       => 'http://zuul.openstack.org/p',
    sysadmins                      => hiera('sysadmins', []),
    statsd_host                    => 'graphite.openstack.org',
    gearman_workers                => [
      'nodepool-prod.openstacklocal',
      'jenkins-master-prod.openstacklocal',
      'zuul-prod.openstacklocal',
    ],
  }

  class { 'openstackci::zuul_merger':
    vhost_name               => $::fqdn,
    gearman_server           => 'zuul-prod.openstacklocal',
    gerrit_server            => 'review.openstack.org',
    gerrit_user              => 'ibm_storage_ci',
    zuul_ssh_private_key     => hiera('zuul_ssh_private_key_contents'),
    zuul_url                 => "http://${::fqdn}/p",
    git_email                => 'jenkins@openstack.org',
    git_name                 => 'OpenStack Jenkins',
    manage_common_zuul       => false,
  }
}

node 'jenkins-master-prod.openstacklocal' {
  $group = "jenkins"
  $zmq_event_receivers = ['nodepool-prod.openstacklocal']
  $iptables_rule = regsubst ($zmq_event_receivers,
                             '^(.*)$', '-m state --state NEW -m tcp -p tcp --dport 8888 -s \1 -j ACCEPT')
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80, 443],
    iptables_rules6           => $iptables_rule,
    iptables_rules4           => $iptables_rule,
    sysadmins                 => hiera('sysadmins', []),
    puppetmaster_server       => 'puppet-master-prod.openstacklocal',
  }
  class { 'openstack_project::jenkins':
    project_config_repo     => 'https://gitlabhost.rtp.raleigh.ibm.com/ocata/project-config.git',
    jenkins_username	    => hiera('jenkins_username'),
    jenkins_password        => hiera('jenkins_jobs_password'),
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    ssl_cert_file           => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    ssl_key_file            => '/etc/ssl/private/ssl-cert-snakeoil.key',
    ssl_chain_file          => '',
  }
}

node 'nodepool-prod.openstacklocal' {
  $clouds_yaml = template("openstack_project/nodepool/clouds.yaml.erb") 
  $zk_receivers = ['nodepool-prod.openstacklocal']

  class { 'openstack_project::server':
    sysadmins                 => hiera('sysadmins', []),
    iptables_public_tcp_ports => [80],
# Node-OS: centos7
  }

  class { '::zookeeper': }

  include openstack_project

  class { '::openstackci::nodepool':
    vhost_name               => 'nodepool-prod.openstacklocal',
    project_config_repo      => 'https://gitlabhost.rtp.raleigh.ibm.com/ocata/project-config.git',
    mysql_password           => hiera('nodepool_mysql_password'),
    mysql_root_password      => hiera('nodepool_mysql_root_password'),
    nodepool_ssh_private_key => hiera('jenkins_ssh_private_key_contents'),
    oscc_file_contents       => $clouds_yaml,
    image_log_document_root  => '/var/log/nodepool/image',
    logging_conf_template    => 'openstack_project/nodepool/nodepool.logging.conf.erb',
    jenkins_masters          => [
      {
        name        => 'jenkins-master-prod.openstacklocal',
        url         => 'https://jenkins-master-prod.openstacklocal/',
        user        => hiera('jenkins_api_user', 'jenkins'),
        apikey      => hiera('jenkins_api_key'),
        credentials => hiera('jenkins_credentials_id'),
      },
    ],
  }
}

# Node-OS: centos7
# Node-OS: fedora24
# Node-OS: fedora25
# Node-OS: jessie
# Node-OS: trusty
# Node-OS: xenial
# This is not meant to be an actual node that connects to the master.
# This is a dummy node definition to trigger a test of the code path used by
# nodepool's prepare_node scripts in the apply tests
# NOTE(pabelanger): These are the current settings we use for devstack-* nodes.
node 'single-use-slave-devstack' {
  class { 'openstack_project::single_use_slave':
    sudo => true,
  }
}

