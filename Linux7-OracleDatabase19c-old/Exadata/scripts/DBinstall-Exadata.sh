#!/bin/bash

echo "--------------------------------------------------"
echo 'INSTALLER: Started up'
echo "--------------------------------------------------"

#set environment variables in .bashrc
#export ORACLE_BASE=$1
export ORACLE_HOME=$1
export LD_LIBRARY_PATH=$1/lib
export CDBNAME=$2
export ORACLE_SID=$3
export PDB_NAME=$4
export PDBNUMBER=$5
export ORACLE_PWD=$6


#environment variables used in dbca
export CONFIGTYPE=RAC
export CONTAINERIZE=true
export ASM_LOCATION_DATA=+DATA
export ASM_LOCATION_ARCH=+ARCH
export STORAGETYPE=ASM

#Location where files are unzipped
export ORA_LOCATION=/tmp

echo "--------------------------------------------------"
echo "INSTALLER: Setting Environment Variables for Oracle completed"
echo "--------------------------------------------------"

cp ${ORA_LOCATION}/ora-response/dbca.rsp.tmpl ${ORA_LOCATION}/ora-response/dbca.rsp
sed -i -e "s|###CDBNAME###|$CDBNAME|g" ${ORA_LOCATION}/ora-response/dbca.rsp && \
sed -i -e "s|###ORACLE_SID###|$ORACLE_SID|g" ${ORA_LOCATION}/ora-response/dbca.rsp && \
sed -i -e "s|###CONFIGTYPE###|$CONFIGTYPE|g" ${ORA_LOCATION}/ora-response/dbca.rsp && \
sed -i -e "s|###CONTAINERIZE###|$CONTAINERIZE|g" ${ORA_LOCATION}/ora-response/dbca.rsp && \
sed -i -e "s|###PDBNUMBER###|$PDBNUMBER|g" ${ORA_LOCATION}/ora-response/dbca.rsp && \
sed -i -e "s|###PDB_NAME###|$PDB_NAME|g" ${ORA_LOCATION}/ora-response/dbca.rsp && \
sed -i -e "s|###ORACLE_PWD###|$ORACLE_PWD|g" ${ORA_LOCATION}/ora-response/dbca.rsp && \
sed -i -e "s|###ASM_LOCATION_DATA###|$ASM_LOCATION_DATA|g" ${ORA_LOCATION}/ora-response/dbca.rsp && \
sed -i -e "s|###ASM_LOCATION_ARCH###|$ASM_LOCATION_ARCH|g" ${ORA_LOCATION}/ora-response/dbca.rsp && \
sed -i -e "s|###STORAGETYPE###|$STORAGETYPE|g" ${ORA_LOCATION}/ora-response/dbca.rsp
#sed -i -e "s|###ORACLE_BASE###|$ORACLE_BASE|g" ${ORA_LOCATION}/ora-response/dbca.rsp

su -l oracle -c "yes | $ORACLE_HOME/bin/dbca -silent -createDatabase -responseFile ${ORA_LOCATION}/ora-response/dbca.rsp"
rm -f ${ORA_LOCATION}/ora-response/dbca.rsp

echo "--------------------------------------------------"
echo " INSTALLER: Database Created                      "
echo "--------------------------------------------------"

echo "--------------------------------------------------"
echo 'INSTALLER: Done'
echo "--------------------------------------------------"
