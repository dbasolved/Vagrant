#!/bin/sh

Usage()
{
    # Display Help
    echo "---------------------------------------------------------------------------------------------"
    echo "DBinstall.sh Usage Information"
    echo
    echo "Note: This script should be ran on node 1 of an Oracle RAC system"
    echo
    echo "Syntax:"
    echo "DBinstall.sh \$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8"
    echo
    echo "\$1  : Database Name"
    echo "\$2  : Database Domain Name"
    echo "\$3  : Installation Type - Single Instance (SI) or Real Application Cluster (RAC)"
    echo "\$4  : Storage Type - File system (FS) or Automatic Storage Management (ASM)"
    echo "\$5  : CDB or Non-CDB Build - Boolean - true || false"
    echo "\$6  : Number of Pluggable Database (PDB) to build - resulting PDBs will be enumerated"
    echo "\$7  : Pluggable Database Name"
    echo "\$8  : Default Password to use"
    echo "\$9  : RAC Node List (format: node_name,node_name) - optional - only needed if \$3 is RAC"
    echo
    echo "-h   : Display this help message"
    echo
    echo
    echo "Example:"
    echo "\$ sh ./DBinstall.sh db rheodata.com SI FS true 1 dbtst Welcome1"
    echo
    echo "\$ sh ./DBinstall.sh db rheodata.com RAC ASM true 1 dbtst Welcome1 node1,node2,node3"
    echo
    echo "--------------------------------------------------------------------------------------------"
}

#Standard Items - Update as needed
export ORA_INVENTORY=/u01/app/oraInventory
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.3.0/dbhome_1
export DATA_DIR=+DATA1 ## modified
export FRA_DIR=+DATA1  ## modified
export WALLET_LOCATION=/u01/app/oracle/wallet/tde  ## modified
export WALLET_ROOT=/u01/app/oracle/wallet  ## modified

#Standard Settings - Do not change
export ORACLE_EDITION=EE
export DB_VERSION=ORA19c
export ORACLE_CHARACTERSET=AL32UTF8

#Variables being passed
export ORACLE_NAME=$1
export ORACLE_SID=$1
export DB_DOMAIN=$2
export ORACLE_TYPE=$3
export STORAGETYPE=$4
export CDBBOOLEN=$5
export PDBNUMBER=$6
export PDB_NAME=$7
export ORACLE_PWD=$8

if [ $# -ne 8 ] || [ $1 == "-h" ];
then
    echo
    echo "You must enter exactly eight (8) command line arguments"
    echo
    Usage
    exit 0
else

    if [ $3 == "SI" ]
    then

        #Change as needed to build desired database (CDB/PDB)
        #
        #Notes
        #If the database does not come up, then the environment variable (ORACLE_SID) needs to be chnaged to match what this script builds.
        #
        #
        export ORACLE_NAME=${ORACLE_NAME}
        export ORACLE_SID=${ORACLE_SID}
        export DB_DOMAIN=${DB_DOMAIN}
        export ORACLE_TYPE=${ORACLE_TYPE}
        export CDBBOOLEN=${CDBBOOLEN}
        export PDBNUMBER=${PDBNUMBER}
        export PDB_NAME=${PDB_NAME}
        export DATA_DIR=${DATA_DIR}
        export FRA_DIR=${FRA_DIR}
        export STORAGETYPE=${STORAGETYPE}
        export WALLET_LOCATION=${WALLET_LOCATION}
        export WALLET_ROOT=${WALLET_ROOT}

        echo "--------------------------------------------------"
        echo "INSTALLER: Started up                             "
        echo "--------------------------------------------------"

        mkdir -p $WALLET_ROOT/tde

        cp /tmp/SETUP/ora-response/dbca.rsp.tmpl /tmp/SETUP/ora-response/dbca.rsp
        sed -i -e "s|###ORACLE_NAME###|$ORACLE_NAME|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###ORACLE_SID###|$ORACLE_SID|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###ORACLE_TYPE###|$ORACLE_TYPE|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###CDBBOOLEN###|$CDBBOOLEN|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###PDBNUMBER###|$PDBNUMBER|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###PDB_NAME###|$PDB_NAME|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###ORACLE_PWD###|$ORACLE_PWD|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###DATA_DIR###|$DATA_DIR|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###FRA_DIR###|$FRA_DIR|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###STORAGETYPE###|$STORAGETYPE|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###ORACLE_BASE###|$ORACLE_BASE|g" /tmp/SETUP/ora-response/dbca.rsp
        sed -i -e "s|###WALLET_ROOT###|$WALLET_ROOT|g" /tmp/SETUP/ora-response/dbca.rsp

        $ORACLE_HOME/bin/dbca -silent -createDatabase -responseFile /tmp/SETUP/ora-response/dbca.rsp
        rm -f /tmp/SETUP/ora-response/dbca.rsp

        echo "---------------------------------------------------------"
        echo " INSTALLER: Database Created                             "
        echo "---------------------------------------------------------"

        #Used to ensure database will come up.
        export ORACLE_SID=${ORACLE_SID}

        echo "---------------------------------------------------------"
        echo " INSTALLER: Enabling Archive Logging                     "
        echo "---------------------------------------------------------"

        sh ./archivelog_force.sh

        echo "---------------------------------------------------------"
        echo " INSTALLER: DONE - Enabling Archive Logging              "
        echo "---------------------------------------------------------"

        echo "---------------------------------------------------------"
        echo " INSTALLER: Enabling Transparent Data Encryption         "
        echo "---------------------------------------------------------"

        sh ./tde_wallet.sh $WALLET_LOCATION

        echo "---------------------------------------------------------"
        echo " INSTALLER: DONE - Enabling Transparent Data Encryption  "
        echo "---------------------------------------------------------"

        echo "---------------------------------------------------------"
        echo "INSTALLER: DONE                                          "
        echo "---------------------------------------------------------"

        exit 0

    elif [ $3 == "RAC" ]
    then

        #Change as needed to build desired database (CDB/PDB)
        #
        #Notes
        #If the database does not come up, then the environment variable (ORACLE_SID) needs to be chnaged to match what this script builds.
        #
        #
        export ORACLE_NAME=${ORACLE_NAME}
        export ORACLE_SID=${ORACLE_SID}
        export ORACLE_UNIQUE_NAME=${ORACLE_SID}1  ## modified
        export NODE_LIST=$9
        export DB_DOMAIN=${DB_DOMAIN}
        export ORACLE_TYPE=${ORACLE_TYPE}
        export CDBBOOLEN=${CDBBOOLEN}
        export PDBNUMBER=${PDBNUMBER}
        export PDB_NAME=${PDB_NAME}
        export DATA_DIR=${DATA_DIR}     ## modified
        export FRA_DIR=${FRA_DIR}       ## modified
        export STORAGETYPE=${STORAGETYPE}
        export WALLET_LOCATION=${WALLET_LOCATION}
        export WALLET_ROOT=${WALLET_ROOT}

        echo "--------------------------------------------------"
        echo "INSTALLER: Starting up RAC DB build               "
        echo "--------------------------------------------------"

        mkdir -p $WALLET_ROOT/tde

        cp /tmp/SETUP/ora-response/dbca_rac.rsp.tmpl /tmp/SETUP/ora-response/dbca.rsp
        sed -i -e "s|###ORACLE_NAME###|$ORACLE_NAME|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###ORACLE_SID###|$ORACLE_SID|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###ORACLE_TYPE###|$ORACLE_TYPE|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###CDBBOOLEN###|$CDBBOOLEN|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###NODE_LIST###|$NODE_LIST|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###PDBNUMBER###|$PDBNUMBER|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###PDB_NAME###|$PDB_NAME|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###ORACLE_PWD###|$ORACLE_PWD|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###DATA_DIR###|$DATA_DIR|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###FRA_DIR###|$FRA_DIR|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###STORAGETYPE###|$STORAGETYPE|g" /tmp/SETUP/ora-response/dbca.rsp && \
        sed -i -e "s|###ORACLE_BASE###|$ORACLE_BASE|g" /tmp/SETUP/ora-response/dbca.rsp
        sed -i -e "s|###WALLET_ROOT###|$WALLET_ROOT|g" /tmp/SETUP/ora-response/dbca.rsp

        $ORACLE_HOME/bin/dbca -silent -createDatabase -responseFile /tmp/SETUP/ora-response/dbca.rsp
        rm -f /tmp/SETUP/ora-response/dbca.rsp

        echo "---------------------------------------------------------"
        echo " INSTALLER: Database Created                             "
        echo "---------------------------------------------------------"

        #Used to ensure database will come up.
        export ORACLE_SID=${ORACLE_UNIQUE_NAME}

        echo "---------------------------------------------------------"
        echo " INSTALLER: Enabling Archive Logging                     "
        echo "---------------------------------------------------------"

        #Enable archive Logging
        sh ./archivelog_force.sh

        echo "---------------------------------------------------------"
        echo " INSTALLER: DONE - Enabling Archive Logging              "
        echo "---------------------------------------------------------"

        echo "---------------------------------------------------------"
        echo " INSTALLER: Enabling Transparent Data Encryption         "
        echo "---------------------------------------------------------"

        sh ./tde_wallet.sh $WALLET_LOCATION

        echo "---------------------------------------------------------"
        echo " INSTALLER: DONE - Enabling Transparent Data Encryption  "
        echo "---------------------------------------------------------"

        echo "---------------------------------------------------------"
        echo " RESTARTING THE RAC DATABASE                             "
        echo "---------------------------------------------------------"

        srvctl stop db -d ${ORACLE_NAME}; sleep 5; srvctl start db -d ${ORACLE_NAME}; srvctl status db -d ${ORACLE_NAME}

        echo "---------------------------------------------------------"
        echo "INSTALLER: DONE                                          "
        echo "---------------------------------------------------------"

        exit 0

    else
        echo "---------------------------------------------------------"
        echo "Did not select the correct Oracle Database Type          "
        echo "Avaliable Options are:"
        echo "SI - Single Instance"
        echo "RAC - Real Application Cluster"
        echo

        exit 0

        echo
        echo "---------------------------------------------------------"
    fi #end SI/RAC statement
fi #end top level if statement
