# modules/koji/manifests/cli.pp
#
# == Class: koji::cli
#
# Manages the Koji CLI on a host.
#
# === Parameters
#
# ==== Required
#
# [*downloads*]
#   URL of your package download site.
#
# [*hub*]
#   URL of your Koji-Hub server.
#
# [*top_dir*]
#   Directory containing the "repos/" directory.
#
# [*web*]
#   URL of your Koji-Web server.
#
# ==== Optional
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


class koji::cli (
        $downloads,
        $hub,
        $top_dir,
        $web,
    ) inherits ::koji::params {

    package { $::koji::params::cli_packages:
        ensure  => installed,
    }

    File {
        owner     => 'root',
        group     => 'root',
        mode      => '0644',
        seluser   => 'system_u',
        selrole   => 'object_r',
        seltype   => 'etc_t',
        subscribe => Package[$::koji::params::cli_packages],
    }

    file { '/etc/koji.conf':
        content => template('koji/cli/koji.conf'),
    }

}
