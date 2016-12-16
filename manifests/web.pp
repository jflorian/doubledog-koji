# modules/koji/manifests/web.pp
#
# == Class: koji::web
#
# Manages the Koji Web component on a host.
#
# === Assumptions
#
# This class presently assumes that the Koji Web component is deployed on the
# same host as the Koji Hub component.  Additional work in the Puppet
# resources would be required to allow these to be split apart since both
# components require Apache httpd and mod_ssl support.
#
# === Parameters
#
# ==== Required
#
# [*client_ca_cert*]
#   Puppet source URI providing the CA certificate which signed "web_cert".
#   This must be in PEM format and include all intermediate CA certificates,
#   sorted and concatenated from the leaf CA to the root CA.
#
# [*files_url*]
#   URL for accessing Koji's file resources.
#
# [*hub_ca_cert*]
#   Puppet source URI providing the CA certificate which signed the Koji Hub
#   certificate.  This must be in PEM format and include all intermediate CA
#   certificates, sorted and concatenated from the leaf CA to the root CA.
#
# [*hub_url*]
#   URL for accessing the Koji Hub's RPC services.
#
# [*web_cert*]
#   Puppet source URI providing the Koji Web's certificate.  This must be in
#   PEM format.
#
# [*secret*]
#   Undocumented by the Koji project, but required.  Pass in a reasonably long
#   random string.  It is unknown where/how this is used exactly without
#   deeper investigation, but you won't need during normal use.
#
# ==== Optional
#
# [*debug*]
#   Enable verbose debugging for the Koji Web.  When enabled, a full traceback
#   will be shown to the client for unhandled exceptions.
#   One of: true or false (default).
#
# [*theme*]
#   Name of the web theme that Koji is to use.  Content under
#   /usr/share/koji-web/static/themes/$theme will be used instead of the
#   normal files under /usr/share/koji-web/static/.  Any absent files will
#   fall back to the normal files.
#
# [*theme_source*]
#   This should point to a gzipped tarball providing content for the named
#   "theme".  The default is to not install an alternate theme.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


class koji::web (
        $client_ca_cert,
        $files_url,
        $hub_ca_cert,
        $hub_url,
        $secret,
        $web_cert,
        $debug=false,
        $theme='default',
        $theme_source=undef,
    ) inherits ::koji::params {

    package { $::koji::params::web_packages:
        ensure => installed,
    }

    # Duplicates that in koji::hub.  See assumptions note above.
    #   class { '::apache':
    #       network_connect_db => true,
    #       anon_write         => true,
    #   }

    include '::apache::mod_ssl'

    ::apache::site_config {
        # Duplicates that in koji::hub.  See assumptions note above.
        #   'ssl':
        #       source    => 'puppet:///modules/koji/httpd/ssl.conf',
        #       subscribe => Class['apache::mod_ssl'];
        'kojiweb':
            content   => template('koji/web/kojiweb.conf'),
            subscribe => Package[$::koji::params::web_packages];
    }

    # The CA certificates are correct to use openssl::tls_certificate instead
    # of openssl::tls_ca_certificate because they don't need to be general
    # trust anchors.
    #
    # Also note that attempting to move common values into a default resource
    # type is problematic due to Puppet's bizzare scoping which looks to
    # conflict/share with type defaults from Class[koji::hub].
    ::openssl::tls_certificate {
        'kojiweb-client-ca-chain':
            cert_name   => 'client-ca-chain',
            cert_path   => '/etc/kojiweb',
            cert_source => $client_ca_cert,
            notify      => Class['::apache::service'],
            ;
        'kojiweb-hub-ca-chain':
            cert_name   => 'hub-ca-chain',
            cert_path   => '/etc/kojiweb',
            cert_source => $hub_ca_cert,
            notify      => Class['::apache::service'],
            ;
        'kojiweb':
            cert_name   => 'web',
            cert_path   => '/etc/kojiweb',
            cert_source => $web_cert,
            notify      => Class['::apache::service'],
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
            subscribe => Package[$::koji::params::web_packages],
            ;
        '/etc/kojiweb/web.conf':
            content => template('koji/web/web.conf'),
            ;
    }

    if $theme_source {
        $themes_dir = '/usr/share/koji-web/static/themes'
        $theme_path = "${themes_dir}/${theme}"
        $theme_tgz = "${theme_path}.tgz"
        file { $theme_tgz:
            source => $theme_source,
        } ->
        exec { "tar xzf ${theme_tgz}":
            cwd     => $themes_dir,
            creates => $theme_path,
        }
    }

}
