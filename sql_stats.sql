clear columns
clear breaks
set pagesize 200 linesize 200
column sql_id NEW_VALUE tsqlid noprint
col cur form 999
col iowaitms Heading "IO Wait (ms)"
col clwaitms Heading "Cluster Wait (ms)"
col ccwaitms Heading "Concurr Wait (ms)"
col apwaitms Heading "App Wait (ms)"
ttitle center 'Execution statistics for sql_id ' tsqlid skip 2
break on sql_id skip page on plan_hash_value on cur skip 2
select
  sql_id,
  plan_hash_value,
  child_number cur,
  executions,
  sorts,
  fetches,
  disk_reads,
  buffer_gets,
  user_io_wait_time/1000 iowaitms,
  cluster_wait_time/1000 clwaitms,
  concurrency_wait_time/1000 ccwaitms,
  application_wait_time/1000 apwaitms
from v$sql
where sql_id = '&sqlid'
order by sql_id, plan_hash_value, cur;
