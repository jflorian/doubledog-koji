#
# == Class: koji::builder::x509
#
# Manages X.509 certificates on a host acting as a Koji Builder.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# This file is part of the doubledog-koji Puppet module.
# Copyright 2018-2019 John Florian
# SPDX-License-Identifier: GPL-3.0-or-later


class koji::builder::x509 (
        Optional[String[1]] $hub_ca_cert_content,
        Optional[String[1]] $hub_ca_cert_source,
        Optional[String[1]] $kojid_cert_content,
        Optional[String[1]] $kojid_cert_source,
    ) {

    include 'koji::builder'

    # The CA certificates are correct to use openssl::tls_certificate instead
    # of openssl::tls_ca_certificate because they don't need to be general
    # trust anchors.
    openssl::tls_certificate {
        default:
            cert_path => '/etc/kojid',
            notify    => Service[$koji::builder::service],
            require   => Package[$koji::builder::packages],
            ;
        'kojid-hub-ca-chain':
            cert_name    => 'hub-ca-chain',
            cert_content => $hub_ca_cert_content,
            cert_source  => $hub_ca_cert_source,
            ;
        'kojid':
            cert_name    => 'kojid',
            cert_content => $kojid_cert_content,
            cert_source  => $kojid_cert_source,
            ;
    }

}
