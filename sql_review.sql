-- sql_review.sql
--
-- This routine prompts for a sql_id then produces a report that can be used to review the statement.
-- This is just current data and is not a comphrehensive as SQLHC or SQLT provide by ORACLE
-- 
--
clear columns
clear breaks
ttitle off
set echo off
set verify off
set pagesize 200 linesize 200
--
-- set spool and markup
--
@@set_spool SQL_Review
--
-- Prompt for sql_id
undef sqlid
prompt Enter SQL_ID of the statement to be reviewed
set heading off;
set long 2000
column sql_fulltext format a180 word wrap
column sqlid new_value sqlid noprint
select sql_fulltext from v$sql where sql_id = '&&sqlid' and rownum < 2;
--
-- if sql not in v$sql then text can be got from dba_hist_sqltext...
--
-- column sql_text format a180 word wrap
--
-- select sql_text from dba_hist_sqltext where sql_id = :bind_sql;
--
set heading on;
--
-- declare a bind variable and set it to the input value
var bind_sql varchar2(16)
begin
  :bind_sql := '&sqlid';
end;
/
--
column sql_id NEW_VALUE tsqlid noprint
col cur form 999
col iowaitms Heading "IO Wait (ms)"
col clwaitms Heading "Cluster Wait (ms)"
col ccwaitms Heading "Concurr Wait (ms)"
col apwaitms Heading "App Wait (ms)"
col sql_profile format a20 Heading "Profile"
col sql_plan_baseline format a20 Heading "Baseline"
--
ttitle center 'Current Execution statistics for sql_id ' tsqlid skip 2
break on sql_id skip page on plan_hash_value on cur skip 1
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
  application_wait_time/1000 apwaitms,
  sql_profile,
  sql_plan_baseline
from v$sql
where sql_id = :bind_sql
order by sql_id, plan_hash_value, cur
;
--
-- display execution plan
--
col cur form 999
col id form 999
col parent_pos form a12 Heading "Parent(pos)"
col own_obj_acc form a60 Heading "Object Access" word wrap
col oper_option form a50 Heading "Operation"
ttitle center 'Current Execution Plan(s) for sql_id ' tsqlid skip 2
break on sql_id skip page on plan_hash_value on cur skip 1
select
  sql_id,
  plan_hash_value,
  child_number cur,
  id,
  lpad((to_char(parent_id) || ' (' || to_char(position) || ')'),11,' ') parent_pos,
  lpad(' ',depth*2,' ') || trim(operation) || ' ' || trim (options) oper_option,
  nvl2(object_name,(trim(object_owner) || nvl2(object_name,'.',' ') || trim(object_name)),'')
    || nvl2(access_predicates,(' -->' || trim(access_predicates)),'') own_obj_acc,
  cost,
  cardinality,
  cpu_cost,
  io_cost
from v$sql_plan
where sql_id = :bind_sql
order by sql_id, plan_hash_value, cur, id
;
--
-- ASH History
--
col cur form 999
col event form a30
col twaitms Heading "Waited (ms)"
col obj_info form a30 Heading "Object Details"
col oper_option form a30 Heading "Operation"
ttitle center 'Active Session History for sql_id ' tsqlid skip 2
break on sql_id skip page on hash_value on cur skip 2
select
  sql_id,
  sql_plan_hash_value hash_value,
  sql_child_number cur,
  sample_id,
  event,
  time_waited/1000 twaitms,
  trim(sql_plan_operation) || ' ' || trim (sql_plan_options) oper_option,
  current_obj#,
  nvl2(current_obj#,(trim(object_type) || ' ' || trim(owner) || '.' || trim(object_name)),'') obj_info,
  session_state
from dba_hist_active_sess_history, dba_objects
where sql_id = :bind_sql
  and event is not null
  and current_obj# = object_id(+)
  and rownum <= &ash_rows
order by sql_id, hash_value, cur, sample_id;
--
--
-- display plan History
--
ttitle skip 2 center 'Execution Plan History for sql_id ' tsqlid skip 2
break on sql_id on plan_hash_value
select
  sql_id,
  plan_hash_value,
  min (snap_id),
  max (snap_id)
from dba_hist_sqlstat
where sql_id = :bind_sql
group by sql_id, plan_hash_value
order by sql_id, plan_hash_value
;
--
-- table infomation
--
column owner format a16
column table_name format a30
column pct_sample format 999 Heading "Sample %"
ttitle skip 2 center 'Table Information' skip 2
with tab_list as
( select distinct object_owner, object_name from
  (
  select object_owner, object_name
  from v$sql_plan
  where sql_id = :bind_sql
    and object_type = 'TABLE'
  Union all
  select di.table_owner object_name, di.table_name object_name
  from dba_indexes di, v$sql_plan sp
  where sp.sql_id = :bind_sql
    and sp.object_type like 'INDEX%'
    and di.owner = sp.object_owner
    and di.index_name = sp.object_name
  ) tbl
)
select dt.owner, dt.table_name, dt.num_rows, dt.avg_row_len, dt.chain_cnt, dt.blocks, dt.empty_blocks,
       dt.last_analyzed, dt.sample_size, dt.sample_size / dt.num_rows * 100 pct_sample
from dba_tables dt, tab_list tl
where dt.table_name = tl.object_name
      and
      dt.owner = tl.object_owner
;
--
-- column infomation
--
column owner format a16
column table_name format a30
col column_name format a30
col data_type format a12 Heading "Type"
col data_length format 99,999 Heading "Length"
col data_precision Heading "Precision"
col data_scale Heading "Scale"
col buckets format 9,999 Heading "Buckets"
--
break on owner on table_name skip 1
ttitle skip 2 center 'Table Column Information' skip 2
--
with tab_list as
( select distinct object_owner, object_name from
  (
  select object_owner, object_name
  from v$sql_plan
  where sql_id = :bind_sql
    and object_type = 'TABLE'
  Union all
  select di.table_owner object_name, di.table_name object_name
  from dba_indexes di, v$sql_plan sp
  where sp.sql_id = :bind_sql
    and sp.object_type like 'INDEX%'
    and di.owner = sp.object_owner
    and di.index_name = sp.object_name
  ) tbl
)
, hist_data as (
select owner, table_name, column_name, count(*) as buckets
  from dba_histograms
group by owner, table_name, column_name
order by owner, table_name, column_name
)
select
  c.owner,
  c.table_name,
  c.column_name,
  c.data_type,
  c.data_length,
  c.data_precision,
  c.data_scale,
  c.histogram,
  h.buckets,
  c.nullable
from dba_tab_columns c, tab_list tl, hist_data h
where c.owner = tl.object_owner
      and
      c.table_name = tl.object_name
      and
      c.owner = h.owner
      and
      c.table_name = h.table_name
      and
      c.column_name = h.column_name
order by c.owner, c.table_name, c.column_name
;
--
-- Index infomation
--
column owner format a16
column table_name format a30
column index_name format a30
column index_type format a21
column blevel format 99
column avg_leaf_blocks_per_key heading "Leaf/key"
column avg_data_blocks_per_key heading "Data/key"
column last_analyzed Heading "Analyzed"
break on table_name on owner on index_name skip 1
ttitle skip 2 center 'Index Information' skip 2
with tab_list as
( select distinct object_owner, object_name from
  (
  select object_owner, object_name
  from v$sql_plan
  where sql_id = :bind_sql
    and object_type = 'TABLE'
  Union all
  select di.table_owner object_name, di.table_name object_name
  from dba_indexes di, v$sql_plan sp
  where sp.sql_id = :bind_sql
    and sp.object_type like 'INDEX%'
    and di.owner = sp.object_owner
    and di.index_name = sp.object_name
  ) tbl
)
select di.table_name, di.owner, di.index_name, index_type, uniqueness, di.blevel, di.leaf_blocks, di.distinct_keys, di.num_rows,
       di.avg_leaf_blocks_per_key, di.avg_data_blocks_per_key, di.last_analyzed
from dba_indexes di, tab_list tl
where di.table_name = tl.object_name
      and
      di.table_owner = tl.object_owner
order by di.table_name, di.owner, di.index_name
;
--
-- Index column infomation
--
column index_owner format a16
column table_name format a30
column index_name format a30
column column_position Heading "Pos."
column column_name format a30
column column_length format 99,999 Heading "Length"
--
break on table_name on index_owner on index_name skip 1
ttitle skip 2 center 'Index Column Information' skip 2
with tab_list as
( select distinct object_owner, object_name from
  (
  select object_owner, object_name
  from v$sql_plan
  where sql_id = :bind_sql
    and object_type = 'TABLE'
  Union all
  select di.table_owner object_name, di.table_name object_name
  from dba_indexes di, v$sql_plan sp
  where sp.sql_id = :bind_sql
    and sp.object_type like 'INDEX%'
    and di.owner = sp.object_owner
    and di.index_name = sp.object_name
  ) tbl
)
select dc.table_name, dc.index_owner, dc.index_name, dc.column_position, dc.column_name, dc.column_length, dc.descend
from dba_ind_columns dc, tab_list tl
where dc.table_name = tl.object_name
      and
      dc.table_owner = tl.object_owner
order by dc.table_name, dc.index_owner, dc.index_name, column_position 
;
--
spool off
set markup html off
