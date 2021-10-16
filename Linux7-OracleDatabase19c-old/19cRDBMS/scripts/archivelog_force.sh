#!/bin/sh

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.3.0/dbhome_1

srvctl stop db -d ${ORACLE_NAME}

#connect to database and configure TDE
${ORACLE_HOME}/bin/sqlplus / as sysdba << EOF

spool archive_log_and_java_settings.log append

STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ARCHIVE LOG LIST;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
ALTER DATABASE FORCE LOGGING;
ALTER SYSTEM SWITCH LOGFILE;

begin
 DBMS_JAVA.DISABLE_PERMISSION(45);
 DBMS_java.delete_permission(45);
 commit;
END;
/

begin
 DBMS_JAVA.DISABLE_PERMISSION(39);
 DBMS_java.delete_permission(39);
 commit;
END;
/

SHUTDOWN IMMEDIATE;
STARTUP;

spool off;

exit

EOF
