#!/bin/bash -e
# Common definitions used by SOCI build scripts at travis-ci.org
#
# Copyright (c) 2013 Mateusz Loskot <mateusz@loskot.net>
#
if [[ "$TRAVIS" != "true" ]] ; then
	echo "Running this script makes no sense outside of travis-ci.org"
	exit 1
fi

install_sqlite3()
{
  echo 'install libsqlite3-dev_3.16.2-5_amd64.deb'
  # wget 'http://ftp.de.debian.org/debian/pool/main/s/sqlite3/libsqlite3-0_3.16.2-5_amd64.deb'
  # wget 'http://ftp.de.debian.org/debian/pool/main/s/sqlite3/libsqlite3-dev_3.16.2-5_amd64.deb'
  # sudo dpkg -i libsqlite3-0_3.16.2-5_amd64.deb libsqlite3-dev_3.16.2-5_amd64.deb
  # sudo apt-get -f install

  # echo 'install sqlite3-dev'
  # sudo add-apt-repository ppa:jonathonf/backports
  # sudo apt-get update && sudo apt-get install sqlite3 libsqlite3-dev
  sudo apt-get update && apt-get install sqlite libsqlite-dev

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
  sed -i 's/usr\/lib\/odbc/usr\/local\/lib/' ./debian/unixodbc.ini
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
}
