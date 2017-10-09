#!/bin/bash -e
# Common definitions used by SOCI build scripts at travis-ci.org
#
# Copyright (c) 2013 Mateusz Loskot <mateusz@loskot.net>
#
if [[ "$TRAVIS" != "true" ]] ; then
	echo "Running this script makes no sense outside of travis-ci.org"
	exit 1
fi

download_and_install_sqlite_libs()
{
  echo ">>> download & install newer ubuntu sqlite libs"
  mkdir -p ./debs-ubuntu
  cd debs-ubuntu
  wget 'http://launchpadlibrarian.net/310407012/libsqlite3-0_3.16.2-3_amd64.deb'
  wget 'http://launchpadlibrarian.net/310407013/libsqlite3-dev_3.16.2-3_amd64.deb'  
  wget 'http://launchpadlibrarian.net/295938781/libsqliteodbc_0.9995-1_amd64.deb'
  cd ..
  sudo dpkg -i -R --force-depends ./debs-ubuntu/
  sudo apt-get -f install
}

download_and_compile_sqlite_odbc()
{
  echo '>>> download and install sqlite odbc driver'
  wget 'http://www.ch-werner.de/sqliteodbc/sqliteodbc-0.9995.tar.gz'
  tar xzf sqliteodbc-*.tar.gz
  cd sqliteodbc-*
  sudo ./configure --build=x86_64-linux-gnu && make
  sudo make install

  echo 'install sqlite3 odbc driver'
  # sed -i 's/lib\/odbc/lib\/x86_64-linux-gnu\/odbc/' ./debian/unixodbc.ini
  sed -i 's/usr\/lib\/odbc/usr\/local\/lib/' ./debian/unixodbc.ini
  sudo odbcinst -i -d -f ./debian/unixodbc.ini
}

install_sqlite3()
{
  echo '>>> install libsqlite3-dev_3.16.2-5_amd64.deb'
  mkdir -p ./tmp-sqlite
  mkdir -p ./tmp-extracted
  cd tmp-sqlite
#  wget 'http://launchpadlibrarian.net/310407015/sqlite3_3.16.2-3_amd64.deb'
  wget 'http://launchpadlibrarian.net/310407012/libsqlite3-0_3.16.2-3_amd64.deb'
  wget 'http://launchpadlibrarian.net/310407013/libsqlite3-dev_3.16.2-3_amd64.deb'
#  wget 'http://launchpadlibrarian.net/284875588/libreadline7_7.0-0ubuntu2_amd64.deb'
  wget 'http://launchpadlibrarian.net/295938781/libsqliteodbc_0.9995-1_amd64.deb'
#  wget 'http://launchpadlibrarian.net/271601076/libtinfo5_6.0+20160625-1ubuntu1_amd64.deb'
  cd ..
  sudo dpkg -i -R --force-depends ./tmp-sqlite/
  sudo apt-get -f install
  
  echo '>>> show content libsqlite3-0_3.16.2-3_amd64.deb'
  sudo dpkg -c ./tmp-sqlite/libsqlite3-0_3.16.2-3_amd64.deb #./tmp-extracted
  # ls -Al ./tmp-extracted/
  
  echo '>>> debian lib path'
  ls -Al /usr/lib/odbc/

  echo '>>> local build path'
  ls -Al /usr/local/lib/

  echo '>>> show odbcinst.ini'
  cat /etc/odbcinst.ini

  # Ubuntu 12.04 is architecture dependend
  # /usr/lib/x86_64-linux-gnu/odbc/libmyodbc.so
  # /usr/lib/i386-linux-gnu/odbc/libmyodbc.so
  echo '>>> /usr/lib/x86_64-linux-gnu/'
  ls -Al /usr/lib/x86_64-linux-gnu/

  echo '>>> /usr/lib/x86_64-linux-gnu/odbc/'
  ls -Al /usr/lib/x86_64-linux-gnu/odbc/  
}
