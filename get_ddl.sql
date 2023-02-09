clear columns
clear breaks
set pagesize 100 linesize 200
set verify off
set echo off
column ddltxt format a120 wrap heading "DDL text"
set long 40000
select dbms_metadata.get_ddl('&typ','&obj','&own') ddltxt from dual;


