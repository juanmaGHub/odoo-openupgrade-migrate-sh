#!/bin/bash

read -p "Do you want to restore the database from a dump file? (y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd backup

    if [ ! -f dump.sql ]; then
        echo "No dump.sql found."
        echo "Please place the dump.sql file in /backup folder in this script directory."
        exit 1
    fi
    PGPASSWORD=$DB_PASSWORD
    export PGPASSWORD
    if [ $(psql -h $DB_HOST -U $DB_USER -lqt | cut -d \| -f 1 | grep $DB_NAME) ]; then
        dropdb -h $DB_HOST -U $DB_USER $DB_NAME
    fi
    createdb -h $DB_HOST -U $DB_USER $DB_NAME
    psql -h $DB_HOST -U $DB_USER -d $DB_NAME < dump.sql

    unset PGPASSWORD
    
    cd ..
fi