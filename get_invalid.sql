clear columns
clear breaks
column object_name format a50
set pagesize 100 linesize 200
select owner, object_name, subobject_name, object_type, status from dba_objects where status = 'INVALID';

