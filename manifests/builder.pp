# modules/koji/manifests/builder.pp
#
# == Class: koji::builder
#
# Manages a host as a Koji Builder.
#
# === Parameters
#
# ==== Required
#
# [*client_ca_cert*]
#   Puppet source URI providing the CA certificate which signed "kojid_cert".
#   This must be in PEM format and include all intermediate CA certificates,
#   sorted and concatenated from the leaf CA to the root CA.
#
# [*downloads*]
#   URL of your package download site.
#
# [*hub*]
#   URL of your Koji Hub service.
#
# [*hub_ca_cert*]
#   Puppet source URI providing the CA certificate which signed the Koji Hub
#   certificate.  This must be in PEM format and include all intermediate CA
#   certificates, sorted and concatenated from the leaf CA to the root CA.
#
# [*kojid_cert*]
#   Puppet source URI providing the builder's identity certificate which must
#   be in PEM format.
#
# [*top_dir*]
#   Name of the directory containing the "repos/" directory.
#
# ==== Optional
#
# [*allowed_scms*]
#   A space-separated list of tuples from which kojid is allowed to checkout.
#   The format of those tuples is:
#
#       host:repository[:use_common[:source_cmd]]
#
#   Incorrectly-formatted tuples will be ignored.
#
#   If use_common is not present, kojid will attempt to checkout a common/
#   directory from the repository.  If use_common is set to no, off, false, or
#   0, it will not attempt to checkout a common/ directory.
#
#   source_cmd is a shell command (args separated with commas instead of
#   spaces) to run before building the srpm.  It is generally used to retrieve
#   source files from a remote location.  If no source_cmd is specified, "make
#   sources" is run by default.
#
# [*debug*]
#   Enable verbose debugging for the Koji Builder.
#   One of: true or false (default).
#
# [*enable*]
#   Instance is to be started at boot.  Either true (default) or false.
#
# [*ensure*]
#   Instance is to be 'running' (default) or 'stopped'.  Alternatively,
#   a Boolean value may also be used with true equivalent to 'running' and
#   false equivalent to 'stopped'.
#
# [*failed_buildroot_lifetime*]
#   The number of seconds a buildroot should be retained by kojid after
#   a build failure occurs.  It is sometimes necessary to manually chroot into
#   the buildroot to determine exactly why a build failed and what might done
#   to resolve the issue.  The default is 4 hours (or 14,400 seconds).
#
#   It must be noted here that this feature is somewhat flakey because Koji
#   seems to set the expiration time based not on when the build started but
#   on some other event, likely when the buildroot was created.  This might
#   not sound all that different but bear in mind that kojid doesn't fully
#   destroy the build roots; it merely empties them.  So in effect, kojid can
#   reuse a buildroot -- one which may already be hours towards its
#   expiration.  If you wish to use this feature, you may want to use a value
#   of a day or more, but keep in mind you might then exhaust the storage
#   capacity of the "mock_dir".
#
# [*min_space*]
#   The minimum amount of free space (in MiB) required for each build root.
#
# [*mock_dir*]
#   The directory under which mock will do its work and create buildroots.
#   The default is '/var/lib/mock'.
#
# [*smtp_host*]
#   The mail host to use for sending email notifications.  The Koji Builder
#   must be able to connect to this host via TCP on port 25.  The default is
#   'localhost'.
#
# [*work_dir*]
#   Name of the directory where temporary work will be performed.  The default
#   is '/tmp/koji'.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


class koji::builder (
        String[1] $client_ca_cert,
        String[1] $downloads,
        String[1] $hub,
        String[1] $hub_ca_cert,
        String[1] $kojid_cert,
        String[1] $top_dir,
        Optional[String[1]] $allowed_scms=undef,
        Boolean $debug=false,
        Boolean $enable=true,
        Variant[Boolean, Enum['running', 'stopped']] $ensure='running',
        Integer $failed_buildroot_lifetime=60 * 60 * 4,
        Integer $min_space=8192,
        String[1] $mock_dir='/var/lib/mock',
        String[1] $smtp_host='localhost',
        String[1] $work_dir='/tmp/koji',
    ) inherits ::koji::params {

    package { $::koji::params::builder_packages:
        ensure => installed,
        notify => Service[$::koji::params::builder_services],
    }

    # The CA certificates are correct to use openssl::tls_certificate instead
    # of openssl::tls_ca_certificate because they don't need to be general
    # trust anchors.
    ::openssl::tls_certificate {
        'kojid-client-ca-chain':
            cert_name   => 'client-ca-chain',
            cert_path   => '/etc/kojid',
            cert_source => $client_ca_cert,
            notify      => Service[$::koji::params::builder_services],
            ;
        'kojid-hub-ca-chain':
            cert_name   => 'hub-ca-chain',
            cert_path   => '/etc/kojid',
            cert_source => $hub_ca_cert,
            notify      => Service[$::koji::params::builder_services],
            ;
        'kojid':
            cert_name   => 'kojid',
            cert_path   => '/etc/kojid',
            cert_source => $kojid_cert,
            notify      => Service[$::koji::params::builder_services],
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
            before    => Service[$::koji::params::builder_services],
            notify    => Service[$::koji::params::builder_services],
            subscribe => Package[$::koji::params::builder_packages],
            ;
        '/etc/kojid/kojid.conf':
            content => template('koji/builder/kojid.conf'),
            ;
        '/etc/sysconfig/kojid':
            content => template('koji/builder/kojid'),
            ;
    }

    service { $::koji::params::builder_services:
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => true,
        hasstatus  => true,
    }

}
