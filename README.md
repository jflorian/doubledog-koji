<!--
This file is part of the doubledog-koji Puppet module.
Copyright 2017-2019 John Florian <jflorian@doubledog.org>
SPDX-License-Identifier: GPL-3.0-or-later
-->

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
    * [Data types](#data-types)
    * [Facts](#facts)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

The typical Koji build system deployment consists of one or more Builders, a Web portal, a CLI, and a Hub that coordinates activities.  There's also some "behind the scenes" components such a Garbage Collector, database and that service know as Kojira.  This Puppet module aims to make deployment of all these components relatively easy, while allowing considerable flexibility for advanced setups.

## Setup

### What koji Affects

### Setup Requirements

This module integrates and thus depends on several other Puppet modules to
achieve a reliable solution.  At present these are:

* [doubledog-apache](https://github.com/jflorian/doubledog-apache)
* [doubledog-cron](https://github.com/jflorian/doubledog-cron)
* [puppetlabs-concat](https://github.com/puppetlabs/puppetlabs-concat)
* [puppetlabs-postgresql](https://github.com/puppetlabs/puppetlabs-postgresql)

The following is optional (despite being listed as a requirement in the
`metadata.json` file), unless you wish to use any of the integrated `*::x509`
classes.  If you don't use those, you will either need to manage the X.509
certificates separately (or help with the Kerberos support, below).

* [doubledog-openssl](https://github.com/jflorian/doubledog-openssl)

In the future, I intend to do more such disintegration and implement Kerberos
support but, alas I only have so much time.  (Hint: PRs welcome!)

### Beginning with koji

## Usage

## Reference

**Classes:**

* [koji::builder](#kojibuilder-class)
* [koji::builder::x509](#kojibuilderx509-class)
* [koji::cli](#kojicli-class)
* [koji::database](#kojidatabase-class)
* [koji::gc](#kojigc-class)
* [koji::httpd](#kojihttpd-class)
* [koji::hub](#kojihub-class)
* [koji::hub::x509](#kojihubx509-class)
* [koji::kojira](#kojikojira-class)
* [koji::kojira::x509](#kojikojirax509-class)
* [koji::utils](#kojiutils-class)
* [koji::web](#kojiweb-class)
* [koji::web::x509](#kojiwebx509-class)

**Defined types:**

* [koji::cli::profile](#kojicliprofile-defined-type)
* [koji::gc::policy](#kojigcpolicy-defined-type)

**Data types:**

**Facts:**


### Classes

#### koji::builder class

This class manages a host as a Koji Builder.

##### `allowed_scms`
An array of tuples from which kojid is allowed to checkout.  The format of
each tuple is:

    host:repository[:use_common[:source_cmd]]

Incorrectly-formatted tuples will be ignored.

If *use_common* is not present, kojid will attempt to checkout a `'common/'`
directory from the repository.  If *use_common* is set to `no`, `'off'`,
`false`, or `0`, it will not attempt to checkout a `'common/'` directory.

*source_cmd* is a shell command (args separated with commas instead of spaces)
to run before building the srpm.  It is generally used to retrieve source files
from a remote location.  If no *source_cmd* is specified, `'make sources'` is
run by default.

##### `downloads`
URL of your package download site.

##### `hub`
URL of your Koji Hub service.

##### `top_dir`
Name of the directory containing the `'repos/'` directory.

##### `build_arch_can_fail`
Don't cancel sub-task when other fails.  In some cases it makes sense to
continue with sibling task even if some of them already failed.  E.g., with
a kernel build it could be of use if the submitter knows for which
architectures it succeeds and for which it fails.  Repeated builds could take
a lot of time and resources.  Note, that this shouldn't be enabled ordinarily
as it could result in unnecessary resource consumption.  The default is
`false`.

##### `chroot_tmpdir`
Name of the directory within buildroots that is used for various temporary data
by the Koji builder daemon.  Prior to Koji 1.16, this was hard-coded to
`/builddir/tmp`, which created problems with modern versions of mock.  The
default is `/chroot_tmpdir`.

##### `debug`
Enable verbose debugging for the Koji Builder.  One of: `true` or `false`
(default).

##### `enable`
Instance is to be started at boot.  Either `true` (default) or `false`.

##### `ensure`
Instance is to be `'running'` (default) or `'stopped'`.  Alternatively,
a Boolean value may also be used with `true` equivalent to `'running'` and
`false` equivalent to `'stopped'`.

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
exhaust the storage capacity of the *mock_dir*.

##### `image_building`
If `true`, additional packages will be installed to permit this host to perform
image building tasks.  The default is `false`.

##### `imaging_packages`
An array of extra package names needed for the Koji Builder installation when
*image_building* is `true`.

##### `min_space`
The minimum amount of free space (in MiB) required for each build root.

##### `mock_dir`
The directory under which mock will do its work and create buildroots.
The default is `'/var/lib/mock'`.

##### `mock_user`
The user to run as when doing builds.  The default is `'kojibuilder'`.

##### `oz_install_timeout`
The install timeout for imagefactory.  The default is `0`, which disables the timeout.

##### `packages`
An array of package names needed for the Koji Builder installation.

##### `service`
The service name of the Koji Builder daemon.

##### `sleep_time`
The number of seconds to sleep between tasks.  The default is `15` seconds.

##### `smtp_host`
The mail host to use for sending email notifications.  The Koji Builder must be
able to connect to this host via TCP on port 25.  The default is `'localhost'`.

##### `use_createrepo_c`
Enable using createrepo\_c instead of createrepo.  The default is `false`.

##### `work_dir`
Name of the directory where temporary work will be performed.  The default
is `'/tmp/koji'`.


#### koji::builder::x509 class

This class manages the X.509 certificates on a host acting as a Koji Builder.
It's use is optional and should only be included if you wish to use the
integrated X.509 support offered by the
[doubledog-openssl](https://github.com/jflorian/doubledog-openssl) module.

#####  `hub_ca_cert_content`, `hub_ca_cert_source`
Literal string or Puppet source URI providing the CA certificate which signed
the Koji Hub certificate.  This must be in PEM format and include all
intermediate CA certificates, sorted and concatenated from the leaf CA to the
root CA.

#####  `kojid_cert_content`, `kojid_cert_source`
Literal string or Puppet source URI providing the builder's identity
certificate which must be in PEM format and contain both the public- and
private-keys.


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
Name of the of the Koji administrator.  Defaults to `'kojiadmin'`.

##### `dbname`
Name of the database.  Defaults to `'koji'`.

##### `listen_addresses`
From where may the PostgreSQL server accept connections?  Defaults to
`'localhost'` which means it will only accept connections originating from the
local host.  A value of `'*'` makes the PostgreSQL server accept connections
from any remote host.  You may instead choose to specify a comma-separated list
of host names and/or IP addresses.

NB: This parameter affects the entire PostgreSQL server, not just the Koji
database.  If the database cluster has other duties, additional work must be
done here to permit that.

##### `schema_source`
Source URI for the Koji database schema.  The default is
`'/usr/share/doc/koji/docs/schema.sql'`.

##### `username`
Name of the user who is to own the database.  Defaults to `'koji'`.

##### `web_username`
Name of the user that runs the Koji-Web server.  Defaults to `'apache'`.


#### koji::gc class

This class manages the Koji garbage collector on a host.

#####  `client_cert_content`, `client_cert_source`
Literal string or Puppet source URI providing the Koji garbage collector's
certificate.  This must be in PEM format.

##### `hub`
URL of your Koji-Hub server.

#####  `hub_ca_cert_content`, `hub_ca_cert_source`
Literal string or Puppet source URI providing the CA certificate which signed
Koji-Hub.  This must be in PEM format and include all intermediate CA
certificates, sorted and concatenated from the leaf CA to the root CA.

##### `keys`
GPG key IDs that were used to sign packages, as a hash.  E.g.:

    { 'fedora-gold' => '4F2A6FD2', 'fedora-test' => '30C9ECF8' }

##### `owner`
Name of the OS user account under which the garbage collection process
will run.

##### `top_dir`
Directory containing the `'repos/'` directory.

##### `web`
URL of your Koji-Web server.

##### `email_domain`
The domain name that will be appended to Koji user names when creating
email notifications.  Defaults to the `$domain` fact.

##### `grace_period`
Determines the length of time that builds are held in the trash can before
their ultimate demise.  The default is `'4 weeks'`.

##### `group`
Name of the OS group account under which the garbage collection process will
run.  The default is to be the same as *owner*.

##### `oldest_scratch`
Any scratch builds that were last modified more than this number of days
ago are eligible for purging.  Set to a negative number to prohibit
purging any scratch builds.  The default is 90 days.

##### `smtp_host`
The mail host to use for sending email notifications.  The Koji garbage
collector must be able to connect to this host via TCP on port 25.  The
default is `'localhost'`.

##### `unprotected_keys`
An array of names in *keys* which are to be considered unprotected by the
garbage collector.  Any key not listed here is considered a protected key.


#### koji::httpd class

This class manages Apache httpd for the needs of the Koji Hub/Web components.

This manages those parts of httpd that are common to both the Koji Hub and the
Koji Web components, which may be on the same or different hosts.


#### koji::hub class

This class manages the Koji Hub component on a host.

This manages the Koji Hub, an XML-RPC server running under mod\_wsgi in
Apache's httpd.  It also manages Koji's skeleton file system.  The Koji Hub may
be run on the same host as the Koji Web, but that's not required.

##### `db_host`
Name of host that provides the Koji database.

##### `db_passwd`
Password for the Koji database connection.

##### `db_port`
The TCP port for the Koji database connection.  The default is `5432`, the standard for a PostgreSQL database.  Supported since Koji 1.16.

##### `db_user`
User name for the Koji database connection.

##### `top_dir`
Directory containing the `'repos/'` directory.

##### `proxy_auth_dns`
An array of Distinguished Names (DN) of the clients allowed to proxy SSL
authentication requests through the Koji Hub.

##### `debug`
Enable verbose debugging for the Koji Hub.  One of: `true` or `false`
(default).

##### `email_domain`
The domain name that will be append to Koji user names when creating email
notifications.  Defaults to the `$domain` fact.

##### `packages`
An array of package names needed for the Koji Hub installation.

##### `plugins`
An array of strings, each naming a Koji Hub plugin that is to be enabled.  The
default is for no plugins to be enabled.

##### `traceback`
Determines how much detail about exceptions is reported to the client (via
faults).  The `'extended'` format is intended for debugging only and should NOT
be used in production, since it may contain sensitive information.  The default
is `'normal'`.  One of:

* `'normal'` - a basic traceback (format\_exception)
* `'extended'` - an extended traceback (format\_exc\_plus)
* `'message'` - no traceback, just the error message

##### `web_url`
The prefix the Koji Hub is to use when providing content references for access
through the Koji Web.  The default is `'http://`*FQDN*`/koji'` where *FQDN* is
the host's fully qualified domain name.


#### koji::hub::x509 class

This class manages the X.509 certificates on a host acting as a Koji Hub.  It's
use is optional and should only be included if you wish to use the integrated
X.509 support offered by the
[doubledog-openssl](https://github.com/jflorian/doubledog-openssl) module.

#####  `client_ca_cert_content`, `client_ca_cert_source`
Literal string or Puppet source URI providing the CA certificate which signed
the client certificates that wish to connect to this Koji Hub.  This must be in
PEM format and include all intermediate CA certificates, sorted and
concatenated from the leaf CA to the root CA.

#####  `hub_ca_cert_content`, `hub_ca_cert_source`
Literal string or Puppet source URI providing the CA certificate which signed
*hub_cert_source*.  This must be in PEM format and include all intermediate CA
certificates, sorted and concatenated from the leaf CA to the root CA.

#####  `hub_cert_content`, `hub_cert_source`
Literal string or Puppet source URI providing the Koji Hub's certificate.  This
must be in PEM format.

#####  `hub_key_content`, `hub_key_source`
Literal string or Puppet source URI providing the private key that was used to
sign the Koji Hub's certificate contained in *hub_cert_source*.  This must be
in PEM format.


#### koji::kojira class

This class manages the Kojira component on a host.

##### `hub`
URL of your Koji Hub service.

##### `top_dir`
Name of the directory containing the `'repos/'` directory.

##### `debug`
Enable verbose debugging for Kojira.  One of: `true` or `false` (default).

##### `deleted_repo_lifetime`
The number of seconds expired repositories must age before they will be
cleaned up.  The default is one week.

##### `dist_repo_lifetime`
The number of seconds dist repositories must age before they will be
cleaned up.  The default is one week.

##### `ensure`
Instance is to be `'running'` (default) or `'stopped'`.  Alternatively,
a Boolean value may also be used with `true` equivalent to `'running'` and
`false` equivalent to `'stopped'`.

##### `enable`
Instance is to be started at boot.  Either `true` (default) or `false`.

##### `service`
The service name of the Kojira daemon.


#### koji::kojira::x509 class

This class manages the X.509 certificates for Kojira.  It's use is optional and
should only be included if you wish to use the integrated X.509 support offered
by the [doubledog-openssl](https://github.com/jflorian/doubledog-openssl)
module.

#####  `hub_ca_cert_content`, `hub_ca_cert_source`
Literal string or Puppet source URI providing the CA certificate which signed
the Koji Hub certificate.  This must be in PEM format and include all
intermediate CA certificates, sorted and concatenated from the leaf CA to the
root CA.

#####  `kojira_cert_content`, `kojira_cert_source`
Literal string or Puppet source URI providing the Kojira component's identity
certificate which must be in PEM format.


#### koji::utils class

This class manages Koji utilities package.

##### `ensure`
Instance is to be `'present'` (default) or `'absent'`.

##### `packages`
An array of package names needed for the Koji utilities installation.


#### koji::web class

This class manages the Koji Web component on a host.

The Koji Web may be run on the same host as the Koji Hub, but that's not
required.

##### `files_url`
URL for accessing Koji's file resources.

##### `hub_url`
URL for accessing the Koji Hub's RPC services.

##### `secret`
Undocumented by the Koji project, but required.  Pass in a reasonably long
random string.  It is unknown where/how this is used exactly without deeper
investigation, but you won't need during normal use.

##### `debug`
Enable verbose debugging for the Koji Web.  When enabled, a full traceback will
be shown to the client for unhandled exceptions.  One of: `true` or `false`
(default).

##### `hidden_users`
An array of the numeric IDs of users that you want to hide from tasks listed on
the front page.  You might want to, for instance, hide the activity of an
account used for continuous integration.  The default is to not hide any user's
tasks.

##### `login_timeout`
Automatically logout users after this many hours.  The default is `72` hours.

##### `packages`
An array of package names needed for the Koji Web installation.

##### `theme`
Name of the web theme that Koji is to use.  Content under
`'/usr/share/koji-web/static/themes/$theme'` will be used instead of the normal
files under `'/usr/share/koji-web/static/'`.  Any absent files will fall back
to the normal files.  This module provides only the configuration to use
*theme* and provides nothing to actually install *theme*.


#### koji::web::x509 class

This class manages the X.509 certificates the Koji Web component.  It's use is
optional and should only be included if you wish to use the integrated X.509
support offered by the
[doubledog-openssl](https://github.com/jflorian/doubledog-openssl) module.

#####  `hub_ca_cert_content`, `hub_ca_cert_source`
Literal string or Puppet source URI providing the CA certificate which signed
the Koji Hub certificate.  This must be in PEM format and include all
intermediate CA certificates, sorted and concatenated from the leaf CA to the
root CA.

#####  `web_cert_content`, `web_cert_source`
Literal string or Puppet source URI providing the Koji Web's certificate.  This
must be in PEM format.


### Defined types

#### koji::cli::profile defined type

This defined type manages a Koji CLI configuration profile.

The profile is managed for all users on the host.  Specifically, the
configuration managed here resides in `/etc/` but some aspects of a profile may
abstractly reference a user's home directory via the conventional `'~'`
character in a file system path.  Depending on *auth_type*, it may be necessary
for each user to populate their `~/.koji/` directory with additional resources,
such as X.509 certificates.  Nothing in any user's home directory is managed by
this defined type.

Profiles can be utilized by the Koji CLI using:

    koji -p|--profile PROFILE

The Koji CLI will use a default profile named `koji` unless another is
specified.

##### `namevar`
An identifier for the configuration profile instance.  Specify `'koji'` to
configure the default profile.

It appears that the Koji CLI has built-in defaults even if a default profile is
absent.  Therefore if these defaults are undesired, the default profile must be
managed explicitly.

##### `downloads`
URL of your package download site.

##### `hub`
URL of your Koji-Hub server.

##### `top_dir`
Directory containing the `'repos/'` directory.

##### `web`
URL of your Koji-Web server.

##### `auth_type`
The method the client should use to authenticate itself to the Koji-Hub.  Must
be one of: `'noauth'`, `'ssl'`, `'password'`, or `'kerberos'`.  The default is
`'ssl'`.

##### `client_cert`
Name of the file containing the client's X.509 certificate to be used in
authenticating the client for this profile.  Ignored unless *auth_type* is
`'ssl'`.  The default is `'~/.koji/client.crt'`.

##### `max_retries`
When making Koji calls, if the Koji Hub reports a temporary failure, how many
times should the call be retried?  The default is `30`.

##### `offline_retry`
When making Koji calls, if the Koji Hub reports itself as offline, should the
call be retried automatically?  The default is `false`.

Note that offline failures are treated specially from other temporary failures.
These are not constrained by other failure handling options, most notably
*max_retries*.

##### `offline_retry_interval`
When making Koji calls, if the Koji Hub reports itself as offline and
*offline_retry* is `true`, this determines how many seconds the Koji Client
will wait before attempting the call again.  The default is 20 seconds.

##### `retry_interval`
When making Koji calls, if the Koji Hub reports a temporary failure, this
determines how many seconds the Koji Client will wait before attempting the
call again.  The default is 20 seconds.

##### `server_ca`
Name of the file containing the X.509 CA certificate that signed the *hub*.
Ignored unless *auth_type* is `'ssl'`.  The default is
`'~/.koji/serverca.crt'`.


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
precedence.  Value `'000'` is reserved for use by this module.


### Data types

### Facts


## Limitations

Tested on modern Fedora and CentOS releases, but likely to work on any Red Hat variant.  Adaptations for other operating systems should be trivial as this module follows the data-in-module paradigm.  See `data/common.yaml` for the most likely obstructions.  If "one size can't fit all", the value should be moved from `data/common.yaml` to `data/os/%{facts.os.name}.yaml` instead.  See `hiera.yaml` for how this is handled.

## Development

Contributions are welcome via pull requests.  All code should generally be compliant with puppet-lint.
