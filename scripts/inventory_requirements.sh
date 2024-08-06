#!/bin/bash

source ./helper_functions.sh

cd ../migration

if [ -f $PYPI_SCRAPER_FOLDER/data/requirements-$ODOO_TARGET_VERSION_INT.txt ]; then
    echo "Requirements file already updated for Odoo version $ODOO_TARGET_VERSION"
else
    cd $PYPI_SCRAPER_FOLDER

    create_virtualenv pypi-scraper 3.10.12

    pyenv activate pypi-scraper
    pip install -r requirements.txt
    python main.py -f ../$ODOO_INVENTORY_FOLDER/files/requirements.txt -v $ODOO_TARGET_VERSION -V

    # Deactivate virtual environment and delete it
    pyenv deactivate
    pyenv virtualenv-delete -f pypi-scraper

    cd ../

    # Clean known issues with OCA repositories
    # TODO: Implement this
fi

cd ../scripts