/* Copyright (c) 2017, 2020, Oracle and/or its affiliates. 
All rights reserved.*/

Introduction
============
   The contents of the new healthcheck is almost the same as the old
   healthcheck report. 

   The presentation of the information has changed. The new healthcheck 
   script can be
     - Used across different DB, versions greater than 11.2.0.3.0 
     - Used to install as sys and non-sys users 
          (Non-Sys users require 'SELECT ANY DICTIONARY' privilege and 
          dbms_goldengate_adm.grant_admin_privilege )
     - Run in full or in part depending on the need and frequency.
     - Generate output in different formats (JSON, javascript/HTML)

  This healthcheck consists of a number of 'Stats', each one of them having 
  many attributes.
  
  Each 'stat' has the following attributes

  ID - Unique id of the stat.
  Short Description - Short description about the stat e.g 'Capture Status'
  Detail Description - Detailed description about the stat if the info
                       provided by stat is not staight forward. 
                       This is optional attribute.
  Hint - Hint that may give corrective action based on the query 
         output of the stat. This is optional attribute.
  Query - The actual query that is executed to get the data for the stat.
  Tags - Each stat may have a number of tags associated with them.
         e.g CAPTURE, APPLY, DATABASE etc.

  Only a few attributes are directly visible in the generated healthcheck
  report. The 'Query' attribute is not available in the report, but can be
  obtained through a pl/sql function call described further below.

Installation and Use
====================

  The healthcheck script consists of three parts

  Part1 - ogghc_install.sql

  This is the installation script that installs the necessary tables and 
  packages needed to generate the healthcheck report. It can be installed 
  on sys or any other user having 'SELECT ANY DICTIONARY' privilege.
  However, when installing as non-sys users some of the stats may not be 
  available as they select from x$ views and other sys-access-only tables.

  Part2 - ogghc_run.sql

  This script should be used to generate the report. It spools the output to
  gghc_<instance_name>_YYYYMMDDHH24MI.html. The default output is javascript
  based html output. It can be changed to output in JSON

  Part3 - ogghc_uninstall.sql

  The objects created by ogghc_install.sql can be removed cleanly using 
  this script. 

  The general usage would be to run ogghc_install.sql, once as a preferred
  user, then run ogghc_run.sql as the same user everytime the
  healthcheck needs to be generated.


dbms_goldengate_hcadm
=====================

  This package contains functions and procedures that control the
  generated healthcheck report.

  The main function that generates the healthcheck is the following function in
  dbms_goldengate_hcadm

===============================================================================
    health_check(
      exclude_stats varchar2 default null,
      format number default 3,
      tags varchar2 default 'HC'
      exclude_tags varchar2 default null,
    ) return clob;

    Returns the generated healthcheck report as a clob.

    exclude_stats : comma separated list of stat id that are to be excluded
    from the report if any. If not specified, all the enabled stats having the
    tag in 'tags' would be included in the report.

    format:  Defines the output format. 2 - simple HTML, 3 - Javascript HTML, 
    4 -JSON. Defaults to 3.

    tags: Comma separated list of tags that are to be included in the report.
    Defaults to 'HC'. i.e Any stat having tag 'HC' would be included.

    exclude_tags: Comma separated list of tags to be excluded. This overrides
    the 'tags' parameter. i.e if a tag was present in both 'tags' and 
    'exclude_tags' parameter then it would be excluded.

   NOTE1: When running this in sqlplus the output line break would depend 
   on certain sqlplus parameters such as longsize, linesize, longchunksize etc. 
   If these are not set high enough the output generated could be malformed 
   (with newlines introduced by sqlplus). 

   NOTE2:The function truncates any column value that is more than 400 chars. 
   This number is configurable through max_column_length parameter.
   Also it would remove any new lines present in any column values so that 
   the json could be correctly formed. 

===============================================================================

  /* There a few parameters that can be altered in the healthcheck framework
   * This function can be used to alter those parameters
   */
 
  procedure set_parameter(
    name_in varchar2,
    value_in varchar2
  ) ;

  name_in - Name of the healthcheck parameter to be set
  value_in - value of the healthcheck parameter.

  Allowed parameters : 
     -- The snapshot of the system before and after the interval would be
     -- used to compute rate of change of data/messages/transactions etc.
     'sample_interval' - in seconds - default 10secs

     -- Number of times the advisor needs to be run
     'advisor_run_count', - in count - default 1 (run once)

     -- Time interval to wait between each advisor runs
     'advisor_interval', - in seconds - default 1 sec

     -- How many minutes of sql needs to be analyzed prior to current time
     'minutes_to_analyze' - in minutes - default 30 min

     -- Column value exceeding max_column_length bytes would be truncated
     -- to max_column_size. The column value would be prefixed with message
     -- that this values is truncated from actual size to max_column_length
     'max_column_length' - in bytes - default 400

     -- If a stat query returns more than this many number of rows
     -- then the number of rows fetched would be limited to this.
     'max_rows' - in count - default 5000

  function get_parameter(name_in varchar2) return varchar2 ;
===============================================================================

/* Unlike old healthcheck, the queries catering to each stat is not directly
 * visible. This function gets the query belonging to a stat 
 */

  function getQuery(
    name in varchar2
  ) return clob ;

  Returns the query text as a clob.

  name -  Stat Id whose query needs to be fetched
===============================================================================

/* Each stat can be enabled or disabled. If disabled, the query belonging to
 * the stat will not be executed on the server, but the metatdata of the stat
 * would appear in the output (in chosen format) saying it was disabled 
 */

  procedure enable(stat_id varchar2) ;
  procedure disable(stat_id varchar2) ;

  stat_id -  Stat Id that needs to be enabled or disabled
===============================================================================
