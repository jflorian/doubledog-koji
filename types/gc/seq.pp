#
# == Type: Koji::Gc::Seq
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# This file is part of the doubledog-koji Puppet module.
# Copyright 2019 John Florian
# SPDX-License-Identifier: GPL-3.0-or-later


type Koji::Gc::Seq = Variant[
    Integer[1, 999],
    Pattern[
        # effectively 001-999
        /[1-9][0-9]{2}/,        # 100-999
        /[0-9][1-9][0-9]/,      # 010-999
        /[0-9]{2}[1-9]/         # 001-999
    ],
]
