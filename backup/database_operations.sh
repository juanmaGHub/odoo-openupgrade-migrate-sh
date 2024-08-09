#!/bin/bash

read -p "Do you want to restore the database from a dump file? (y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd backup
    ODOO_TARGET_VERSION_INT=$(echo $ODOO_TARGET_VERSION | sed 's/\.0//')

    DUMPFILE=dump$(($ODOO_TARGET_VERSION_INT - 1)).sql
    echo "Restoring database from $DUMPFILE"

    if [ ! -f $DUMPFILE ]; then
        echo "No $DUMPFILE found."
        echo "Please place the dump.sql file in /backup folder in this script directory."
        exit 1
    fi
    PGPASSWORD=$DB_PASSWORD
    export PGPASSWORD
    if [ $(psql -h $DB_HOST -U $DB_USER -lqt | cut -d \| -f 1 | grep $DB_NAME) ]; then
        dropdb -h $DB_HOST -U $DB_USER $DB_NAME
    fi
    createdb -h $DB_HOST -U $DB_USER $DB_NAME
    psql -h $DB_HOST -U $DB_USER -d $DB_NAME < $DUMPFILE

    unset PGPASSWORD
    
    cd ..
fi