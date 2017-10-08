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
  echo '>>> install libsqlite3-dev_3.16.2-5_amd64.deb'
  mkdir -p ./tmp-sqlite
  mkdir -p ./tmp-extracted
  cd tmp-sqlite
#  wget 'http://launchpadlibrarian.net/310407015/sqlite3_3.16.2-3_amd64.deb'
  wget 'http://launchpadlibrarian.net/310407012/libsqlite3-0_3.16.2-3_amd64.deb'
#  wget 'http://launchpadlibrarian.net/310407013/libsqlite3-dev_3.16.2-3_amd64.deb'
#  wget 'http://launchpadlibrarian.net/284875588/libreadline7_7.0-0ubuntu2_amd64.deb'
  wget 'http://launchpadlibrarian.net/295938781/libsqliteodbc_0.9995-1_amd64.deb'
#  wget 'http://launchpadlibrarian.net/271601076/libtinfo5_6.0+20160625-1ubuntu1_amd64.deb'
  cd ..
  sudo dpkg -i -R --force-depends ./tmp-sqlite/libsqlite3-0_3.16.2-3_amd64.deb ./tmp-extracted
  sudo apt-get -f install
  
  echo '>>> extract and list ./tmp-sqlite/'
  sudo dpkg -x ./tmp-sqlite/
  ls -Al ./tmp-sqlite/
  
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

install_sqlite_old()
{
  # wget 'http://ftp.de.debian.org/debian/pool/main/s/sqlite3/libsqlite3-0_3.16.2-5_amd64.deb'
  # wget 'http://ftp.de.debian.org/debian/pool/main/s/sqlite3/libsqlite3-dev_3.16.2-5_amd64.deb'
  # sudo dpkg -i libsqlite3-0_3.16.2-5_amd64.deb
  # sudo dpkg -i libsqlite3-dev_3.16.2-5_amd64.deb
  # sudo apt-get -f install

  echo 'install fakeroot'
  sudo apt-get install fakeroot

  # echo 'install sqlite from scratch'
  # sqlite3 --version
  # # wget 'http://www.sqlite.org/2017/sqlite-autoconf-3200100.tar.gz'
  # wget 'http://www.sqlite.org/2016/sqlite-autoconf-3150200.tar.gz'
  # tar xzf sqlite-autoconf-*.tar.gz
  # cd sqlite-autoconf-*
  # sudo ./configure --build=x86_64-linux-gnu && make
  # sudo make install
  #
  # cd ..

  echo 'install sqlite3-dev'
  # sudo add-apt-repository -y ppa:jonathonf/backports
  # sudo apt-get update && sudo apt-get install sqlite3 libsqlite3-dev
  
  # sudo add-apt-repository ppa:jonathonf/backports -y
  # sudo apt-get update -q
  # sudo apt-get install sqlite3 libsqlite3-dev -y
  ### sudo apt-get update && apt-get install sqlite libsqlite-dev

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
