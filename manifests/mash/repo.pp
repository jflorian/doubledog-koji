# modules/koji/manifests/mash/repo.pp
#
# == Define: koji::mash::repo
#
# Manages a repository configuration file for Koji's mash client.
#
# === Parameters
#
# ==== Required
#
# [*namevar*]
#   An arbitrary identifier for the mash repository instance unless the
#   "repo_name" parameter is not set in which case this must provide the value
#   normally set with the "repo_name" parameter.
#
# [*dist_tag*]
#   Pull RPMs from what tag?
#
# ==== Optional
#
# [*ensure*]
#   Instance is to be 'present' (default) or 'absent'.
#
# [*arches*]
#   A list of the platform architectures to be included in the repository.
#   Defaults to ['i386', 'x86_64'].
#
# [*comp_dir*]
#   Name of the directory into which this repository is to be composited by
#   mash-everything.  Defaults to the value set by "repo_name".
#
# [*debug_info*]
#   If true, the debug-info files will be copied into the mashed repository;
#   otherwise they will be skipped.
#
# [*debug_info_path*]
#   Directory name where the debug RPMs are to land.  The default is a dynamic
#   value that matches the package architecture and is relative to the
#   directory named "repo_name" which itself is relative to the "repo_dir"
#   specified for Class[koji::mash].
#
# [*delta*]
#   Should delta-RPMs be produced for the repository?  Defaults to false.
#
# [*distro_tags*]
#   Undocumented.  Defaults to "cpe:/o:fedoraproject:fedora:$repo_name Null".
#
# [*hash_packages*]
#   If true, each RPM will be placed within a subdirectory whose name matches
#   the first character of the RPM.  Otherwise such subdirectories will not be
#   used.  Defaults to true.
#
# [*inherit*]
#   Undocumented.  Defaults to false.
#
# [*keys*]
#   A list of GPG key IDs that were used to sign packages.  Defaults to [].
#   E.g., [ '4F2A6FD2', '30C9ECF8' ]
#
# [*max_delta_rpm_age*]
#   Skip the delta-RPM for any package where the base package is more than
#   this many seconds old.   Defaults to 604,800 (== 7 days).
#
# [*max_delta_rpm_size*]
#   Skip the delta-RPM for any package where the size would exceed this value.
#   Defaults to 800,000,000.
#
# [*multilib*]
#   If true, binary RPMs for various target hardware platforms will be
#   combined; otherwise they will be kept separate.
#
# [*multilib_method*]
#   Undocumented.  Defaults to "devel".
#
# [*repo_name*]
#   This may be used in place of "namevar" if it's beneficial to give namevar
#   an arbitrary value.
#
# [*repodata_path*]
#   Directory name where the repodata files are to land.  The default is
#   a dynamic value that matches the package architecture and is relative to
#   the directory named "repo_name" which itself is relative to the "repo_dir"
#   specified for Class[koji::mash].
#
# [*repoview_title*]
#   Title to be used atop the repoview pages.
#
# [*repoview_url*]
#   Repository URL to use when generating the RSS feed.  The default disables
#   RSS feed generation.
#
# [*rpm_path*]
#   Directory name where the binary RPMs are to land.  The default is
#   a dynamic value that matches the package architecture and is relative to
#   the directory named "repo_name" which itself is relative to the "repo_dir"
#   specified for Class[koji::mash].
#
# [*source_path*]
#   Directory name where the source RPMs are to land.  The default is
#   "SRPMS" and is relative to the directory named "repo_name" which itself is
#   relative to the "repo_dir" specified for Class[koji::mash].
#
# [*strict_keys*]
#   If true, the mash job will fail if any of the builds has not be signed
#   with one of the "keys".  Defaults to false.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


define koji::mash::repo (
        $dist_tag,
        $ensure='present',
        $arches=['i386', 'x86_64'],
        $comp_dir=undef,
        $debug_info=true,
        $debug_info_path='%(arch)s/debug',
        $delta=false,
        $distro_tags=undef,
        $hash_packages=true,
        $inherit=false,
        $keys=[],
        $max_delta_rpm_age=604800,
        $max_delta_rpm_size=800000000,
        $multilib=false,
        $multilib_method='devel',
        $repo_name=$title,
        $repodata_path='%(arch)s',
        $repoview_title="Packages from ${dist_tag} for %(arch)s",
        $repoview_url=undef,
        $rpm_path='%(arch)s',
        $source_path='SRPMS',
        $strict_keys=false,
    ) {

    include '::koji::params'

    if $comp_dir {
        $comp_dir_ = $comp_dir
    } else {
        $comp_dir_ = $repo_name
    }

    if $distro_tags {
        $distro_tags_ = $distro_tags
    } else {
        $distro_tags_ = "cpe:/o:fedoraproject:fedora:${repo_name} Null"
    }

    file { "${::koji::params::mash_conf_dir}/${repo_name}.mash":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        seluser => 'system_u',
        selrole => 'object_r',
        seltype => 'etc_t',
        require => Class['koji::mash'],
        content => template('koji/mash/template.mash'),
    }

    concat::fragment { "include mash of ${repo_name}":
        target  => $::koji::params::mash_everything_conf,
        content => "${repo_name}:${comp_dir_}\n",
        order   => '02',
    }

}
