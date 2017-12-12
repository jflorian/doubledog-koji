# koji

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with koji](#setup)
    * [What koji affects](#what-koji-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with koji](#beginning-with-koji)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
    * [Defined types](#defined-types)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

The typical Koji build system deployment consists of one or more Builders, a Web portal, a CLI, and a Hub that coordinates activities.  There's also some "behind the scenes" components such a Garbage Collector, database and that service know as Kojira.  This Puppet module aims to make deployment of all these components relatively easy, while allowing considerable flexibility for advanced setups.

## Setup

Sorry, this section needs some love.  You'll have to settle for the [reference](#reference) docs for now.

### What koji affects **OPTIONAL**

If it's obvious what your module touches, you can skip this section. For
example, folks can probably figure out that your mysql_instance module affects
their MySQL instances.

If there's more that they should know about, though, this is the place to mention:

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute.
* Dependencies that your module automatically installs.
* Warnings or other important notices.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
etc.), mention it here.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you might want to include an additional "Upgrading" section
here.

### Beginning with koji

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most
basic use of the module.

## Usage

This section is where you describe how to customize, configure, and do the
fancy stuff with your module here. It's especially helpful if you include usage
examples and code samples for doing things with your module.

## Reference

**Classes:**

* [koji::builder](#kojibuilder-class)
* [koji::cli](#kojicli-class)
* [koji::database](#kojidatabase-class)
* [koji::gc](#kojigc-class)

**Defined types:**

* [koji::cli::profile](#kojicliprofile-defined-type)
* [koji::gc::policy](#kojigcpolicy-defined-type)


### Classes

#### koji::builder class

This class manages a host as a Koji Builder.

##### `allowed_scms`
An array of tuples from which kojid is allowed to checkout.  The format of
each tuple is:

    host:repository[:use_common[:source_cmd]]

Incorrectly-formatted tuples will be ignored.

If `use_common` is not present, kojid will attempt to checkout a common/
directory from the repository.  If `use_common` is set to `no`, `off`, `false`,
or `0`, it will not attempt to checkout a `common/` directory.

`source_cmd` is a shell command (args separated with commas instead of spaces)
to run before building the srpm.  It is generally used to retrieve source files
from a remote location.  If no `source_cmd` is specified, `make sources` is run
by default.

##### `downloads`
URL of your package download site.

##### `hub`
URL of your Koji Hub service.

##### `hub_ca_cert`
Puppet source URI providing the CA certificate which signed the Koji Hub
certificate.  This must be in PEM format and include all intermediate CA
certificates, sorted and concatenated from the leaf CA to the root CA.

##### `kojid_cert`
Puppet source URI providing the builder's identity certificate which must
be in PEM format.

##### `top_dir`
Name of the directory containing the `repos/` directory.

##### `build_arch_can_fail`
Don't cancel sub-task when other fails.  In some cases it makes sense to
continue with sibling task even if some of them already failed.  E.g., with
a kernel build it could be of use if submitter knows for which archs it succeed
and for which it fails.  Repeated builds could take a lot of time and
resources.  Note, that this shouldn't be enabled ordinarily as it could result
in unnecessary resource consumption.  The default is `false`.

##### `debug`
Enable verbose debugging for the Koji Builder.  One of: `true` or `false`
(default).

##### `enable`
Instance is to be started at boot.  Either `true` (default) or `false`.

##### `ensure`
Instance is to be `running` (default) or `stopped`.  Alternatively, a Boolean
value may also be used with `true` equivalent to `running` and `false`
equivalent to `stopped`.

##### `failed_buildroot_lifetime`
The number of seconds a buildroot should be retained by kojid after a build
failure occurs.  It is sometimes necessary to manually chroot into the
buildroot to determine exactly why a build failed and what might done to
resolve the issue.  The default is 4 hours (or 14,400 seconds).

It must be noted here that this feature is somewhat flaky because Koji seems to
set the expiration time based not on when the build started but on some other
event, likely when the buildroot was created.  This might not sound all that
different but bear in mind that kojid doesn't fully destroy the build roots; it
merely empties them.  So in effect, kojid can reuse a buildroot -- one which
may already be hours towards its expiration.  If you wish to use this feature,
you may want to use a value of a day or more, but keep in mind you might then
exhaust the storage capacity of the `mock_dir`.

##### `image_building`
If `true`, additional packages will be installed to permit this host to perform
image building tasks.  The default is `false`.

##### `imaging_packages`
An array of extra package names needed for the Koji Builder installation when
`image_building` is `true`.

##### `min_space`
The minimum amount of free space (in MiB) required for each build root.

##### `mock_dir`
The directory under which mock will do its work and create buildroots.
The default is `/var/lib/mock`.

##### `mock_user`
The user to run as when doing builds.  The default is `kojibuilder`.

##### `packages`
An array of package names needed for the Koji Builder installation.

##### `service`
The service name of the Koji Builder daemon.

##### `smtp_host`
The mail host to use for sending email notifications.  The Koji Builder must be
able to connect to this host via TCP on port 25.  The default is `localhost`.

##### `use_createrepo_c`
Enable using createrepo_c instead of createrepo.  The default is `false`.

##### `work_dir`
Name of the directory where temporary work will be performed.  The default
is `/tmp/koji`.


#### koji::cli class

This class manages the Koji CLI on a host.

##### `packages`
An array of package names needed for the Koji CLI installation.

##### `profiles`
A hash whose keys are profile names and whose values are hashes comprising the
same parameters you would otherwise pass to [koji::cli::profile](#kojicliprofile-defined-type).


#### koji::database class

This class manages the Koji database on a host.

This class presently assumes a PostgreSQL database.

Specifically, this class will:

  1. install/configure the PostgreSQL server, including authentication
  1. create the database and PostgreSQL user role
  1. import the Koji database schema
  1. bootstrap the database with an initial Koji administrator account

**Upgrading**

This class is primarily useful for establishing new Koji setups.  If you
already have a Koji setup and you are building a newer one to replace it,
a suggested procedure is as follows:

  1. successfully apply this to the new Koji host ($NEW)
  1. stop the Puppet agent on $NEW
  1. stop the PostgreSQL server on $NEW
  1. reinitialize the database cluster
  1. perform a full dump on the old Koji host $(OLD)
  1. transfer the dumped content to $NEW
  1. load the dumped content on $NEW
  1. review migration documents on $NEW; see `rpm -qd koji`

##### `password`
Password for the database user.

##### `admin`
Name of the of the Koji administrator.  Defaults to `kojiadmin`.

##### `dbname`
Name of the database.  Defaults to `koji`.

##### `listen_addresses`
From where may the PostgreSQL server accept connections?  Defaults to
`localhost` which means it will only accept connections originating from the
local host.  A value of `*` makes the PostgreSQL server accept connections from
any remote host.  You may instead choose to specify a comma-separated list of
host names and/or IP addresses.

NB: This parameter affects the entire PostgreSQL server, not just the Koji
database.  If the database cluster has other duties, additional work must be
done here to permit that.

##### `schema_source`
Source URI for the Koji database schema.  The default is
`/usr/share/doc/koji/docs/schema.sql`.

##### `username`
Name of the user who is to own the database.  Defaults to `koji`.

##### `web_username`
Name of the user that runs the Koji-Web server.  Defaults to `apache`.


#### koji::gc class

This class manages the Koji garbage collector on a host.

##### `client_cert`
Puppet source URI providing the Koji garbage collector's certificate.  This
must be in PEM format.

##### `hub`
URL of your Koji-Hub server.

##### `hub_ca_cert`
Puppet source URI providing the CA certificate which signed Koji-Hub.  This
must be in PEM format and include all intermediate CA certificates, sorted and
concatenated from the leaf CA to the root CA.

##### `keys`
GPG key IDs that were used to sign packages, as a hash.  E.g.:

    { 'fedora-gold' => '4F2A6FD2', 'fedora-test' => '30C9ECF8' }

##### `owner`
Name of the OS user account under which the garbage collection process
will run.

##### `top_dir`
Directory containing the `repos/` directory.

##### `web`
URL of your Koji-Web server.

##### `email_domain`
The domain name that will be appended to Koji user names when creating
email notifications.  Defaults to the `$domain` fact.

##### `grace_period`
Determines the length of time that builds are held in the trash can before
their ultimate demise.  The default is `4 weeks`.

##### `group`
Name of the OS group account under which the garbage collection process will
run.  The default is to be the same as `owner`.

##### `oldest_scratch`
Any scratch builds that were last modified more than this number of days
ago are eligible for purging.  Set to a negative number to prohibit
purging any scratch builds.  The default is 90 days.

##### `smtp_host`
The mail host to use for sending email notifications.  The Koji garbage
collector must be able to connect to this host via TCP on port 25.  The
default is `localhost`.

##### `unprotected_keys`
An array of names in `keys` which are to be considered unprotected by the
garbage collector.  Any key not listed here is considered a protected key.


### Defined types

#### koji::cli::profile defined type

This defined type manages a Koji CLI configuration profile.

Profiles can be utilized by the Koji CLI using:

    koji -p|--profile PROFILE

Without the `-p`/`--profile` option, the Koji CLI will use a default profile
named `koji`.

##### `namevar`
An identifier for the configuration profile instance.  Specify `koji` to
configure the default profile.

##### `downloads`
URL of your package download site.

##### `hub`
URL of your Koji-Hub server.

##### `top_dir`
Directory containing the `repos/` directory.

##### `web`
URL of your Koji-Web server.

##### `auth_type`
The method the client should use to authenticate itself to the Koji-Hub.  Must
be one of: `noauth`, `ssl`, `password`, or `kerberos`.  The default is `ssl`.

##### `max_retries`
When making Koji calls, if the Koji Hub reports a temporary failure, how many
times should the call be retried?  The default is `30`.

##### `offline_retry`
When making Koji calls, if the Koji Hub reports itself as offline, should the
call be retried automatically?  The default is `false`.

Note that offline failures are treated specially from other temporary failures.
These are not constrained by other failure handling options, most notably
`max_retries`.

##### `offline_retry_interval`
When making Koji calls, if the Koji Hub reports itself as offline and
`offline_retry` is `true`, this determines how many seconds the Koji Client will
wait before attempting the call again.  The default is 20 seconds.

##### `retry_interval`
When making Koji calls, if the Koji Hub reports a temporary failure, this
determines how many seconds the Koji Client will wait before attempting the
call again.  The default is 20 seconds.


#### koji::gc::policy defined type

This defined type manages a policy rule for the Koji garbage collector.

The pruning policy is a series of rules.  During pruning, the garbage collector
goes through each tag in the system and considers its contents.  For each build
within the tag, it goes through the pruning policy rules until it finds one
that matches.  It it does, it takes that action for it.

##### `namevar`
An arbitrary identifier for the policy rule instance.

##### `rule`
Literal string describing one policy rule.  The general format is:

    test <args> [ && test <args> ...] :: action

The available tests are:

* `tag <pattern> [<pattern> ...]`
    * The name of the tag must match one of the patterns.
* `package <pattern> [<pattern> ...]`
    * The name of the package must match one of the patterns.
* `age <operator> <value>`
    * A comparison against the length of time since the build was tagged.  This
      is not the same as the age of the build.
    * Valid operators are `<`, `<=`, `==`, `=>`, `>`.
    * Value is something like `1 day` or `4 weeks`.
* `sig <key>`
    * The build's component rpms are signed with a matching key.
* `order <operator> <value>`
    * Like the `age` test, but the comparison is against the order number of
      the build within a given tag.  The order number is the number of more
      recently tagged builds for the same package within the tag.  For example,
      the latest build of FOO in tag BAR has order number 0, the next latest
      has order number 1, and so on.
    * The `skip` action modifies this -- the build is kept, but is not counted
      for ordering.

Note that the tests are not being applied to just a build, but to a build
within a tag.  If a build is multiply tagged, it will be checked against these
policies for each tag and may be kept in some but untagged in others.

The available actions are:

* `keep`
    * Do not untag the build from this tag.
* `untag`
    * Untag the build from this tag.
* `skip`
    * Like keep, but do not count the build for ordering.

##### `seq`
Determines the evaluation sequence of this rule amongst all of the policy
rules.  This should be a 3-digit numerical string with lower values taking
precedence.  Value `000` is reserved for use by this module.


## Limitations

This is where you list OS compatibility, version compatibility, etc. If there
are Known Issues, you might want to include them under their own heading here.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel
are necessary or important to include here. Please use the `## ` header.
