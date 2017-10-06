#!/bin/bash -e
# Install ODBC libraries for SOCI at travis-ci.org
#
# Copyright (c) 2013 Mateusz Loskot <mateusz@loskot.net>
#
source ${TRAVIS_BUILD_DIR}/scripts/travis/common.sh

sudo apt-get install -qq \
    tar bzip2 \
    unixodbc-dev \
    libmyodbc odbc-postgresql # libsqliteodbc 

sudo odbcinst -i -d -f /usr/share/libmyodbc/odbcinst.ini

# echo 'show odbcinst.ini'
# cat /etc/odbcinst.ini

echo 'install sqlite-dev'
sudo apt-get install libsqlite-dev

echo 'install fakeroot'
sudo apt-get install fakeroot

# Install sqlite3odbc driver
echo 'build sqlite3 odbc driver'
wget 'http://www.ch-werner.de/sqliteodbc/sqliteodbc-0.9995.tar.gz'
tar xzf sqliteodbc-*.tar.gz
cd sqliteodbc-*
sudo ./configure --build=x86_64-linux-gnu && make
sudo make install

echo 'install sqlite3 odbc driver'
# sed -i 's/lib\/odbc/lib\/x86_64-linux-gnu\/odbc/' ./debian/unixodbc.ini
sed -i 's/usr\/lib/usr\/local\/lib/' ./debian/unixodbc.ini
sudo odbcinst -i -d -f ./debian/unixodbc.ini

echo 'debian path'
ls -Al /usr/lib/odbc/

echo 'build path'
ls -Al /usr/local/lib/

echo 'show odbcinst.ini'
cat /etc/odbcinst.ini

# Ubuntu 12.04 is architecture dependend
# /usr/lib/x86_64-linux-gnu/odbc/libmyodbc.so
# /usr/lib/i386-linux-gnu/odbc/libmyodbc.so
echo 'driver path Ubuntu'
ls -Al /usr/lib/x86_64-linux-gnu/odbc/