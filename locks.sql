set pagesize 60 linesize 200
column object_name format a28
column object_type format a10 Heading 'Type'
column event format a30
column LOCKED_MODE format 99 Heading 'Mode'
column oracle_username format a8 heading 'User'
column final_blocking_session format 999999 heading 'Holder'
column blocking_session format 999999 heading 'Blocker'
column sid format 999999 heading 'session'
select to_char(systimestamp,'hh24:mi:ss') "Time", do.object_type, do.object_name, lo.locked_mode, lo.oracle_username, vs.sid,
       vs.blocking_session, vs.final_blocking_session, vs.event, vs.sql_id, vs.prev_sql_id
from dba_objects do, v$locked_object lo, v$session vs
where do.object_id = lo.object_id
  and lo.session_id = vs.sid
;

