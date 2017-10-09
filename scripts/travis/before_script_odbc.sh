#!/bin/bash -e
# Sets up environment for SOCI backend ODBC at travis-ci.org
#
# Mateusz Loskot <mateusz@loskot.net>, http://github.com/SOCI
#
source ${TRAVIS_BUILD_DIR}/scripts/travis/common.sh
source ${TRAVIS_BUILD_DIR}/scripts/travis/common_odbc.sh
source ${TRAVIS_BUILD_DIR}/scripts/travis/before_script_firebird.sh

mysql --version
mysql -e 'create database soci_test;'
psql --version
psql -c 'create database soci_test;' -U postgres > /dev/null
sqlite3_version
isql-fb -z -q -i /dev/null # --version
echo '>>> Installed ODBC Driver:'
odbcinst -q -d
