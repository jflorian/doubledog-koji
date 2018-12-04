# == Class: koji::database
#
# Manages the Koji database on a host.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016-2018 John Florian


class koji::database (
        String[1]   $admin,
        String[1]   $password,
        String[1]   $dbname,
        String[1]   $listen_addresses,
        String[1]   $schema_source,
        String[1]   $username,
        String[1]   $web_username,
    ) {

    # Class[koji::cli] provides the schema.sql file required by the bootstrap
    # script.
    include '::koji::cli'

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
        content => template('koji/database/bootstrap.sh.erb'),
    } ->

    exec { 'bootstrap Koji database':
        user    => 'root',
        creates => $bstrap_flag,
        command => "${bstrap_cmd} &> ${bstrap_log} && touch ${bstrap_flag}",
    }

}
