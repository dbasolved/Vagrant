#!/bin/bash

export LIQUIBASE_HOME=/opt/app/liquibase/
export LIQUIBASE_TAR=liquibase-4.3.1.tar
export PATH=$LIQUIBASE_HOME:$PATH

#Adding Liquid User
useradd -d /home/liquid -s /bin/bash liquid
echo "base123" | passwd liquid --stdin

yum -y -q install java

mkdir -p ${LIQUIBASE_HOME}

cp /Test_Software/${LIQUIBASE_TAR} ${LIQUIBASE_HOME}

chown liquid:liquid -R ${LIQUIBASE_HOME}

#Setting Environment Variables
echo "export PATH=${LIQUIBASE_HOME}:$PATH" >> /home/liquid/.bash_profile

su -l liquid -c "yes | tar -xvf ${LIQUIBASE_HOME}/${LIQUIBASE_TAR}"

echo
echo 'Done!'
echo