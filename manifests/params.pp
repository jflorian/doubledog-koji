# modules/koji/manifests/params.pp
#
# == Class: koji::params
#
# Parameters for the koji puppet module.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


class koji::params {

    $admin_user = 'kojiadmin'

    case $::operatingsystem {
        'CentOS', 'Fedora': {

            $builder_packages = [
                'createrepo',
                'koji-builder',
            ]
            $cli_packages = 'koji'
            $hub_packages = [
                'koji-hub',
                'koji-hub-plugins',
                # Work-around for
                # https://bugzilla.redhat.com/show_bug.cgi?id=1301765
                'python-simplejson',
            ]
            $utils_packages = 'koji-utils'
            $mash_packages = [
                'mash',
                'repoview',
            ]
            $web_packages = 'koji-web'

            $builder_services = 'kojid'
            $helpers_bin = '/usr/local/libexec/_shared_koji_helpers'
            $kojira_services = 'kojira'
            $mash_conf_dir = '/etc/mash'
            $mash_work_dir = '/var/cache/mash'
            $mash_everything_bin = '/usr/local/bin/mash-everything'
            $mash_everything_conf = '/etc/mash/mash-everything.conf'
            $regen_repos_bin = '/usr/local/bin/regen-repos'
            $regen_repos_conf = '/etc/regen-repos.conf'
            $regen_repos_states = '/var/lib/regen-repos'

        }

        default: {
            fail ("${title}: operating system '${::operatingsystem}' is not supported")
        }

    }

}
