#!/bin/bash
#
# This file is managed by Puppet via the "<%= @module_name %>" module.

# Synopsis:
#       Bootstrap the Koji database.
#
# Copyright 2016 John Florian <jflorian@doubledog.org>

SELF="$(basename $0)"

# Context passed from Class[koji::database].
ADMIN='<%= @admin %>'
DB_NAME='<%= @dbname %>'
DB_OWNER='<%= @username %>'
SCHEMA='<%= @schema_source %>'

fail() {
    if [ "$1" = '-h' ]
    then
        usage
        shift
    fi
    echo >&2 "Error: $*"
    exit 1
}

usage() {
    cat >&2 <<EOF
Usage:
$SELF [OPTION]...

Options:
    -h
        Display this help and exit.

EOF
}

get_options_and_arguments() {
    local opt
    OPTIND=1
    while getopts ':h' opt
    do
        case "$opt" in
            h)  usage && exit 0 ;;
            \?) fail -h "invalid option: -$OPTARG" ;;
            \:) fail -h "option -$OPTARG requires an argument" ;;
        esac
    done
    shift $((OPTIND-1)); OPTIND=1
    [ $# -eq 0 ] || fail -h "unexpected arguments: $@"
}

notice() {
    echo -e "\n## $* ..."
}

import_database_schema() {
    notice 'Importing Koji database schema ...'
    psql -f $SCHEMA $DB_NAME $DB_OWNER \
        || fail 'Could not import Koji database schema.'
}

create_admin_user() {
    notice "Creating Koji administrator '${ADMIN}' ..."
    psql -c "insert into users (name, status, usertype)
             values ('${ADMIN}', 0, 0);" \
            $DB_NAME $DB_OWNER \
        || fail 'Could not create Koji administrator.'
}

assign_admin_permissions() {
    notice "Assigning administrator permissions to '${ADMIN}' ..."
    psql -c "insert into user_perms (user_id, perm_id, creator_id)
                    select users.id, permissions.id, users.id
                    from users, permissions
                    where users.name in ('${ADMIN}')
                      and permissions.name = 'admin';" \
            $DB_NAME $DB_OWNER \
        || fail 'Could assign administrator permissions.'
}

main() {
    get_options_and_arguments "$@"
    import_database_schema
    create_admin_user
    assign_admin_permissions
}


main "$@"
