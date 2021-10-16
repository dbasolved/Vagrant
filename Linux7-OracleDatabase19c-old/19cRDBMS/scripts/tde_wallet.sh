#!/bin/sh

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.3.0/dbhome_1
export WALLET_LOCATION=$1

#create wallet directory
#mkdir ${WALLET_LOCATION} already created

#connect to database and configure TDE
${ORACLE_HOME}/bin/sqlplus / as sysdba << EOF

spool tde_and_security_settings.log append

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

CREATE OR REPLACE FUNCTION SYS.VERIFY_PASSWORD_12c
(username varchar2,
  password varchar2,
  old_password varchar2)
  RETURN boolean IS
   n boolean;
   pwLen integer;
   m integer;
   differ integer:= 0;
   isdigit boolean;
   ischar  boolean;
   ispunct boolean;
   db_name varchar2(40);
   digitarray varchar2(20);
   punctarray varchar2(25);
   chararray varchar2(52);
   upperarray varchar2(26);
   lowerarray varchar2(26);
   i_char varchar2(10);
   simple_password varchar2(10);
   reverse_user varchar2(32);

BEGIN
   digitarray:= '0123456789';
   chararray:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
   punctarray:='!"#$%&()``*+,-/:;<=>?_';
   upperarray:= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
   lowerarray:= 'abcdefghijklmnopqrstuvwxyz';

   -- Check for the minimum length of the password
   IF length(password) < 12 THEN
      raise_application_error(-20001, 'Password length is less than 12 characters');
   END IF;

   -- Check if the password is same as the username or username(1-100)
   IF NLS_LOWER(password) = NLS_LOWER(username) THEN
     raise_application_error(-20002, 'Password same as or similar to user');
   END IF;
   FOR i IN 1..100 LOOP
      i_char := to_char(i);
      if NLS_LOWER(username)|| i_char = NLS_LOWER(password) THEN
        raise_application_error(-20003, 'Password same as or similar to user name ');
      END IF;
    END LOOP;

   -- Check if the password is same as the username reversed
   FOR i in REVERSE 1..length(username) LOOP
     reverse_user := reverse_user || substr(username, i, 1);
   END LOOP;
   IF NLS_LOWER(password) = NLS_LOWER(reverse_user) THEN
     raise_application_error(-20004, 'Password same as username reversed');
   END IF;

   --Check if maximum length is less than 64
   IF length(password) > 64 THEN
    raise_application_error(-20005, 'Password length must be no more than 64 characters');
    END IF;

   -- Check if the password is the same as server name and or servername(1-100)
   select name into db_name from sys.v$database;
   if NLS_LOWER(db_name) = NLS_LOWER(password) THEN
      raise_application_error(-20006, 'Password same as or similar to server name');
   END IF;
   FOR i IN 1..100 LOOP
      i_char := to_char(i);
      if NLS_LOWER(db_name)|| i_char = NLS_LOWER(password) THEN
        raise_application_error(-20007, 'Password same as or similar to server name ');
      END IF;
    END LOOP;

   -- Check if the password contains at least one letter, one upper letter, one lower letter, one digit, one punctuation
   -- 1. Check for the digit
   isdigit:=FALSE;
   m := length(password);
   FOR i IN 1..10 LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(digitarray,i,1) THEN
            isdigit:=TRUE;
             GOTO findchar;
         END IF;
      END LOOP;
   END LOOP;

   IF isdigit = FALSE THEN
      raise_application_error(-20008, 'Password must contain at least one digit');
   END IF;

   -- 2. Check for the letter
   <<findchar>>
   ischar:=FALSE;
   FOR i IN 1..length(chararray) LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(chararray,i,1) THEN
            ischar:=TRUE;
             GOTO findpunct;
         END IF;
      END LOOP;
   END LOOP;
   IF ischar = FALSE THEN
      raise_application_error(-20009, 'Password must contain at least one letter');
   END IF;

   --3. Check for the punctuation
   <<findpunct>>
   ispunct:=FALSE;
   FOR i IN 1..length(punctarray) LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(punctarray,i,1) THEN
            ispunct:=TRUE;
             GOTO findupper;
         END IF;
      END LOOP;
   END LOOP;
   IF ispunct = FALSE THEN
      raise_application_error(-20010, 'Password should contain at least one punctuation');
   END IF;

   --4. Check for the Uppercase letter
   <<findupper>>
   ischar:=FALSE;
   FOR i IN 1..length(upperarray) LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1)= substr(upperarray,i,1) THEN
            ischar:=TRUE;
             GOTO findlower;
         END IF;
      END LOOP;
   END LOOP;
   IF ischar = FALSE THEN
      raise_application_error(-20011, 'Password must contain at least one UPPER CASE letter');
   END IF;

--5. Check for the lowercase letter

<<findlower>> 
   ischar:=FALSE;
   FOR i IN 1..length(lowerarray) LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1)= substr(lowerarray,i,1) THEN
            ischar:=TRUE;
             GOTO endsearch;
         END IF;
      END LOOP;
   END LOOP;

   IF ischar = FALSE THEN
      raise_application_error(-20012, 'Password must contain at least one LOWER CASE letter');
   END IF;

<<endsearch>>


--Check if the password differs from the previous 
	-- password by at least 8 characters
	IF username = USER THEN
		pwLen := length(password);
		FOR i IN 1..pwLen LOOP
			IF substr(password,i,1) != substr(old_password,i,1) THEN
				differ := differ + 1;
			END IF;
		END LOOP;
		IF differ < 8 THEN
			raise_application_error(-20013, 
				'Password should differ by at least 8 characters');
		END IF;
	END IF;


   -- Everything is fine; return TRUE ;
   RETURN(TRUE);

END;
/

spool off;

exit
EOF
