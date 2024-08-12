#!/bin/bash

source ./helper_functions.sh

# Repositories
# Odoo (required for versions greater than 13.0)
ODOO_REPO=https://github.com/odoo/odoo.git
ODOO_BRANCH=$ODOO_TARGET_VERSION
ODOO_OCB_RELEASE=${ODOO_TARGET_VERSION}_2024-07-14
ODOO_OCB_REPO=https://git.coopdevs.org/coopdevs/odoo/OCB/-/archive/$ODOO_OCB_RELEASE/OCB-$ODOO_OCB_RELEASE.tar.gz
export ODOO_FOLDER=$(get_repo_local_folder $ODOO_REPO $ODOO_TARGET_VERSION_INT)

# OpenUpgrade
OPENUPGRADE_REPO=https://github.com/somitcoop/OpenUpgrade.git
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
    read -p "Do you want to clone Odoo from OCB repository? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        clone_OCB_repo $ODOO_OCB_REPO $ODOO_OCB_RELEASE $ODOO_TARGET_VERSION_INT
    else
        clone_repo $ODOO_REPO $ODOO_BRANCH $ODOO_TARGET_VERSION_INT
    fi
fi
clone_repo $OPENUPGRADE_REPO $OPENUPGRADE_BRANCH $ODOO_TARGET_VERSION_INT

# patch to migrate project_status on version 15.0
if [ $ODOO_TARGET_VERSION_INT -eq 15 ]; then
    cd $OPENUPGRADE_FOLDER
    git checkout 15.0-add-project_status
    git pull origin 15.0-add-project_status
    cd ..
fi

clone_repo $PYPI_SCRAPER_REPO $PYPI_SCRAPER_BRANCH ""
clone_repo $ODOO_INVENTORY_REPO $ODOO_INVENTORY_BRANCH ""

cd ../scripts
