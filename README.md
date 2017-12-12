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

**Defined types:**

* [koji::cli::profile](#kojicliprofile-defined-type)


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
