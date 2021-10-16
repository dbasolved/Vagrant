#!/bin/bash

#yum update -y
#cp /vagrant/software/postgresql12-server-12.4-1PGDG.rhel7.x86_64.rpm /tmp
#rpm -qpR /tmp/postgresql12-server-12.4-1PGDG.rhel7.x86_64.rpm | awk '{print $1}' | sort -u | xargs yum -y install
#rpm -qpR /tmp/postgresql12-server-12.4-1PGDG.rhel7.x86_64.rpm

sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum install -y postgresql13-server
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
sudo systemctl enable postgresql-13
sudo systemctl start postgresql-13