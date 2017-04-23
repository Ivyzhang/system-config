# == Class: openstack_project::zuul_prod
#
class openstack_project::zuul_prod(
  $vhost_name = $::fqdn,
  $gearman_server = '127.0.0.1',
  $gerrit_server = 'review.openstack.org',
  $gerrit_user = 'ibm_storage_ci',
  $gerrit_ssh_host_key = '',
  $zuul_ssh_private_key = '',
  $layout_file_name = 'ibm-layout.yaml',
  $url_pattern = '',
  $zuul_url = '',
  $status_url = 'http://status.openstack.org/zuul/',
  $swift_authurl = '',
  $swift_auth_version = '',
  $swift_user = '',
  $swift_key = '',
  $swift_tenant_name = '',
  $swift_region_name = '',
  $swift_default_container = '',
  $swift_default_logserver_prefix = '',
  $swift_default_expiry = 7200,
  $proxy_ssl_cert_file_contents = '',
  $proxy_ssl_key_file_contents = '',
  $proxy_ssl_chain_file_contents = '',
  $statsd_host = '',
  $project_config_repo = '',
  $git_email = 'jenkins@openstack.org',
  $git_name = 'OpenStack Jenkins',
) {
  class { 'openstackci::zuul_scheduler':
    vhost_name                     => $vhost_name,
    gearman_server                 => $gearman_server,
    gerrit_server                  => $gerrit_server,
    gerrit_user                    => $gerrit_user,
    known_hosts_content            => "review.openstack.org ${gerrit_ssh_host_key}",
    zuul_ssh_private_key           => $zuul_ssh_private_key,
    layout_file_name               => $layout_file_name,
    url_pattern                    => $url_pattern,
    zuul_url                       => $zuul_url,
    job_name_in_report             => true,
    status_url                     => $status_url,
    swift_authurl                  => $swift_authurl,
    swift_auth_version             => $swift_auth_version,
    swift_user                     => $swift_user,
    swift_key                      => $swift_key,
    swift_tenant_name              => $swift_tenant_name,
    swift_region_name              => $swift_region_name,
    swift_default_container        => $swift_default_container,
    swift_default_logserver_prefix => $swift_default_logserver_prefix,
    swift_default_expiry           => $swift_default_expiry,
    proxy_ssl_cert_file_contents   => $proxy_ssl_cert_file_contents,
    proxy_ssl_key_file_contents    => $proxy_ssl_key_file_contents,
    proxy_ssl_chain_file_contents  => $proxy_ssl_chain_file_contents,
    statsd_host                    => $statsd_host,
    project_config_repo            => $project_config_repo,
    git_email                      => $git_email,
    git_name                       => $git_name,
  }
}
