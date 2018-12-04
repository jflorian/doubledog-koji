#
# == Class: koji::kojira
#
# Manages the Koji Kojira component on a host.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# This file is part of the doubledog-koji Puppet module.
# Copyright 2016-2018 John Florian
# SPDX-License-Identifier: GPL-3.0-or-later


class koji::kojira (
        String[1]                                    $hub,
        Optional[String[1]]                          $hub_ca_cert_content,
        Optional[String[1]]                          $hub_ca_cert_source,
        Optional[String[1]]                          $kojira_cert_content,
        Optional[String[1]]                          $kojira_cert_source,
        String[1]                                    $top_dir,
        Boolean                                      $debug,
        Integer[0]                                   $deleted_repo_lifetime,
        Integer[0]                                   $dist_repo_lifetime,
        Variant[Boolean, Enum['running', 'stopped']] $ensure,
        Boolean                                      $enable,
        String[1]                                    $service,
    ) {

    include '::koji::utils'

    # The CA certificates are correct to use openssl::tls_certificate instead
    # of openssl::tls_ca_certificate because they don't need to be general
    # trust anchors.
    ::openssl::tls_certificate {
        default:
            cert_path   => '/etc/kojira',
            notify      => Service[$service],
            ;
        'kojira-hub-ca-chain':
            cert_name    => 'hub-ca-chain',
            cert_content => $hub_ca_cert_content,
            cert_source  => $hub_ca_cert_source,
            ;
        'kojira':
            cert_name    => 'kojira',
            cert_content => $kojira_cert_content,
            cert_source  => $kojira_cert_source,
            ;
    }

    file { '/etc/kojira/kojira.conf':
        owner     => 'root',
        group     => 'root',
        mode      => '0644',
        seluser   => 'system_u',
        selrole   => 'object_r',
        seltype   => 'etc_t',
        content   => template('koji/kojira/kojira.conf.erb'),
        before    => Service[$service],
        notify    => Service[$service],
        subscribe => Class['::koji::utils'],
    }

    service { $service:
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => true,
        hasstatus  => true,
        subscribe  => Class['::koji::utils'],
    }

}
