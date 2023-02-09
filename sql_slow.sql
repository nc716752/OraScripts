set pages 100 lines 200
set long 200
col "Elapsed per Exec" format 9,999,999.999
select sql_id, executions, elapsed_time, elapsed_time / executions / 1000000 "Elapsed per Exec", parsing_schema_name "User"
from v$sql
where executions  > 0
and parsing_schema_name not in ('SYS', 'SYSTEM', 'SKYUTILS')
and elapsed_time / executions / 1000000 > 0.05
order by elapsed_time / executions / 1000000
/
