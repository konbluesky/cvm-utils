#!/usr/bin/env bash
set -e

if [ -z $1 ]; then
  echo 'Please Input  Port, Username, Password'
  echo '********************************************************************************'
  echo 'Format ./proxy.sh port username password'
  echo 'prot        Port '
  echo 'username    Username '
  echo 'password    Password'
  echo '********************************************************************************'
  exit
fi
if [ -z $2 ]; then
  echo 'Please Input Username'
  exit
fi
if [ -z $3 ]; then
  echo 'Please Input Password'
  exit
fi

wget http://ftp.barfooze.de/pub/sabotage/tarballs/microsocks-1.0.3.tar.xz
tar -xf microsocks-1.0.3.tar.xz && cd microsocks-1.0.3 && sudo apt install -y gcc make && make && sudo make install
nohup sudo microsocks -1 -i 0.0.0.0 -p $1 -u $2 -P $3 &

