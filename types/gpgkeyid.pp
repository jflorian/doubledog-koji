#
# == Type: Koji::GpgKeyId
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


type Koji::GpgKeyId = Pattern[/[0-9A-F]{8}/]
