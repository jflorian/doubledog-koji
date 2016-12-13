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
# [*auth_type*]
#   The method the client should use to authenticate itself to the Koji-Hub.
#   Must be one of: 'noauth', 'ssl', 'password', or 'kerberos'.  The default
#   is 'ssl'.
#
# [*max_retries*]
#   When making Koji calls, if the Koji Hub reports a temporary failure, how
#   many times should the call be retried?  The default is 30.
#
# [*offline_retry*]
#   When making Koji calls, if the Koji Hub reports itself as offline, should
#   the call be retried automatically?  The default is false.
#
#   Note that offline failures are treated specially from other temporary
#   failures.  These are not constrained by other failure handling options,
#   most notably "max_retries".
#
# [*offline_retry_interval*]
#   When making Koji calls, if the Koji Hub reports itself as offline and
#   "offline_retry" is true, this determines how many seconds the Koji Client
#   will wait before attempting the call again.  The default is 20 seconds.
#
# [*retry_interval*]
#   When making Koji calls, if the Koji Hub reports a temporary failure, this
#   determines how many seconds the Koji Client will wait before attempting
#   the call again.  The default is 20 seconds.
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
        Enum['noauth', 'ssl', 'password', 'kerberos'] $auth_type='ssl',
        $max_retries=30,
        $offline_retry=false,
        $offline_retry_interval=20,
        $retry_interval=20,
    ) inherits ::koji::params {

    validate_bool($offline_retry)
    validate_integer($max_retries)
    validate_integer($offline_retry_interval)
    validate_integer($retry_interval)

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
