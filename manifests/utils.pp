# modules/koji/manifests/utils.pp
#
# == Class: koji::utils
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
# [*packages*]
#   An array of package names needed for the Koji utilities installation.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016-2017 John Florian


class koji::utils (
        Variant[Boolean, Enum['present', 'absent']] $ensure,
        Array[String[1], 1]     $packages,
    ) {

    package { $packages:
        ensure => installed,
    }

}
