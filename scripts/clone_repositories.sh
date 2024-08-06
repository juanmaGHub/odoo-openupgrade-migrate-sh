#!/bin/bash

source ./helper_functions.sh

# Repositories
# Odoo (required for versions greater than 13.0)
ODOO_REPO=https://github.com/odoo/odoo.git
ODOO_BRANCH=$ODOO_TARGET_VERSION
export ODOO_FOLDER=$(get_repo_local_folder $ODOO_REPO $ODOO_TARGET_VERSION_INT)

# OpenUpgrade
OPENUPGRADE_REPO=https://github.com/OCA/OpenUpgrade.git
OPENUPGRADE_BRANCH=$ODOO_TARGET_VERSION
export OPENUPGRADE_FOLDER=$(get_repo_local_folder $OPENUPGRADE_REPO $ODOO_TARGET_VERSION_INT)

# PyPI Scraper
PYPI_SCRAPER_REPO=https://github.com/juanmaGHub/odoo-addon-pypi-scraper.git
PYPI_SCRAPER_BRANCH=main
export PYPI_SCRAPER_FOLDER=$(get_repo_local_folder $PYPI_SCRAPER_REPO "")

# Project Odoo Inventory
export ODOO_INVENTORY_FOLDER=$(get_repo_local_folder $ODOO_INVENTORY_REPO "")

# Clone repositories in the migration folder
if [ ! -d ../migration ]; then
    mkdir ../migration
fi
cd ../migration

# Odoo is only cloned for versions greater than 13.0
if [ $ODOO_TARGET_VERSION_INT -ge 14 ]; then
    clone_repo $ODOO_REPO $ODOO_BRANCH $ODOO_TARGET_VERSION_INT
fi
clone_repo $OPENUPGRADE_REPO $OPENUPGRADE_BRANCH $ODOO_TARGET_VERSION_INT
clone_repo $PYPI_SCRAPER_REPO $PYPI_SCRAPER_BRANCH ""
clone_repo $ODOO_INVENTORY_REPO $ODOO_INVENTORY_BRANCH ""

cd ../scripts
