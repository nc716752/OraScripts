clear columns
clear breaks

alter session set nls_date_format = 'dd-Mon-yyyy hh24:mi:ss';
column username format A20

select s.sid, s.serial#, s.username, s.sql_id, c.sql_text
from v$session s, v$sql c
where s.sql_id = c.sql_id
  and s.sid = &sid
/
