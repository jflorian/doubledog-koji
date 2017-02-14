# modules/koji/manifests/gc.pp
#
# == Class: koji::gc
#
# Manages the Koji garbage collector on a host.
#
# For some additional details see:
#   http://fedoraproject.org/wiki/Koji/GarbageCollection
#
# === Parameters
#
# ==== Required
#
# [*client_cert*]
#   Puppet source URI providing the Koji garbage collector's certificate.
#   This must be in PEM format.
#
# [*hub*]
#   URL of your Koji-Hub server.
#
# [*hub_ca_cert*]
#   Puppet source URI providing the CA certificate which signed Koji-Hub.
#   This must be in PEM format and include all intermediate CA certificates,
#   sorted and concatenated from the leaf CA to the root CA.
#
# [*keys*]
#   GPG key IDs that were used to sign packages, as a hash.  E.g.,
#   { 'fedora-gold' => '4F2A6FD2', 'fedora-test' => '30C9ECF8' }
#
# [*owner*]
#   Name of the OS user account under which the garbage collection process
#   will run.
#
# [*top_dir*]
#   Directory containing the "repos/" directory.
#
# [*web*]
#   URL of your Koji-Web server.
#
# ==== Optional
#
# [*email_domain*]
#   The domain name that will be appended to Koji user names when creating
#   email notifications.  Defaults to the $domain fact.
#
# [*grace_period*]
#   Determines the length of time that builds are held in the trash can before
#   their ultimate demise.  The default is "4 weeks".
#
# [*group*]
#   Name of the OS group account under which the garbage collection process
#   will run.  The default is to be the same as "owner".
#
# [*oldest_scratch*]
#   Any scratch builds that were last modified more than this number of days
#   ago are eligible for purging.  Set to a negative number to prohibit
#   purging any scratch builds.  The default is 90 days.
#
# [*smtp_host*]
#   The mail host to use for sending email notifications.  The Koji garbage
#   collector must be able to connect to this host via TCP on port 25.  The
#   default is 'localhost'.
#
# [*unprotected_keys*]
#   An array of names in "keys" which are to be considered unprotected by the
#   garbage collector.  Any key not listed here is considered a protected key.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016-2017 John Florian


class koji::gc (
        String[1]                               $client_cert,
        String[1]                               $hub,
        String[1]                               $hub_ca_cert,
        Hash[String, Pattern[/[0-9A-F]{8}/], 1] $keys,
        String[1]                               $owner,
        String[1]                               $top_dir,
        String[1]                               $web,
        String[1]                               $email_domain=$::domain,
        String[1]                               $grace_period='4 weeks',
        String[1]                               $group=$owner,
        Integer                                 $oldest_scratch=90,
        String[1]                               $smtp_host='localhost',
        Array[Pattern[/[0-9A-F]{8}/]]           $unprotected_keys=[],
    ) inherits ::koji::params {

    include '::koji::packages::utils'

    file {
        default:
            owner     => $owner,
            group     => $group,
            mode      => '0640',
            seluser   => 'system_u',
            selrole   => 'object_r',
            seltype   => 'etc_t',
            subscribe => Class['::koji::packages::utils'],
            ;
        '/etc/koji-gc/client.pem':
            source  => $client_cert,
            ;
        '/etc/koji-gc/serverca.crt':
            source  => $hub_ca_cert,
            ;
    }

    ::concat { 'koji-gc.conf':
        path      => '/etc/koji-gc/koji-gc.conf',
        owner     => 'root',
        group     => 'root',
        mode      => '0644',
        seluser   => 'system_u',
        selrole   => 'object_r',
        seltype   => 'etc_t',
        subscribe => Class['::koji::packages::utils'],
    }

    ::concat::fragment { 'koji-gc.conf-top':
        target  => 'koji-gc.conf',
        order   => '000',
        content => template('koji/gc/koji-gc.conf'),
    }

    ::cron::job {
        'koji-gc':
            command => 'koji-gc',
            user    => $owner,
            hour    => '4',
            minute  => '42',
            ;
    }

}
