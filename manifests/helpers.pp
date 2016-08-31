# modules/koji/manifests/helpers.pp
#
# == Class: koji::helpers
#
# Manages the koji-helpers package.
#
# === Parameters
#
# ==== Required
#
# ==== Optional
#
# [*ensure*]
#   Instance is to be 'installed' (default) or 'absent'.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


class koji::helpers (
        $ensure='installed',
    ) inherits ::koji::params {

    package { $::koji::params::helpers_package:
        ensure => $ensure,
    }

}
