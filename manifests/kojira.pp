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
#   Instance is to be 'running' (default) or 'stopped'.  Alternatively,
#   a Boolean value may also be used with true equivalent to 'running' and
#   false equivalent to 'stopped'.
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
        String[1] $hub,
        String[1] $hub_ca_cert,
        String[1] $kojira_cert,
        String[1] $top_dir,
        Variant[Boolean, Enum['running', 'stopped']] $ensure='running',
        Boolean $enable=true,
    ) inherits ::koji::params {

    include '::koji::packages::utils'

    # The CA certificates are correct to use openssl::tls_certificate instead
    # of openssl::tls_ca_certificate because they don't need to be general
    # trust anchors.
    ::openssl::tls_certificate {
        default:
            cert_path   => '/etc/kojira',
            notify      => Service[$::koji::params::kojira_services],
            ;
        'kojira-hub-ca-chain':
            cert_name   => 'hub-ca-chain',
            cert_source => $hub_ca_cert,
            ;
        'kojira':
            cert_name   => 'kojira',
            cert_source => $kojira_cert,
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
        subscribe  => Class['::koji::packages::utils'],
    }

}
