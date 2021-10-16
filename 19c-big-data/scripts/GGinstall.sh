#!/bin/bash

echo "--------------------------------------------------"
echo 'INSTALLER: Started up'
echo "--------------------------------------------------"
echo
echo

#fix locale
echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.utf-8 >> /etc/environment

echo "--------------------------------------------------"
echo 'INSTALLER: Locale Fixed'
echo "--------------------------------------------------"
echo
echo

#install prereqs and openssl
yum -y -q reinstall glibc-common
yum -y -q install oracle-database-preinstall-19c openssl

echo
echo '###################################'
echo  'Installing Oracle Instanct Client 19.8.0.0'
echo '###################################'
echo
echo

yum -y -q install oracle-release-el7
yum -y -q install oracle-instantclient19.8-basic.x86_64
yum -y -q install oracle-instantclient19.8-devel.x86_64
yum -y -q install oracle-instantclient19.8-tools.x86_64
yum -y -q install oracle-instantclient19.8-sqlplus.x86_64
yum -y -q install java

rpm -qa | grep java

echo "--------------------------------------------------"
echo 'INSTALLER: Oracle database preinstall and instant client installed'
echo "--------------------------------------------------"
echo
echo

#adding server desktop and vncserver
yum -y -q install xterm
yum -y -q install tightvnc-server
cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
sed -i -e "s|<USER>|oracle|g" /etc/systemd/system/vncserver@:1.service

echo "--------------------------------------------------"
echo 'INSTALLER: GUI desktop and VNC Server installed'
echo "--------------------------------------------------"
echo
echo

#create directories
mkdir -pv $ORACLE_BASE && \
#mkdir -pv $ORACLE_HOME && \
mkdir -pv $ORA_INVENTORY && \
mkdir -pv $TNS_ADMIN && \
mkdir -pv $OGG_HOME

#set permissions (abit of overkill)
chown oracle:oinstall -R $ORACLE_BASE
#chown oracle:oinstall -R $ORACLE_HOME
chown oracle:oinstall -R $ORA_INVENTORY
chown oracle:oinstall -R $TNS_ADMIN
chown oracle:oinstall -R $OGG_HOME

echo "--------------------------------------------------"
echo 'INSTALLER: Required Oracle directories created'
echo "--------------------------------------------------"
echo
echo

#set environment variables in .bashrc
echo "export ORACLE_BASE=$ORACLE_BASE" >> /home/oracle/.bashrc && \
echo "export ORACLE_HOME=$ORACLE_HOME" >> /home/oracle/.bashrc && \
echo "export TNS_ADMIN=$TNS_ADMIN" >> /home/oracle/.bashrc && \
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> /home/oracle/.bashrc && \
echo "export OGG_HOME=$OGG_HOME" >> /home/oracle/.bashrc && \
echo "export PATH=\$PATH:\$ORACLE_HOME/bin:\$LD_LIBRARY_PATH:\$OGG_HOME" >> /home/oracle/.bashrc

echo "--------------------------------------------------"
echo "INSTALLER: Setting Environment Variables for Oracle completed"
echo "--------------------------------------------------"
echo
echo

#unzip software and configure database
#unzip -q -o -j /Test_Software/${CLIENT_SHIPHOME_19C} -d ${ORACLE_HOME_19C_LIB}

echo "--------------------------------------------------"
echo "INSTALLER: Oracle Database Client 19c installed   "
echo "--------------------------------------------------"
echo
echo

#configure GoldenGate
unzip -q -o /Test_Software/${OGG_SHIPHOME} -d /vagrant/oggbd
chmod -R 777 /vagrant/oggbd
cp /vagrant/oggbd/OGG_BigData_Linux_x64_19.1.0.0.5.tar ${OGG_HOME}
cd ${OGG_HOME}
tar -xvf ${OGG_HOME}/OGG_BigData_Linux_x64_19.1.0.0.5.tar

echo "--------------------------------------------------"
echo " INSTALLER: Oracle GoldenGate 19c Big Data Installed                  "
echo "--------------------------------------------------"
echo
echo

#remove yum cache
rm -rf /var/cache/yum

echo "--------------------------------------------------"
echo 'INSTALLER: Done'
echo "--------------------------------------------------"

echo "--------------------------------------------------"
echo "Please set the JAVA_HOME and the LID_LIBRARY_PATH correctly"
echo "--------------------------------------------------"