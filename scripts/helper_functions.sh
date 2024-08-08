#!/bin/bash

function get_repo_local_folder() {
    repo_url=$1
    v_suffix=$2
    echo $(basename $repo_url .git)$v_suffix
}

function clone_repo() {
    repo_url=$1
    branch=$2
    v_suffix=$3
    repo_folder=$(get_repo_local_folder $repo_url $v_suffix)
    if [ ! -d $repo_folder ]; then
        git clone --branch=$branch --depth=1 --single-branch $repo_url $repo_folder
    else
        echo "Repo $repo_folder already exists and will not be cloned again."
    fi
}

function clone_OCB_repo() {
    repo_url=$1
    ocb_release=$2
    v_suffix=$3

    # keep it simple, just use the odoo version as the folder name
    repo_folder=odoo$v_suffix
    if [ ! -d $repo_folder ]; then
        mkdir $repo_folder
        
        # download and extract the repo
        wget $repo_url
        tar -xvf OCB-$ocb_release.tar.gz
        
        # move the content to the repo folder
        mv OCB-$ocb_release/* $repo_folder
        
        # cleanup
        rm -rf OCB-$ocb_release
        rm OCB-$ocb_release.tar.gz
    else
        echo "Repo $repo_folder already exists and will not be cloned again."
    fi
}

function get_odoo_python_version() {
    ODOO_TARGET_VERSION=$1
    if [ $ODOO_TARGET_VERSION == "12.0" ]; then
        python_version=3.7.12
    elif [ $ODOO_TARGET_VERSION == "13.0" ]; then
        python_version=3.7.16
    elif [ $ODOO_TARGET_VERSION == "14.0" ]; then
        python_version=3.8.5
    elif [ $ODOO_TARGET_VERSION == "15.0" ]; then
        python_version=3.8.13
    elif [ $ODOO_TARGET_VERSION == "16.0" ]; then
        python_version=3.11.6
    else
        echo "Odoo version not supported."
        exit 1
    fi
    echo $python_version
}

function create_virtualenv() {
    environment_name=$1
    python_version=$2

    if [ -z $python_version ]; then
        python_version=$(get_odoo_python_version $ODOO_TARGET_VERSION)
    fi

    if [ ! $(pyenv versions --bare --skip-aliases --skip-envs | grep $python_version) ]; then
        pyenv install $python_version
    fi
    pyenv virtualenv-delete -f $environment_name
    pyenv virtualenv $python_version $environment_name
}
