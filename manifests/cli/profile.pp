# == Define: koji::cli::profile
#
# Manages a Koji CLI configuration profile.
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


define koji::cli::profile (
        String[1]   $downloads,
        String[1]   $hub,
        String[1]   $top_dir,
        String[1]   $web,
        Enum['noauth', 'ssl', 'password', 'kerberos'] $auth_type='ssl',
        Integer     $max_retries=30,
        Boolean     $offline_retry=false,
        Integer     $offline_retry_interval=20,
        Integer     $retry_interval=20,
    ) {

    # Force the default profile to be first.  It looks better and may be
    # more robust.
    $order = $title ? {
        'koji'  => '02',
        default => '03',
    }

    concat::fragment { "koji profile '${title}'":
        target  => '/etc/koji.conf',
        content => template('koji/cli/profile.erb'),
        order   => $order,
    }

}
