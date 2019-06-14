#
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
# This file is part of the doubledog-koji Puppet module.
# Copyright 2016-2019 John Florian
# SPDX-License-Identifier: GPL-3.0-or-later


class koji::web (
        Boolean             $debug,
        String[1]           $files_url,
        Array[Integer]      $hidden_users,
        String[1]           $hub_url,
        Integer             $login_timeout,
        Array[String[1], 1] $packages,
        String[1]           $secret,
        String[1]           $theme,
    ) {

    package { $packages:
        ensure => installed,
    }

    include 'koji::httpd'

    apache::site_config {
        'kojiweb':
            content   => template('koji/web/kojiweb.conf.erb'),
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
        '/etc/kojiweb/web.conf':
            content => template('koji/web/web.conf.erb'),
            ;
    }

}
