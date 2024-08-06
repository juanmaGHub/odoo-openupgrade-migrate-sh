#!/bin/bash

# Remove version specific migration repositories
rm -rf ../migration/$ODOO_FOLDER
rm -rf ../migration/$OPENUPGRADE_FOLDER
rm -rf ../migration/odoo.conf

# Unset the environment variables
unset ODOO_TARGET_VERSION
unset ODOO_TARGET_VERSION_INT
unset ODOO_FOLDER
unset OPENUPGRADE_FOLDER
unset PYPI_SCRAPER_FOLDER
unset ODOO_INVENTORY_FOLDER

for var in $(grep -v '^#' "../.env" | xargs); do
    unset $var
done
