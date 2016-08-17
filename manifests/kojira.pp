# modules/koji/manifests/kojira.pp
#
# == Class: koji::kojira
#
# Manages the Koji Kojira component on a host.
#
# === Parameters
#
# ==== Required
#
# [*client_ca_cert*]
#   Puppet source URI providing the CA certificate which signed "kojira_cert".
#   This must be in PEM format and include all intermediate CA certificates,
#   sorted and concatenated from the leaf CA to the root CA.
#
# [*hub*]
#   URL of your Koji Hub service.
#
# [*hub_ca_cert*]
#   Puppet source URI providing the CA certificate which signed the Koji Hub
#   certificate.  This must be in PEM format and include all intermediate CA
#   certificates, sorted and concatenated from the leaf CA to the root CA.
#
# [*kojira_cert*]
#   Puppet source URI providing the Kojira component's identity certificate
#   which must be in PEM format.
#
# [*top_dir*]
#   Name of the directory containing the "repos/" directory.
#
# ==== Optional
#
# [*ensure*]
#   Instance is to be 'running' (default) or 'stopped'.
#
# [*enable*]
#   Instance is to be started at boot.  Either true (default) or false.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


class koji::kojira (
        $client_ca_cert,
        $hub,
        $hub_ca_cert,
        $kojira_cert,
        $top_dir,
        $ensure='running',
        $enable=true,
    ) inherits ::koji::params {

    package { $::koji::params::utils_packages:
        ensure => installed,
        notify => Service[$::koji::params::kojira_services],
    }

    # The CA certificates are correct to use openssl::tls_certificate instead
    # of openssl::tls_ca_certificate because they don't need to be general
    # trust anchors.
    #
    # Also note that attempting to move common values into a default resource
    # type is problematic due to Puppet's bizzare scoping which looks to
    # conflict/share with type defaults from Class[koji::hub].
    ::openssl::tls_certificate {
        'kojira-client-ca-chain':
            cert_name   => 'client-ca-chain',
            cert_path   => '/etc/kojira',
            cert_source => $client_ca_cert,
            notify      => Service[$::koji::params::kojira_services],
            ;
        'kojira-hub-ca-chain':
            cert_name   => 'hub-ca-chain',
            cert_path   => '/etc/kojira',
            cert_source => $hub_ca_cert,
            notify      => Service[$::koji::params::kojira_services],
            ;
        'kojira':
            cert_name   => 'kojira',
            cert_path   => '/etc/kojira',
            cert_source => $kojira_cert,
            notify      => Service[$::koji::params::kojira_services],
            ;
    }

    file { '/etc/kojira/kojira.conf':
        owner     => 'root',
        group     => 'root',
        mode      => '0644',
        seluser   => 'system_u',
        selrole   => 'object_r',
        seltype   => 'etc_t',
        content   => template('koji/kojira/kojira.conf'),
        before    => Service[$::koji::params::kojira_services],
        notify    => Service[$::koji::params::kojira_services],
        subscribe => Package[$::koji::params::utils_packages],
    }

    service { $::koji::params::kojira_services:
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => true,
        hasstatus  => true,
    }

}
