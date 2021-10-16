/* Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.*/


set pages 0
set heading off
set lines 2500
set trimspool on
set trimout on
set long 10000000
set longchunksize 10000000

set verify off

column file_name     new_value 1 noprint;
column output_format new_value 2 noprint;
column module_name   new_value module_name noprint;

set termout off
select null file_name, null output_format from dual where 1=2;

select nvl('&1', 'gghc_'||sys_context('userenv','db_name')||'_'||
       to_char(sysdate,'YYYYMMDDHH24MI')||'.html') file_name ,
       nvl('&2', 3) output_format
from dual ;

set termout on


select 'GGSTAT_%_'||sys_context('userenv','sid') module_name from dual;

prompt
prompt +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
prompt +
prompt +    Running GoldenGate Healthcheck
prompt +    Report file                     : &1
prompt +    Report format                   : &2
prompt +
prompt +    This report might take a while to complete. 
prompt +    Please check its progress by executing the following query in a 
prompt +    different sqlplus session
prompt +
prompt +    SELECT MODULE,ACTION FROM V$SESSION WHERE MODULE LIKE '&module_name'
prompt +
prompt +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
prompt

spool &1
select dbms_goldengate_hcadm.health_check 
       ( format => &2,
         exclude_tags    => 'HC_CLASSIC,HC_CLASSIC_FULL') 
  from dual;

spool off
exit

