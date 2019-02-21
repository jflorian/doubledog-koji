#
# == Class: koji::web::x509
#
# Manages the X.509 certificates for the Koji Web component on a host.
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


class koji::web::x509 (
        Optional[String[1]] $hub_ca_cert_content,
        Optional[String[1]] $hub_ca_cert_source,
        Optional[String[1]] $web_cert_content,
        Optional[String[1]] $web_cert_source,
    ) {

    include '::koji::web'

    # The CA certificates are correct to use openssl::tls_certificate instead
    # of openssl::tls_ca_certificate because they don't need to be general
    # trust anchors.
    ::openssl::tls_certificate {
        default:
            cert_path => '/etc/kojiweb',
            notify    => Class['::apache::service'],
            require   => Package[$::koji::web::packages],
            ;
        'kojiweb-hub-ca-chain':
            cert_name    => 'hub-ca-chain',
            cert_content => $hub_ca_cert_content,
            cert_source  => $hub_ca_cert_source,
            ;
        'kojiweb':
            cert_name    => 'web',
            cert_content => $web_cert_content,
            cert_source  => $web_cert_source,
            ;
    }

}
