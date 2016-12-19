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

            $builder_packages = 'koji-builder'
            $builder_imaging_packages = $::operatingsystem ? {
                'CentOS' => [
                    'lorax',
                    'pycdio',
                    'pykickstart',
                ],
                'Fedora' => [
                    'lorax',
                    'pycdio',
                    'python-kickstart',
                ],
            }
            $cli_packages = 'koji'
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

        }

        default: {
            fail ("${title}: operating system '${::operatingsystem}' is not supported")
        }

    }

}
