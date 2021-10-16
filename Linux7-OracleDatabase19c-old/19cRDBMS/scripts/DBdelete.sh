#!/bin/bash

Usage()
{
    # Display Help
    echo "---------------------------------------------------------------------------------------------"
    echo "DBdelete.sh Usage Information"
    echo 
    echo "Note: This script should be ran on node 1 of an Oracle RAC system"
    echo
    echo "Syntax:"
    echo "DBdelete.sh \$1 \$2 \$3"
    echo 
    echo "\$1  : Oracle SID"
    echo "\$2  : SYSDBA Username"
    echo "\$3  : SYSDBA Password"
    echo
    echo "-h   : Display this help message"
    echo
    echo
    echo "Example:"
    echo "\$ sh ./DBdelete.sh orcl sys Welcome1"
    echo 
    echo "--------------------------------------------------------------------------------------------"
}

    #Standard Items - Update as needed
    export ORA_INVENTORY=/u01/app/oraInventory
    export ORACLE_BASE=/u01/app/oracle
    export ORACLE_HOME=/u01/app/oracle/product/19.3.0/dbhome_1

    export ORACLE_NAME=$1
    export ORACLE_SID=$1
    export SYSDBA_USER=$2
    export SYSDBA_PWD=$3

if [ $# -ne 3 ] || [ $1 == "-h" ];
then
    echo
    echo "You must enter exactly three (3) command line arguments"
    echo
    Usage
    exit 0
else

    export ORACLE_NAME=${ORACLE_NAME}
    export ORACLE_SID=${ORACLE_SID}
    export SYSDBA_USER=${SYSDBA_USER}
    export SYSDBA_PWD=${SYSDBA_PWD}

    ${ORACLE_HOME}/bin/dbca -silent -deleteDatabase -sysDBAUserName ${SYSDBA_USER} -sysDBAPassword ${SYSDBA_PWD} -sid ${ORACLE_SID} -sourceDB ${ORACLE_NAME}

    exit 0
fi

