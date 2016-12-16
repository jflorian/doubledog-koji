# modules/koji/manifests/gc/policy.pp
#
# == Define: koji::gc::policy
#
# Manages a policy rule for the Koji garbage collector.
#
# The pruning policy is a series of rules.  During pruning, the garbage
# collector goes through each tag in the system and considers its contents.
# For each build within the tag, it goes through the pruning policy rules
# until it finds one that matches.  It it does, it takes that action for it. 
#
# For some additional details see:
#   http://fedoraproject.org/wiki/Koji/GarbageCollection
#
# === Parameters
#
# ==== Required
#
# [*namevar*]
#   An arbitrary identifier for the policy rule instance.
#
# [*rule*]
#   Literal string describing one policy rule.  The general format is:
#       'test <args> [ && test <args> ...] :: action'
#
#   The available tests are:
#       tag <pattern> [<pattern> ...]
#           The name of the tag must match one of the patterns.
#
#       package <pattern> [<pattern> ...]
#           The name of the package must match one of the patterns.
#
#       age <operator> <value>
#           A comparison against the length of time since the build was
#           tagged.  This is not the same as the age of the build.  Valid
#           operators are <, <=, ==, =>, >.  Value is something like "1 day"
#           or "4 weeks".
#
#       sig <key>
#           The build's component rpms are signed with a matching key.
#
#       order <operator> <value>
#           Like the "age" test, but the comparison is against the order
#           number of the build within a given tag.  The order number is the
#           number of more recently tagged builds for the same package within
#           the tag.  For example, the latest build of FOO in tag BAR has
#           order number 0, the next latest has order number 1, and so on.
#           Note that the 'skip' action modifies this -- the build is kept,
#           but is not counted for ordering.
#
#   Note that the tests are not being applied to just a build, but to a build
#   within a tag.  If a build is multiply tagged, it will be checked against
#   these policies for each tag and may be kept in some but untagged in
#   others.
#
#   The available actions are:
#       keep
#           Do not untag the build from this tag.
#
#       untag
#           Untag the build from this tag.
#       skip
#           Like keep, but do not count the build for ordering.
#
# [*seq*]
#   Determines the evaluation sequence of this rule amongst all of the policy
#   rules.  This should be a 3-digit numerical string with lower values taking
#   precedence.  Value '000' is reserved for use by this module.
#
# ==== Optional
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


define koji::gc::policy (
        String[1] $rule,
        Pattern[/[1-9][0-9]{2}/, /[0-9][1-9][0-9]/, /[0-9]{2}[1-9]/] $seq,
    ) {

    include '::koji::params'

    ::concat::fragment { "koji-gc.conf-${title}":
        target  => 'koji-gc.conf',
        order   => $seq,
        content => "    ${rule}\n",
    }
}
