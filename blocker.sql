select distinct vs.SID "Blocked SID", vs.SQL_ID "Blocked SQL", vs.event "Blocked Status",
       vb.sql_fulltext "Blocked SQL Text",
       bs.SID "Blocking SID", bs.PREV_SQL_ID "Blocker Last SQL", bs.event "Blocker Status",
       sa.sql_fulltext "Blocker last SQL Text"
from v$session vs, v$session bs, v$sqlarea sa, v$sqlarea vb
where vs.FINAL_BLOCKING_SESSION is not null
  and bs.SID = vs.FINAL_BLOCKING_SESSION
  and sa.sql_id = bs.PREV_SQL_ID
  and vb.sql_id = vs.SQL_ID
/

