# modules/koji/manifests/mash.pp
#
# == Class: koji::mash
#
# Manages the mashing of Koji builds into package repositories usable by tools
# such as yum and dnf.
#
# === Parameters
#
# ==== Required
#
# [*hub*]
#   URL of your Koji Hub service.
#
# [*repo_dir*]
#   Name of the directory that is to be synchronized with the repository tree
#   composited from each of the mashed repositories.
#
# [*repo_owner*]
#   User to own the "repo_dir" and the content therein.
#
# [*top_dir*]
#   Name of the directory containing the "repos/" directory.
#
# ==== Optional
#
# [*enable*]
#   Instance is to be started at boot.  Either true (default) or false.
#
# [*ensure*]
#   Instance is to be 'running' (default) or 'stopped'.
#
# [*rest_secs*]
#   The number seconds to rest after all of the repositories have been mashed
#   before starting all over again.
#   The default is 300 seconds (5 minutes).
#
# === See Also
#
#   Define[koji::mash::repo]
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


class koji::mash (
        $hub,
        $repo_dir,
        $repo_owner,
        $top_dir,
        $enable=true,
        $ensure='running',
        $rest_secs=300,
    ) inherits ::koji::params {

    validate_re($hub, '^.+$', 'hub cannot be null')
    validate_re($repo_dir, '^.+$', 'repo_dir cannot be null')
    validate_re($repo_owner, '^.+$', 'repo_owner cannot be null')
    validate_re($top_dir, '^.+$', 'top_dir cannot be null')
    validate_integer($rest_secs, undef, -1)

    include '::koji::helpers'

    File {
        owner     => 'root',
        group     => 'root',
        mode      => '0644',
        seluser   => 'system_u',
        selrole   => 'object_r',
        seltype   => 'etc_t',
        before    => Service[$::koji::params::mash_everything_service],
        notify    => Service[$::koji::params::mash_everything_service],
        subscribe => Package[$::koji::params::helpers_package],
    }

    file {
        '/etc/koji-helpers/mash-everything.conf':
            content => template('koji/mash/mash-everything.conf.erb'),
            ;

        $::koji::params::mash_work_dir:
            ensure  => directory,
            owner   => $repo_owner,
            group   => $repo_owner,
            mode    => '0755',
            seltype => 'var_t',
            ;
    }

    concat { $::koji::params::mash_everything_conf:
        ensure => 'present',
    }

    concat::fragment { 'mashes-header':
        target  => $::koji::params::mash_everything_conf,
        content => template('koji/mash/mashes.conf.erb'),
        order   => '01',
    }

    service { $::koji::params::mash_everything_service:
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => true,
        hasstatus  => true,
        subscribe => Package[$::koji::params::helpers_package],
    }

}
