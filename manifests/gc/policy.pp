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
# Copyright 2016-2018 John Florian
# SPDX-License-Identifier: GPL-3.0-or-later


define koji::gc::policy (
        String[1]   $rule,
        Pattern[/[1-9][0-9]{2}/, /[0-9][1-9][0-9]/, /[0-9]{2}[1-9]/] $seq,
    ) {

    ::concat::fragment { "koji-gc.conf-${title}":
        target  => 'koji-gc.conf',
        order   => $seq,
        content => "    ${rule}\n",
    }
}
