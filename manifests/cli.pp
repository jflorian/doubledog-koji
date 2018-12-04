# == Class: koji::cli
#
# Manages the Koji CLI on a host.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016-2018 John Florian


class koji::cli (
        Array[String[1], 1]     $packages,
        Hash[String[1], Hash]   $profiles,
    ) {

    package { $packages:
        ensure => installed,
    }

    concat { '/etc/koji.conf':
        owner     => 'root',
        group     => 'root',
        mode      => '0644',
        seluser   => 'system_u',
        selrole   => 'object_r',
        seltype   => 'etc_t',
        subscribe => Package[$packages],
    }

    concat::fragment { 'koji CLI configuration header':
        target  => '/etc/koji.conf',
        content => template('koji/cli/koji.conf.erb'),
        order   => '01',
    }

    create_resources(::koji::cli::profile, $profiles)

}
