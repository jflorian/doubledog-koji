# modules/koji/manifests/buildroot_dependency.pp
#
# == Define: koji::buildroot_dependency
#
# Manages a buildroot's dependencies on external package repositories.
#
# If a Koji buildroot has dependencies on external package repositories,
# builds within that buildroot will fail if those external package
# repositories mutate unless Koji's internal repository meta-data is
# regenerated.  This definition allows you to declare such dependencies so
# that such regeneration will be performed automatically, as needed.
#
# === Parameters
#
# ==== Required
#
# [*namevar*]
#   An arbitrary identifier for the buildroot dependency instance unless the
#   "buildroot_name" parameter is not set in which case this must provide the
#   value normally set with the "buildroot_name" parameter.
#
# [*ext_repo_dirs*]
#   A list of directory names, relative to koji::regen_repos::ext_repo_root,
#   each of which contain package repositories upon which this buildroot is
#   dependent.  These entries need not match your package manager's
#   configuration for repositories on a one-to-one basis.  If anything changes
#   in one of these directories or any of their descendents, the regeneration
#   will be triggered.
#
#   For a hint of what belongs here, consult the output of:
#
#       koji list-external-repos
#
# ==== Optional
#
# [*ensure*]
#   Instance is to be 'present' (default) or 'absent'.
#
# [*buildroot_name*]
#   This may be used in place of "namevar" if it's beneficial to give namevar
#   an arbitrary value.  If set, this must provide the Koji tag representing
#   the buildroot having external dependencies.
#
# === See Also
#
#   Class[koji::regen_repos]
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


define koji::buildroot_dependency (
        $ext_repo_dirs,
        $ensure='present',
        $buildroot_name=$title,
    ) {

    include '::koji::params'

    $dirs = join($ext_repo_dirs, ':')

    concat::fragment { "include regeneration for ${buildroot_name}":
        target  => $::koji::params::regen_repos_conf,
        content => "${buildroot_name}:${dirs}\n",
        order   => '02',
    }

}
