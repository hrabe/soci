#!/bin/bash -e
# Install ODBC libraries for SOCI at travis-ci.org
#
# Copyright (c) 2013 Mateusz Loskot <mateusz@loskot.net>
#
source ${TRAVIS_BUILD_DIR}/scripts/travis/common.sh
source ${TRAVIS_BUILD_DIR}/scripts/travis/common_odbc.sh

sudo apt-get install -qq \
    tar bzip2 \
    unixodbc-dev \
    libmyodbc odbc-postgresql 

sudo odbcinst -i -d -f /usr/share/libmyodbc/odbcinst.ini

# need libsqliteodbc_0.9995 to pass all tests, 
# v0.91 from precise does not support vectors
download_and_install_sqlite_libs
# download_and_compile_sqlite_odbc
# show_odbcinst_ini
