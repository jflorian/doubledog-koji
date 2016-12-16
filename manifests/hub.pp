# modules/koji/manifests/hub.pp
#
# == Class: koji::hub
#
# Manages the Koji Hub component on a host.
#
# This manages the Koji Hub, an XML-RPC server running under mod_wsgi in
# Apache's httpd.  It also manages Koji's skeleton file system.
#
# === Parameters
#
# ==== Required
#
# [*client_ca_cert*]
#   Puppet source URI providing the CA certificate which signed the client
#   certificates that wish to connect to this Koji Hub.  This must be in PEM
#   format and include all intermediate CA certificates, sorted and
#   concatenated from the leaf CA to the root CA.
#
# [*db_host*]
#   Name of host that provides the Koji database.
#
# [*db_passwd*]
#   Password for the Koji database connection.
#
# [*db_user*]
#   User name for the Koji database connection.
#
# [*hub_ca_cert*]
#   Puppet source URI providing the CA certificate which signed "hub_cert".
#   This must be in PEM format and include all intermediate CA certificates,
#   sorted and concatenated from the leaf CA to the root CA.
#
# [*hub_cert*]
#   Puppet source URI providing the Koji Hub's certificate.  This must be in
#   PEM format.
#
# [*hub_key*]
#   Puppet source URI providing the private key that was used to sign the
#   Koji Hub's certificate contained in "hub_cert".  This must be in PEM
#   format.
#
# [*top_dir*]
#   Directory containing the "repos/" directory.
#
# [*proxy_auth_dns*]
#   An array of Distinguished Names (DN) of the clients allowed to proxy SSL
#   authentication requests through the Koji Hub.
#
# ==== Optional
#
# [*debug*]
#   Enable verbose debugging for the Koji Hub.
#   One of: true or false (default).
#
# [*email_domain*]
#   The domain name that will be append to Koji user names when creating email
#   notifications.  Defaults to the $domain fact.
#
# [*plugins*]
#   A list of Koji Hub plugins that are to be enabled.  This should be an
#   array of strings, each representing one plugin.  The default is for no
#   plugins to be enabled.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


class koji::hub (
        $client_ca_cert,
        $db_host,
        $db_passwd,
        $db_user,
        $hub_ca_cert,
        $hub_cert,
        $hub_key,
        $top_dir,
        $proxy_auth_dns,
        $debug=false,
        $email_domain=$::domain,
        $plugins=[],
    ) inherits ::koji::params {

    validate_bool($debug)
    validate_array($proxy_auth_dns)

    package { $::koji::params::hub_packages:
        ensure  => installed,
    }

    class { '::apache':
        anon_write         => true,
        network_connect_db => true,
        use_nfs            => true,
    }

    include '::apache::mod_ssl'

    ::apache::module_config {
        '99-prefork':
            source => 'puppet:///modules/koji/httpd/99-prefork.conf',
            ;
        '99-worker':
            source => 'puppet:///modules/koji/httpd/99-worker.conf',
            ;
    }

    ::apache::site_config {
        'ssl':
            content   => template("koji/hub/ssl.conf.${::operatingsystem}.${::operatingsystemmajrelease}"),
            subscribe => Class['::apache::mod_ssl'],
            ;
        'kojihub':
            content   => template('koji/hub/kojihub.conf'),
            subscribe => Package[$::koji::params::hub_packages],
            ;
    }

    ::Openssl::Tls_certificate {
        notify => Class['::apache::service'],
    }

    # The CA certificates are correct to use openssl::tls_certificate instead
    # of openssl::tls_ca_certificate because they don't need to be general
    # trust anchors.
    ::openssl::tls_certificate {
        'koji-client-ca-chain':
            cert_source => $client_ca_cert,
            ;
        'koji-hub-ca-chain':
            cert_source => $hub_ca_cert,
            ;
        'koji-hub':
            cert_source => $hub_cert,
            key_source  => $hub_key,
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
            subscribe => Package[$::koji::params::hub_packages],
            ;
        [
            "${top_dir}/images",
            "${top_dir}/packages",
            "${top_dir}/repos",
            "${top_dir}/repos/signed",
            "${top_dir}/scratch",
            "${top_dir}/work",
        ]:
            ensure  => directory,
            owner   => 'apache',
            group   => 'apache',
            mode    => '0755',
            seltype => 'public_content_rw_t',
            ;
        '/etc/koji-hub/hub.conf':
            content => template('koji/hub/hub.conf'),
            ;
    }

}
