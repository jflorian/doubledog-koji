# == Class: koji::web
#
# Manages the Koji Web component on a host.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016-2018 John Florian


class koji::web (
        String[1]           $files_url,
        String[1]           $hub_ca_cert,
        String[1]           $hub_url,
        String[1]           $secret,
        String[1]           $web_cert,
        Boolean             $debug,
        Array[Integer]      $hidden_users,
        Integer             $login_timeout,
        Array[String[1], 1] $packages,
        String[1]           $theme,
    ) {

    package { $packages:
        ensure => installed,
    }

    include '::koji::httpd'

    ::apache::site_config {
        'kojiweb':
            content   => template('koji/web/kojiweb.conf'),
            subscribe => Package[$packages],
            ;
    }

    # The CA certificates are correct to use openssl::tls_certificate instead
    # of openssl::tls_ca_certificate because they don't need to be general
    # trust anchors.
    ::openssl::tls_certificate {
        default:
            cert_path => '/etc/kojiweb',
            notify    => Class['::apache::service'],
            ;
        'kojiweb-hub-ca-chain':
            cert_name   => 'hub-ca-chain',
            cert_source => $hub_ca_cert,
            ;
        'kojiweb':
            cert_name   => 'web',
            cert_source => $web_cert,
            ;
    }

    file {
        default:
            owner     => 'root',
            group     => 'root',
            mode      => '0644',
            seluser   => 'system_u',
            selrole   => 'object_r',
            seltype   => 'etc_t',
            before    => Class['::apache::service'],
            notify    => Class['::apache::service'],
            subscribe => Package[$packages],
            ;
        '/etc/kojiweb/web.conf':
            content => template('koji/web/web.conf'),
            ;
    }

}
