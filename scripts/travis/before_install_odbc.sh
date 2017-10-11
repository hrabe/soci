#!/bin/bash -e
# Install ODBC libraries for SOCI at travis-ci.org
#
# Copyright (c) 2013 Mateusz Loskot <mateusz@loskot.net>
#
source ${TRAVIS_BUILD_DIR}/scripts/travis/common.sh
source ${TRAVIS_BUILD_DIR}/scripts/travis/common_odbc.sh
source ${TRAVIS_BUILD_DIR}/scripts/travis/before_install_firebird.sh

sudo apt-get install -qq \
    tar bzip2 \
    unixodbc-dev \
    libmyodbc odbc-postgresql libfbclient2 odbc-mdbtools

sudo odbcinst -i -d -f /usr/share/libmyodbc/odbcinst.ini

# need libsqliteodbc_0.9995 to pass all tests, 
# v0.91 from ubuntu precise does not support vectors
download_and_install_sqlite_driver
# driver no official ubuntu driver available
# download_and_install_firebird_driver_official
# download_and_install_firebird_driver_devart_trial2
# download_and_install_sqlite_driver_devart_trial

# db2 has to be installed different
download_and_install_devart_trial_driver sqlite
download_and_install_devart_trial_driver mysql
download_and_install_devart_trial_driver postgresql
download_and_install_devart_trial_driver firebird
download_and_install_devart_trial_driver sqlserver
download_and_install_devart_trial_driver oracle
