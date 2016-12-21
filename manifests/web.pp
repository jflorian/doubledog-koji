# modules/koji/manifests/web.pp
#
# == Class: koji::web
#
# Manages the Koji Web component on a host.
#
# The Koji Web may be run on the same host as the Koji Hub, but that's not
# required.
#
# === Parameters
#
# ==== Required
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
# [*hidden_users*]
#   An array of the numeric IDs of users that you want to hide from tasks
#   listed on the front page.  You might want to, for instance, hide the
#   activity of an account used for continuous integration.  The default is to
#   not hide any user's tasks.
#
# [*login_timeout*]
#   Automatically logout users after this many hours.  The default is 72
#   hours.
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
        String[1] $files_url,
        String[1] $hub_ca_cert,
        String[1] $hub_url,
        String[1] $secret,
        String[1] $web_cert,
        Boolean $debug=false,
        Array[Integer] $hidden_users=[],
        Integer $login_timeout=72,
        String[1] $theme='default',
        Optional[String[1]] $theme_source=undef,
    ) inherits ::koji::params {

    package { $::koji::params::web_packages:
        ensure => installed,
    }

    include '::koji::httpd'

    ::apache::site_config {
        'kojiweb':
            content   => template('koji/web/kojiweb.conf'),
            subscribe => Package[$::koji::params::web_packages],
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
