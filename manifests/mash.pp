# modules/koji/manifests/mash.pp
#
# == Class: koji::mash
#
# Manages the Koji mash client on a host.
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
    ) inherits ::koji::params {

    include '::koji::helpers'

    package { $::koji::params::mash_packages:
        ensure  => installed,
    }

    File {
        owner     => 'root',
        group     => 'root',
        mode      => '0644',
        seluser   => 'system_u',
        selrole   => 'object_r',
        seltype   => 'etc_t',
        subscribe => Package[$::koji::params::mash_packages],
    }

    file {
        $::koji::params::mash_conf_dir:
            ensure => directory,
            mode   => '0755',
            ;

        $::koji::params::mash_work_dir:
            ensure  => directory,
            owner   => $repo_owner,
            group   => $repo_owner,
            mode    => '0755',
            seltype => 'var_t',
            ;

        "${::koji::params::mash_conf_dir}/mash.conf":
            content => template('koji/mash/mash.conf'),
            ;

        $::koji::params::mash_everything_bin:
            mode    => '0755',
            seltype => 'bin_t',
            content => template('koji/mash/mash-everything'),
            ;
    }

    concat { $::koji::params::mash_everything_conf:
        ensure => 'present',
    }

    concat::fragment { 'mash-everything-header':
        target  => $::koji::params::mash_everything_conf,
        content => template('koji/mash/mash-everything.conf'),
        order   => '01',
    }

}
