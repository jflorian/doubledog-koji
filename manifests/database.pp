# modules/koji/manifests/database.pp
#
# == Class: koji::database
#
# Manages the Koji database on a host.
#
# This class presently assumes a PostgreSQL database.  It will handles all
# Koji database set up steps for a PostgreSQL server as described at:
#   https://fedoraproject.org/wiki/Koji/ServerHowTo#PostgreSQL_Server
#
# Specifically, this class will:
#   1. install/configure the PostgreSQL server, including authentication
#   2. create the database and PostgreSQL user role
#   3. import the Koji database schema
#   4. bootstrap the database with an initial Koji administrator account
#
# === Upgrading
#
# This class is primarily useful for establishing new Koji setups.  If you
# already have a Koji setup and you are building a newer one to replace it,
# a suggested procedure is as follows:
#
#   1. successfully apply this to the new Koji host ($NEW)
#   2. stop the Puppet agent on $NEW
#   3. stop the PostgreSQL server on $NEW
#   4. reinitialize the database cluster
#   5. perform a full dump on the old Koji host $(OLD)
#   6. transfer the dumped content to $NEW
#   7. load the dumped content on $NEW
#   8. review migration documents on $NEW; see "rpm -qd koji"
#
# === Parameters
#
# ==== Required
#
# [*password*]
#   Password for the created database user.
#
# ==== Optional
#
# [*dbname*]
#   Name of the database.  Defaults to "koji".
#
# [*listen_addresses*]
#   From where should the PostgreSQL server accept connections?  Defaults to
#   "localhost" which means it will only accept connections originating from
#   the local host.  A value of "*" makes the PostgreSQL server accept
#   connections from any remote host.  You may instead choose to specify
#   a comma-separated list of host names and/or IP addresses.
#
#   NB: This parameter affects the entire PostgreSQL server, not just the Koji
#   database.  If the database cluster has other duties, additional work must
#   be done here to permit that.
#
# [*schema_source*]
#   Source URI for the Koji database schema.  The default is
#   "/usr/share/doc/koji/docs/schema.sql".
#
# [*username*]
#   Name of the user who is to own the database.  Defaults to "koji".
#
# [*web_username*]
#   Name of the that runs the Koji-Web server.  Defaults to "apache".
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016 John Florian


class koji::database (
        $password,
        $dbname='koji',
        $listen_addresses='localhost',
        $schema_source='/usr/share/doc/koji/docs/schema.sql',
        $username='koji',
        $web_username='apache',
    ) inherits ::koji::params {

    # Class[koji::cli] provides the schema.sql file required by the bootstrap
    # script.
    include '::koji::cli'

    $admin = $::koji::params::admin_user
    $bstrap_cmd = "/var/lib/pgsql/data/bootstrap-${dbname}-database"
    $bstrap_flag = "${bstrap_cmd}.flag"
    $bstrap_log = "${bstrap_cmd}.log"

    class { '::postgresql::server':
        listen_addresses => $listen_addresses,
    }

    ::postgresql::server::pg_hba_rule {
        default:
            auth_method => 'trust',
            database    => $dbname,
            order       => '001',
            ;
        'allow Koji-Hub via local IPv4 connection':
            type    => 'host',
            user    => $username,
            address => '127.0.0.0/8',
            ;
        'allow Koji-Hub via local IPv6 connection':
            type    => 'host',
            user    => $username,
            address => '::1/128',
            ;
        'allow Koji-Hub via local domain socket':
            type    => 'local',
            user    => $username,
            ;
        'allow Koji-Web via local domain socket':
            type    => 'local',
            user    => $web_username,
            ;
    } ->

    ::postgresql::server::db { $dbname:
        user     => $username,
        password => $password,
    } ->

    file { $bstrap_cmd:
        owner   => 'root',
        group   => 'root',
        mode    => '0754',
        content => template('koji/database/bootstrap.sh'),
    } ->

    exec { 'bootstrap Koji database':
        user    => 'root',
        creates => $bstrap_flag,
        command => "${bstrap_cmd} &> ${bstrap_log} && touch ${bstrap_flag}",
    }

}
