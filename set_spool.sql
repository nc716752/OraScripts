-- set_spool.sql
--
-- set spool file name and report format (html or text)
--
set echo off
set verify off
set feedback off
--
-- undefine variables
--
undef report_type
undef report_name
undef spool_name
undef ext
undef rephtml
--
prompt
prompt Enter the Report Type
prompt ---------------------
prompt The default report type is text,
prompt press <return> to use this type, otherwise enter the html for html output.
prompt
--
column report_type new_value report_type;
set heading off;
select 'Type Specified: ',lower(nvl('&&report_type','text')) report_type from dual;
set heading on;
set termout off;
--
-- Set the extension based on the report_type
column ext new_value ext;
column rephtml new_value rephtml;
select '.html' ext, 'ON' rephtml from dual where lower('&&report_type') = 'html';
select '.txt' ext, 'OFF' rephtml from dual where lower('&&report_type') <> 'html';
--
--
column spool_name new_value spool_name noprint;
select '&&1'|| '_report' spool_name from dual;
set termout on;
--
prompt
prompt Enter the Report Name
prompt ---------------------
prompt The default report file name is &spool_name,
prompt press <return> to use this name, otherwise enter the spool file name (no extention).
prompt
--
set heading off;
column report_name new_value report_name noprint;
select 'Using the report name ' || nvl('&&report_name','&spool_name')
     , nvl('&&report_name','&spool_name') || '&&ext' report_name
  from sys.dual;
--
set markup html &&rephtml
--
spool &report_name;
