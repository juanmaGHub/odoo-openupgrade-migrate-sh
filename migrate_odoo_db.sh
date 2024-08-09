#!/bin/bash

# Migration target version
ODOO_TARGET_VERSION=$1
if [ -z "$ODOO_TARGET_VERSION" ]; then
    echo "Usage: ./migrate_odoo_db.sh <ODOO_TARGET_VERSION>"
    echo "Example: ./migrate_odoo_db.sh 14.0"
    exit 1
fi
export ODOO_TARGET_VERSION=$ODOO_TARGET_VERSION
export ODOO_TARGET_VERSION_INT=$(echo $ODOO_TARGET_VERSION | sed 's/\.0//')

# Project environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' ".env" | xargs)
else
    echo "The .env file is missing."
    exit 1
fi

source ./backup/database_operations.sh


echo "Migrating Odoo database to version $ODOO_TARGET_VERSION"

# Execute scripts
cd scripts

source ./clone_repositories.sh

if [ -f ~/.bash_profile ]; then
    read -p "Bash profile found. Do you want activate it? (y/n)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Enabling pyenv in the current shell"
        source ~/.bash_profile
    fi
fi

# Update OCA addons requirements for the target Odoo version
source ./inventory_requirements.sh

# Create migration environment and run the migration script
source ./run_migration.sh

# Clean workspace
read -p "Do you want to clean the workspace? (y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    source ./clean_workspace.sh
fi

cd ../backup
pg_dump -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -f dump$ODOO_TARGET_VERSION_INT.sql

cd ..
echo "Migration completed successfully."
