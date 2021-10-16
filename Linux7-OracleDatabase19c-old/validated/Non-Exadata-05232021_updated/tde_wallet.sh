#!/bin/sh

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.3.0/dbhome_1
export WALLET_LOCATION=$1

#create wallet directory
#mkdir ${WALLET_LOCATION} already created

#connect to database and configure TDE
${ORACLE_HOME}/bin/sqlplus / as sysdba << EOF

set linesize 175
col wrl_parameter format a50 wrap

alter pluggable database all open;

administer key management create keystore '$WALLET_LOCATION' identified by welcome1;

administer key management set keystore open identified by welcome1 container=all;

administer key management set key identified by welcome1 with backup container=all;

select wrl_type, wrl_parameter, status, con_id from v\$encryption_wallet;

administer key management create auto_login keystore from keystore '$WALLET_LOCATION' identified by welcome1;

alter pluggable database all save state;

select key_id FROM v\$encryption_keys;

select wrl_type, wrl_parameter, status, con_id from v\$encryption_wallet;

exit
EOF
