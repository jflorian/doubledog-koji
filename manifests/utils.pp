# == Class: koji::utils
#
# Manages the Koji utilities package.
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
