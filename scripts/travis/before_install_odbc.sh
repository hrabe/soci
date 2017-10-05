#!/bin/bash -e
# Install ODBC libraries for SOCI at travis-ci.org
#
# Copyright (c) 2013 Mateusz Loskot <mateusz@loskot.net>
#
source ${TRAVIS_BUILD_DIR}/scripts/travis/common.sh

sudo apt-get install -qq \
    tar bzip2 \
    unixodbc-dev \
    libmyodbc odbc-postgresql

sudo odbcinst -i -d -f /usr/share/libmyodbc/odbcinst.ini

# Install travis-oracle
wget 'http://www.ch-werner.de/sqliteodbc/sqliteodbc-0.9995.tar.gz'
tar xzf sqliteodbc-*.tar.gz
cd sqliteodbc-*
./configure && make deb
make install
