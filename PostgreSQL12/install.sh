#!/bin/bash

#yum update -y
#cp /vagrant/software/postgresql12-server-12.4-1PGDG.rhel7.x86_64.rpm /tmp
#rpm -qpR /tmp/postgresql12-server-12.4-1PGDG.rhel7.x86_64.rpm | awk '{print $1}' | sort -u | xargs yum -y install
#rpm -qpR /tmp/postgresql12-server-12.4-1PGDG.rhel7.x86_64.rpm

yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
#yum install -y -q postgresql12-server
#su -l root -c /usr/pgsql-12/bin/postgresql-12-setup initdb
#su -l root -c systemctl enable postgresql-12
#su -l root -c systemctl start postgresql-12