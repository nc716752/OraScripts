clear columns
clear breaks

alter session set nls_date_format = 'dd-Mon-yyyy hh24:mi:ss';
column username format A20
column "cpu (s)" format 9,999,999.000
column "Elapsed (s)" format 9,999,999.000

select s.sid, s.serial#, s.username, s.status,  s.sql_id, s.SQL_EXEC_START, c.LAST_ACTIVE_TIME,
       c.elapsed_time / 1000000 "Elapsed (s)", c.cpu_time / 1000000 "cpu (s)", c.executions
 , c.sql_text
from v$session s, v$sql c
where s.sql_id = c.sql_id
  and c.LAST_ACTIVE_TIME >= s.SQL_EXEC_START
--  and USERNAME is not null
  and PARSING_SCHEMA_NAME not in ('SYS', 'SYSTEM', 'XDB', 'DBSNMP', 'OUTLN', 'GSMADMIN_INTERNAL')
;
