#!/bin/bash

source ./helper_functions.sh

# Setup virtual environment and install requirements
environment_name=$DB_NAME-$ODOO_TARGET_VERSION_INT
create_virtualenv $environment_name

pyenv activate $environment_name

if [ $ODOO_TARGET_VERSION_INT -ge 14 ]; then
    cd ../migration/$ODOO_FOLDER
else
    cd ../migration/$OPENUPGRADE_FOLDER
fi

pip install -r requirements.txt
python setup.py install

echo "Please make sure that missing requirements are resolved before continuing."
read -p "Ready to continue? (y/n) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

pip install -r ../$PYPI_SCRAPER_FOLDER/data/requirements-$ODOO_TARGET_VERSION_INT.txt

# ensure that the latest version of openupgradelib is installed
pip install git+https://github.com/OCA/openupgradelib.git@master#egg=openupgradelib --upgrade

# Prepare odoo.conf file with database connection details
touch ../odoo.conf
> ../odoo.conf
echo "[options]" >> ../odoo.conf
echo "db_host = $DB_HOST" >> ../odoo.conf
echo "db_port = $DB_PORT" >> ../odoo.conf
echo "db_user = $DB_USER" >> ../odoo.conf
echo "db_password = $DB_PASSWORD" >> ../odoo.conf
echo "db_name = $DB_NAME" >> ../odoo.conf

# Run the migration script
if [ $ODOO_TARGET_VERSION_INT -ge 14 ]; then
    echo "addons_path = $PWD/addons,$PWD/../$OPENUPGRADE_FOLDER" >> ../odoo.conf
    python odoo-bin -c $PWD/../odoo.conf --upgrade-path=$PWD/../$OPENUPGRADE_FOLDER/openupgrade_scripts/scripts --load=base,web,openupgrade_framework --update all --stop-after-init
else
    echo "addons_path = $PWD/addons,$PWD/odoo/addons" >> ../odoo.conf
    python odoo-bin -c $PWD/../odoo.conf -u all --stop-after-init
fi

# Deactivate virtual environment and delete it
pyenv deactivate
pyenv virtualenv-delete -f $environment_name

cd ../../scripts