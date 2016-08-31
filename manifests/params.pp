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
            $helpers_package = 'koji-helpers'
            $hub_packages = [
                'koji-hub',
                'koji-hub-plugins',
                # Work-around for
                # https://bugzilla.redhat.com/show_bug.cgi?id=1301765
                'python-simplejson',
            ]
            $utils_packages = 'koji-utils'
            $web_packages = 'koji-web'

            $builder_services = 'kojid'
            $kojira_services = 'kojira'
            $mash_conf_dir = '/etc/mash'
            $mash_work_dir = '/var/cache/mash'
            $mash_everything_conf = '/etc/koji-helpers/mashes.conf'
            $mash_everything_service = 'mash-everything'
            $regen_repos_conf = '/etc/koji-helpers/repos.conf'
            $regen_repos_service = 'regen-repos'

        }

        default: {
            fail ("${title}: operating system '${::operatingsystem}' is not supported")
        }

    }

}
