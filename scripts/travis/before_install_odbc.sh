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
    libmyodbc odbc-postgresql libsqliteodbc 

sudo odbcinst -i -d -f /usr/share/libmyodbc/odbcinst.ini

echo 'show odbcinst.ini'
cat /etc/odbcinst.ini

# install_sqlite3
