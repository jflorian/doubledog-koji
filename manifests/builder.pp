#
# == Class: koji::builder
#
# Manages a host as a Koji Builder.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# This file is part of the doubledog-koji Puppet module.
# Copyright 2016-2018 John Florian
# SPDX-License-Identifier: GPL-3.0-or-later


class koji::builder (
        String[1]                                    $downloads,
        String[1]                                    $hub,
        Optional[String[1]]                          $hub_ca_cert_content,
        Optional[String[1]]                          $hub_ca_cert_source,
        Optional[String[1]]                          $kojid_cert_content,
        Optional[String[1]]                          $kojid_cert_source,
        String[1]                                    $top_dir,
        Array[String[1], 1]                          $allowed_scms,
        Boolean                                      $build_arch_can_fail,
        Boolean                                      $debug,
        Boolean                                      $enable,
        Variant[Boolean, Enum['running', 'stopped']] $ensure,
        Integer[0]                                   $failed_buildroot_lifetime,
        Boolean                                      $image_building,
        Array[String[1], 1]                          $imaging_packages,
        Integer[0]                                   $min_space,
        String[1]                                    $mock_dir,
        String[1]                                    $mock_user,
        Array[String[1], 1]                          $packages,
        String[1]                                    $service,
        String[1]                                    $smtp_host,
        Boolean                                      $use_createrepo_c,
        String[1]                                    $work_dir,
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
            content => template('koji/builder/kojid.conf.erb'),
            ;
        '/etc/sysconfig/kojid':
            content => template('koji/builder/kojid.erb'),
            ;
    }

    service { $service:
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => true,
        hasstatus  => true,
    }

}
