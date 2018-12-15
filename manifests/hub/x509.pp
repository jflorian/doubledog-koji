#
# == Class: koji::hub::x509
#
# Manages the X.509 certificates for the Koji Hub component on a host.
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


class koji::hub::x509 (
        Optional[String[1]]                   $client_ca_cert_content,
        Optional[String[1]]                   $client_ca_cert_source,
        Optional[String[1]]                   $hub_ca_cert_content,
        Optional[String[1]]                   $hub_ca_cert_source,
        Optional[String[1]]                   $hub_cert_content,
        Optional[String[1]]                   $hub_cert_source,
        Optional[String[1]]                   $hub_key_content,
        Optional[String[1]]                   $hub_key_source,
    ) {

    # The CA certificates are correct to use openssl::tls_certificate instead
    # of openssl::tls_ca_certificate because they don't need to be general
    # trust anchors.
    ::openssl::tls_certificate {
        default:
            notify => Class['::apache::service'],
            ;
        'koji-client-ca-chain':
            cert_content => $client_ca_cert_content,
            cert_source  => $client_ca_cert_source,
            ;
        'koji-hub-ca-chain':
            cert_content => $hub_ca_cert_content,
            cert_source  => $hub_ca_cert_source,
            ;
        'koji-hub':
            cert_content => $hub_cert_content,
            cert_source  => $hub_cert_source,
            key_content  => $hub_key_content,
            key_source   => $hub_key_source,
            ;
    }

}
