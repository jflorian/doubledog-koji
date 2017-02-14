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
# [*allowed_scms*]
#   An array of tuples from which kojid is allowed to checkout.  The format of
#   each tuple is:
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
# [*build_arch_can_fail*]
#   Don't cancel subtask when other fails.  In some cases it makes sense to
#   continue with sibling task even if some of them already failed.  E.g.,
#   with a kernel build it could be of use if submitter knows for which archs
#   it succeed and for which it fails.  Repeated builds could take a lot of
#   time and resources.  Note, that this shouldn't be enabled ordinarily as it
#   could result in unnecessary resource consumption.  The default is false.
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
# [*image_building*]
#   If true, additional packages will be installed to permit this host to
#   perform image building tasks.  The default is false.
#
# [*imaging_packages*]
#   An array of extra package names needed for the Koji Builder installation
#   when "image_building" is true.
#
# [*min_space*]
#   The minimum amount of free space (in MiB) required for each build root.
#
# [*mock_dir*]
#   The directory under which mock will do its work and create buildroots.
#   The default is '/var/lib/mock'.
#
# [*packages*]
#   An array of package names needed for the Koji Builder installation.
#
# [*service*]
#   The service name of the Koji Builder daemon.
#
# [*smtp_host*]
#   The mail host to use for sending email notifications.  The Koji Builder
#   must be able to connect to this host via TCP on port 25.  The default is
#   'localhost'.
#
# [*use_createrepo_c*]
#   Enable using createrepo_c instread of createrepo.  The default is false.
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
# Copyright 2016-2017 John Florian


class koji::builder (
        String[1]           $downloads,
        String[1]           $hub,
        String[1]           $hub_ca_cert,
        String[1]           $kojid_cert,
        String[1]           $top_dir,
        Array[String[1], 1] $allowed_scms,
        Boolean             $build_arch_can_fail,
        Boolean             $debug,
        Boolean             $enable,
        Variant[Boolean, Enum['running', 'stopped']] $ensure,
        Integer[0]          $failed_buildroot_lifetime,
        Boolean             $image_building,
        Array[String[1], 1] $imaging_packages,
        Integer[0]          $min_space,
        String[1]           $mock_dir,
        Array[String[1], 1] $packages,
        String[1]           $service,
        String[1]           $smtp_host,
        Boolean             $use_createrepo_c,
        String[1]           $work_dir,
    ) {

    package { $packages:
        ensure => installed,
        notify => Service[$service],
    }

    if $image_building {
        package { $imaging_packages:
            ensure => installed,
            notify => Service[$service],
        }
    }

    # The CA certificates are correct to use openssl::tls_certificate instead
    # of openssl::tls_ca_certificate because they don't need to be general
    # trust anchors.
    ::openssl::tls_certificate {
        default:
            cert_path => '/etc/kojid',
            notify    => Service[$service],
            ;
        'kojid-hub-ca-chain':
            cert_name   => 'hub-ca-chain',
            cert_source => $hub_ca_cert,
            ;
        'kojid':
            cert_name   => 'kojid',
            cert_source => $kojid_cert,
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
            before    => Service[$service],
            notify    => Service[$service],
            subscribe => Package[$packages],
            ;
        '/etc/kojid/kojid.conf':
            content => template('koji/builder/kojid.conf'),
            ;
        '/etc/sysconfig/kojid':
            content => template('koji/builder/kojid'),
            ;
    }

    service { $service:
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => true,
        hasstatus  => true,
    }

}
