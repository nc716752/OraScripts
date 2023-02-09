set pagesize 100 linesize 200
col owner format a16
col object_name format a34
col subobject_name format a24
col object_type format a12
select owner, object_name, subobject_name, object_type, last_ddl_time, status
from dba_objects
where status = 'INVALID';
