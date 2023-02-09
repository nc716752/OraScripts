set pagesize 100 linesize 200
select vss.sql_id, to_char(vss.last_active_time, 'yyyy-Mon-dd hh24:mi') , vss.executions, vss.rows_processed, vss.fetches, vss.sql_text
from v$sqlstats vss
inner join v$sql vl on vl.sql_id = vss.sql_id and vl.parsing_schema_name = 'CCM'
where (vss.rows_processed > 999 and vss.fetches > 0 )
   or ( vss.fetches > 999 and vss.rows_processed > 0 )
/
