# modules/koji/manifests/helpers.pp
#
# == Class: koji::helpers
#
# Manages various resources that are used and shared by several components of
# this Puppet module for Koji.  This class and it's resources are not intended
# to be used directly and should be considered an internal part of this
# module.
#
# === Parameters
#
# ==== Required
#
# ==== Optional
#
# === See Also
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


class koji::helpers inherits ::koji::params {

    File {
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        seluser => 'system_u',
        selrole => 'object_r',
        seltype => 'bin_t',
    }

    file {
        $::koji::params::helpers_bin:
            mode    => '0755',
            content => template('koji/helpers/_shared'),
            ;
    }

}
