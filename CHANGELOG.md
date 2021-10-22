<!--
This file is part of the doubledog-koji Puppet module.
Copyright 2018-2021 John Florian
SPDX-License-Identifier: GPL-3.0-or-later

Template

## [VERSION] WIP
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

-->

# Change log

All notable changes to this project (since v4.0.0) will be documented in this file.  The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [4.6.1] WIP
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
- `/etc/koji-hub/hub.conf` world-readable with DB connection password

## [4.6.0] 2021-10-06
### Added
- Fedora 34 support (builders only)
### Changed
- refreshed templates against `koji-1.21.1-1.el7` and `koji-builder-1.22.1-1.fc33`
- allow httpd to follow symlinks for static content and local product branding
- `puppetlabs-postgresql` module dependency now allows version 7
### Removed
- Fedora 31 support

## [4.5.0] 2021-03-10
### Added
- Fedora 32-33 support
### Removed
- work around for `python-simplejson` for Koji < 1.11.0 (no longer needed)
- Fedora 29-30 support
### Fixed
- CentOS 8 support missing `ssl.conf` template

## [4.4.0] 2020-02-24
### Added
- Fedora 31 support
### Removed
- Fedora 28 support

## [4.3.0] 2019-10-21
### Added
- CentOS 8 support
### Changed
- `puppetlabs-concat` module dependency now allows version 6
- `puppetlabs-postgresql` module dependency now allows version 6
- `puppetlabs-stdlib` module dependency now allows version 6

## [4.2.0] 2019-06-14
### Added
- parameters:
    - `koji::builder::max_jobs`
    - `koji::builder::rpmbuild_timeout`
    - `koji::builder::sleep_time`
    - `koji::gc::policies` for Hiera driven declarations
- module dependencies:
    - `doubledog-ddolib`
    - `puppetlabs-stdlib`
- data types:
    - `Koji::Gc::Seq`
    - `Koji::GpgKeyId`
    - `Koji::Traceback`
### Changed
- `koji::gc::policy::seq` now also accepts integer values
- freshen version requirement on `doubledog-cron` module
### Fixed
- `koji::utils::ensure` parameter:
    - enforces values suitable for files, but doesn't accept most for packages
    - is not honored
- `koji::gc::unprotected_keys` parameter:
    - did not accept key names as documented
    - documentation did not mention allowance of key IDs

## [4.1.2] 2019-05-23
### Fixed
- `spin-livemedia` tasks fail on Fedora-based Koji Builders
    - `pycdio` and `python2-kickstart` packages are still required there

## [4.1.1] 2019-05-13
### Fixed
- Koji Builders on Fedora 30 fail with `Generic Error: install librepo or yum`

## [4.1.0] 2019-05-02
### Added
- `client_cert` parameter to the `koji::cli::profile` defined type.
- `server_ca` parameter to the `koji::cli::profile` defined type.
- Fedora 30 support
### Changed
- Improved documentation for the `koji::cli::profile` defined type.
- Absolute namespace references have been eliminated since modern Puppet versions no longer require this.
### Removed
- Fedora 27 support

## [4.0.1] 2019-02-21
### Changed
- `puppetlabs-concat` dependency now allows version 5
### Fixed
- X.509 certificate management may cause `No such file or directory` errors because the directory to which they are to be deployed has not yet been created by the appropriate package installation.

## [4.0.0 and prior] 2018-12-15

This and prior releases predate this project's keeping of a formal CHANGELOG.  If you are truly curious, see the Git history.
