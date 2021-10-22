#
# == Class: koji::hub
#
# Manages the Koji Hub component on a host.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# This file is part of the doubledog-koji Puppet module.
# Copyright 2016-2021 John Florian
# SPDX-License-Identifier: GPL-3.0-or-later


class koji::hub (
        String[1]               $db_host,
        String[1]               $db_passwd,
        Stdlib::Port            $db_port,
        String[1]               $db_user,
        Boolean                 $debug,
        String[1]               $email_domain,
        Array[String[1], 1]     $packages,
        Array[String[1]]        $plugins,
        Array[String[1]]        $proxy_auth_dns,
        String[1]               $top_dir,
        Koji::Traceback         $traceback,
        String[1]               $web_url,
    ) {

    package { $packages:
        ensure  => installed,
    }

    include 'koji::httpd'

    apache::module_config {
        '99-prefork':
            source => 'puppet:///modules/koji/httpd/99-prefork.conf',
            ;
        '99-worker':
            source => 'puppet:///modules/koji/httpd/99-worker.conf',
            ;
    }

    apache::site_config {
        'kojihub':
            content   => template('koji/hub/kojihub.conf.erb'),
            subscribe => Package[$packages],
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
            before    => Class['apache::service'],
            notify    => Class['apache::service'],
            subscribe => Package[$packages],
            ;
        [
            $top_dir,
            "${top_dir}/images",
            "${top_dir}/packages",
            "${top_dir}/repos",
            "${top_dir}/repos-dist",
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
            group   => 'apache',
            mode    => '0640',
            content => template('koji/hub/hub.conf.erb'),
            ;
    }

}
