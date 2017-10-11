#!/bin/bash -e
# Common definitions used by SOCI build scripts at travis-ci.org
#
# Copyright (c) 2013 Mateusz Loskot <mateusz@loskot.net>
#
if [[ "$TRAVIS" != "true" ]] ; then
	echo "Running this script makes no sense outside of travis-ci.org"
	exit 1
fi

download_and_install_sqlite_driver()
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

sqlite3_version()
{
  echo 'SQlite3 3.16.2'
  # impossible due to removed binary by install newer deb packages
  # sqlite3 --version
}

download_and_install_firebird_driver()
{
  wget 'https://netcologne.dl.sourceforge.net/project/firebird/firebird-ODBC-driver/2.0.5-Release/OdbcFb-LIB-2.0.5.156.amd64.gz'
  tar -xzf OdbcFb-LIB-2.0.5.156.amd64.gz
  sudo cp libOdbcFb.so /usr/lib/x86_64-linux-gnu/odbc/
  sudo ln -s /usr/lib/x86_64-linux-gnu/odbc/libfbclient.so.2 /usr/lib/x86_64-linux-gnu/odbc/libgds.so
  cat <<EOF >> ./firebird.ini
[Firebird] 
Description = InterBase/Firebird ODBC Driver 
Driver = libOdbcFb.so 
Setup = libOdbcFbS.so 
Threading = 2
FileUsage = 1
EOF
  sudo odbcinst -i -d -f ./firebird.ini
}

PRODUCTFULLNAME="Devart ODBC Driver for Firebird"
DBMSNAME="firebird"
PRODUCTVERSION="2.1.5"
DEFPATH="/usr/lib/x86_64-linux-gnu/"
DEFDIR="devart/odbc"$DBMSNAME
DEFIODBCINIUNIX="/etc/"
DEFIODBCINIMAC="/Library/ODBC/"

download_and_install_devart_firebird_driver()
{  
  mkdir -p ./devart-driver
  cd devart-driver
  wget 'https://www.devart.com/odbc/firebird/devartodbcfirebird-linux.tar'
  tar -xf devartodbcfirebird-linux.tar

  Expr="so"
  path="$DEFPATH$DEFDIR"
  sudo mkdir -p $path
  
  sudo cp "libdevartodbc"$DBMSNAME"."$PRODUCTVERSION".x86."$Expr $path
  sudo ln -s -f $path"/libdevartodbc"$DBMSNAME"."$PRODUCTVERSION".x86."$Expr "/usr/lib/x86_64-linux-gnu/odbc/libdevartodbc"$DBMSNAME".x86".$Expr
  sudo cp $DBMSNAME"odbcsetup_x86" $path
  sudo cp "libdevartodbc"$DBMSNAME"."$PRODUCTVERSION".x64."$Expr $path
  sudo ln -s -f $path"/libdevartodbc"$DBMSNAME"."$PRODUCTVERSION".x64."$Expr "/usr/lib/x86_64-linux-gnu/odbc/libdevartodbc"$DBMSNAME".x64."$Expr
  sudo cp $DBMSNAME"odbcsetup_x64" $path
  sudo cp license.txt $path
  sudo cp history.html $path
  # sudo cp "devartodbc"$DBMSNAME".pdf" $path
  # DRIVER_PATH=$path
  # export DRIVER_PATH
  # export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DRIVER_PATH
  # echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib:/usr/lib:/usr/local/lib' >> ~/.profile
  pathodbc=$DEFIODBCINIUNIX
  lic="TRIAL"
  sudo $path"/"$DBMSNAME"odbcsetup_x86" $lic $pathodbc "/usr/lib/x86_64-linux-gnu/odbc/libdevartodbc"$DBMSNAME".x86."$Expr x86
  sudo rm -f $path"/"$DBMSNAME"odbcsetup_x86"
  sudo $path"/"$DBMSNAME"odbcsetup_x64" $lic $pathodbc "/usr/lib/x86_64-linux-gnu/odbc/libdevartodbc"$DBMSNAME".x64."$Expr x64
  sudo rm -f $path"/"$DBMSNAME"odbcsetup_x64"

  # library=$(ls | grep .x64.so)
  # echo $library
  # sudo cp $library /usr/lib/x86_64-linux-gnu/odbc/
  #
  # lic="TRIAL"
  # pathodbc="/etc/"
  # sudo ./firebirdodbcsetup_x64 $lic $pathodbc "/usr/lib/x86_64-linux-gnu/odbc/"$library x64
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
