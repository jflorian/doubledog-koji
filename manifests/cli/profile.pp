# modules/koji/manifests/cli/profile.pp
#
# == Define: koji::cli::profile
#
# Manages a Koji CLI configuration profile.
#
# Profiles can be utilized by the Koji CLI using:
#       koji -p|--profile PROFILE
#
# Without the -p/--profile option, the Koji CLI will use a default profile
# named 'koji'.
#
# === Parameters
#
# ==== Required
#
# [*namevar*]
#   An identifier for the configuration profile instance.  Specify 'koji' to
#   configure the default profile.
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
# Copyright 2016-2017 John Florian


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
