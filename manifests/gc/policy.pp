#
# == Define: koji::gc::policy
#
# Manages a policy rule for the Koji garbage collector.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# This file is part of the doubledog-koji Puppet module.
# Copyright 2016-2020 John Florian
# SPDX-License-Identifier: GPL-3.0-or-later


define koji::gc::policy (
        String[1]       $rule,
        Koji::Gc::Seq   $seq,
    ) {

    concat::fragment { "koji-gc.conf-${title}":
        target  => 'koji-gc.conf',
        # adding zero causes String conversion to Integer
        order   => sprintf('%03d', $seq + 0),
        content => "    ${rule}\n",
    }

}
