#
# == Class: koji::gc
#
# Manages the Koji garbage collector on a host.
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


class koji::gc (
        String[1]                               $client_cert_source,
        String[1]                               $hub,
        String[1]                               $hub_ca_cert_source,
        Hash[String, Pattern[/[0-9A-F]{8}/], 1] $keys,
        String[1]                               $owner,
        String[1]                               $top_dir,
        String[1]                               $web,
        String[1]                               $email_domain,
        String[1]                               $grace_period,
        String[1]                               $group=$owner,
        Integer                                 $oldest_scratch,
        String[1]                               $smtp_host,
        Array[Pattern[/[0-9A-F]{8}/]]           $unprotected_keys,
    ) {

    include '::koji::utils'

    file {
        default:
            owner     => $owner,
            group     => $group,
            mode      => '0640',
            seluser   => 'system_u',
            selrole   => 'object_r',
            seltype   => 'etc_t',
            subscribe => Class['::koji::utils'],
            ;
        '/etc/koji-gc/client.pem':
            source  => $client_cert_source,
            ;
        '/etc/koji-gc/serverca.crt':
            source  => $hub_ca_cert_source,
            ;
    }

    ::concat { 'koji-gc.conf':
        path      => '/etc/koji-gc/koji-gc.conf',
        owner     => 'root',
        group     => 'root',
        mode      => '0644',
        seluser   => 'system_u',
        selrole   => 'object_r',
        seltype   => 'etc_t',
        subscribe => Class['::koji::utils'],
    }

    ::concat::fragment { 'koji-gc.conf-top':
        target  => 'koji-gc.conf',
        order   => '000',
        content => template('koji/gc/koji-gc.conf'),
    }

    ::cron::job {
        'koji-gc':
            command => 'koji-gc',
            user    => $owner,
            hour    => '4',
            minute  => '42',
            mailto  => '',
            ;
    }

}
