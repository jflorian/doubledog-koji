# modules/koji/manifests/packages/utils.pp
#
# == Class: koji::packages::utils
#
# Manages the Koji utilities package.
#
# === Parameters
#
# ==== Required
#
# ==== Optional
#
# [*ensure*]
#   Identical to the ensure parameter of the standard File resource type.
#   The default is 'present'.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


class koji::packages::utils (
        $ensure='present',
    ) inherits ::koji::params {

    package { $::koji::params::utils_packages:
        ensure => $ensure,
    }

}
