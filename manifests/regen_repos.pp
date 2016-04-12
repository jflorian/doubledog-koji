# modules/koji/manifests/regen_repos.pp
#
# == Class: koji::regen_repos
#
# Manages the regeneration of Koji's repository meta-data that's needed for
# proper buildroot population.  Such regeneration is necessary whenever the
# external repositories change, such as may happen with mirror
# synchronization.
#
# === Parameters
#
# ==== Required
#
# [*ext_repo_root*]
#   Name of the directory under which all external repositories reside.
#   Ideally, this is the longest path possible without getting specific about
#   any particular distribution release.
#
# [*owner*]
#   User name or number that is to own the persistent state files.  You must
#   manually do the following for this user:
#
#       1. Create the Koji user account.
#       2. Grant them the "repo" permission within Koji.
#       3. Provide them with a Koji configuration and authentication
#       credentials.
#
# ==== Optional
#
# [*group*]
#   Group name or number to which the persistent state files are members.
#
# === See Also
#
#   Define[koji::buildroot_dependency]
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


class koji::regen_repos (
        $ext_repo_root,
        $owner,
        $group='root',
    ) inherits ::koji::params {

    File {
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        seluser => 'system_u',
        selrole => 'object_r',
        seltype => 'etc_t',
    }

    file {
        $::koji::params::regen_repos_states:
            ensure => directory,
            owner  => $owner,
            group  => $group,
            mode   => '0755',
            ;

        $::koji::params::regen_repos_bin:
            mode    => '0755',
            content => template('koji/regen-repos/regen-repos'),
            ;
    }

    concat { $::koji::params::regen_repos_conf:
        ensure => 'present',
    }

    concat::fragment { 'header':
        target  => $::koji::params::regen_repos_conf,
        content => template('koji/regen-repos/regen-repos.conf'),
        order   => '01',
    }

}
