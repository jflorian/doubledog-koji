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

            $cli_packages = 'koji'
            $hub_packages = [
                'koji-hub',
                'koji-hub-plugins',
                # Work-around for
                # https://bugzilla.redhat.com/show_bug.cgi?id=1301765
                'python-simplejson',
            ]
            $kojira_packages = 'koji-utils'
            $web_packages = 'koji-web'

            $kojira_services = 'kojira'

        }

        default: {
            fail ("${title}: operating system '${::operatingsystem}' is not supported")
        }

    }

}
