/* Copyright (c) 2017, 2020, Oracle and/or its affiliates. 
All rights reserved.*/

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

drop table gghc_flags_tab;
drop table gghc_summary_tab;
drop sequence gghc_summary_id;
drop table gghc_snapshot_tab;
drop table gghc_params_tab;
drop function gghc_delta_time ; 
drop table gghc_stats_tab;
drop table gghc_files;
drop type GGHC_JSONFmtCtx force;
drop type GGHC_JSON2FmtCtx force;
drop type GGHC_HTMLFmtCtx force;
drop type GGHC_JSFmtCtx force;
drop type GGHC_HCJSONFmtCtx force;
drop type GGHC_StatsFmtctx force;
drop type GGHC_JSONObj force;

drop package dbms_goldengate_hcadm_int;
drop package dbms_goldengate_hcadm;
drop package dbms_goldengate_hc;

drop type gghc_rows force;
drop type gghc_row force;
drop type gghc_cols force;
drop type gghc_heartbeat_rows force;
drop type gghc_heartbeat_row force;
