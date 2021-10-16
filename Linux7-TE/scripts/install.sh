#!/bin/bash

echo "--------------------------------------------------"
echo 'INSTALLER: Started up'
echo "--------------------------------------------------"

#yum-config-manager --disable ol7_UEKR5

#fix locale
echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.utf-8 >> /etc/environment

echo "--------------------------------------------------"
echo 'INSTALLER: Locale Fixed'
echo "--------------------------------------------------"

#install prereqs and openssl
yum -y -q reinstall glibc-common
yum -y -q install oracle-database-preinstall-19c openssl


echo "--------------------------------------------------"
echo 'INSTALLER: Oracle database preinstall and openssl installed'
echo "--------------------------------------------------"
#adding server desktop and vncserver
yum -y -q install xterm

echo "--------------------------------------------------"
echo 'INSTALLER: GUI desktop and VNC Server installed'
echo "--------------------------------------------------"

#remove yum cache
rm -rf /var/cache/yum

echo "--------------------------------------------------"
echo 'INSTALLER: Done'
echo "--------------------------------------------------"
