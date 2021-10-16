#!/bin/bash

echo "--------------------------------------------------"
echo 'INSTALLER: Started up'
echo "--------------------------------------------------"

#fix locale
echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.utf-8 >> /etc/environment

echo "--------------------------------------------------"
echo 'INSTALLER: Locale Fixed'
echo "--------------------------------------------------"

#install prereqs and openssl
yum -y -q reinstall glibc-common
yum -y -q install openssl

echo "--------------------------------------------------"
echo 'INSTALLER: Oracle database preinstall and openssl installed'
echo "--------------------------------------------------"

echo "--------------------------------------------------"
echo 'INSTALLER: Done'
echo "--------------------------------------------------"
