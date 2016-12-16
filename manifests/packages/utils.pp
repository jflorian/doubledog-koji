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
#   Instance is to be 'present' (default) or 'absent'.  Alternatively,
#   a Boolean value may also be used with true equivalent to 'present' and
#   false equivalent to 'absent'.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


class koji::packages::utils (
        Variant[Boolean, Enum['present', 'absent']] $ensure='present',
    ) inherits ::koji::params {

    package { $::koji::params::utils_packages:
        ensure => $ensure,
    }

}
