# == Class: koji::httpd
#
# Manages Apache httpd for the needs of the Koji Hub/Web components.
#
# This manages those parts of httpd that are common to both the Koji Hub and
# the Koji Web components, which may be on the same or different hosts.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016-2018 John Florian


class koji::httpd (
    ) {

    class { '::apache':
        anon_write         => true,
        network_connect_db => true,
        use_nfs            => true,
    }

    include '::apache::mod_ssl'

    ::apache::site_config {
        'ssl':
            content   => template("koji/hub/ssl.conf.${::operatingsystem}.${::operatingsystemmajrelease}.erb"),
            subscribe => Class['::apache::mod_ssl'],
            ;
    }

}
