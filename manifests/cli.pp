# == Class: koji::cli
#
# Manages the Koji CLI on a host.
#
# === Parameters
#
# ==== Required
#
# ==== Optional
#
# [*packages*]
#   An array of package names needed for the Koji CLI installation.
#
# [*profiles*]
#   A hash whose keys are profile names and whose values are hashes
#   comprising the same parameters you would otherwise pass to
#   Define[koji::cli::profile].
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016-2017 John Florian


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

    concat::fragment { "koji CLI configuration header":
        target  => '/etc/koji.conf',
        content => template('koji/cli/koji.conf.erb'),
        order   => '01',
    }

    create_resources(::koji::cli::profile, $profiles)

}
