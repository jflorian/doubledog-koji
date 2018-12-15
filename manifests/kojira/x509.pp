#
# == Class: koji::kojira::x509
#
# Manages the X.509 certificates for the Koji Kojira component on a host.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# This file is part of the doubledog-koji Puppet module.
# Copyright 2018 John Florian
# SPDX-License-Identifier: GPL-3.0-or-later


class koji::kojira::x509 (
        Optional[String[1]] $hub_ca_cert_content,
        Optional[String[1]] $hub_ca_cert_source,
        Optional[String[1]] $kojira_cert_content,
        Optional[String[1]] $kojira_cert_source,
    ) {

    include '::koji::kojira'

    # The CA certificates are correct to use openssl::tls_certificate instead
    # of openssl::tls_ca_certificate because they don't need to be general
    # trust anchors.
    ::openssl::tls_certificate {
        default:
            cert_path => '/etc/kojira',
            notify    => Service[$::koji::kojira::service],
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

}
