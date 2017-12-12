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
# Copyright 2016-2017 John Florian


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
