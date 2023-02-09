-- ind_review.sql
--
-- This routine prompts for a table and owner then produces a report that can be used to review for possible missing indexes.
-- This reports on table access filters
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
@@set_spool Index_Review
--
-- Prompt for owner and table
undef tbown
undef tbnam
prompt Enter owner and table name to be reviewed
--
-- table infomation
--
set heading on;
column tbown new_value tbown noprint
column tbnam new_value tbnam noprint
column owner format a16
column table_name format a30
column pct_sample format 999 Heading "Sample %"
ttitle skip 2 center 'Table Information' skip 2
select dt.owner, dt.table_name, dt.num_rows, dt.avg_row_len, dt.chain_cnt, dt.blocks, dt.empty_blocks,
       dt.last_analyzed, dt.sample_size, dt.sample_size / dt.num_rows * 100 pct_sample
from dba_tables dt
where dt.owner = '&&tbown'
      and
      dt.table_name = '&&tbnam'
;
--
--
--
-- declare a bind variable and set it to the input value
var bind_own varchar2(32)
var bind_tab varchar2(32)
begin
  :bind_own := '&tbown';
  :bind_tab := '&tbnam';
end;
/
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
select di.table_name, di.owner, di.index_name, index_type, uniqueness, di.blevel, di.leaf_blocks, di.distinct_keys, di.num_rows,
       di.avg_leaf_blocks_per_key, di.avg_data_blocks_per_key, di.last_analyzed
from dba_indexes di
where di.table_name = :bind_tab
      and
      di.table_owner = :bind_own
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
select dc.table_name, dc.index_owner, dc.index_name, dc.column_position, dc.column_name, dc.column_length, dc.descend
from dba_ind_columns dc
where dc.table_name = :bind_tab
      and
      dc.table_owner = :bind_own
order by dc.table_name, dc.index_owner, dc.index_name, column_position 
;
--
-- sql_ids with filters on table access - history
--
col oper_option form a50 Heading "Operation"
ttitle skip 2 center 'Table Access Filters - History' skip 2
--
select distinct
  sql_id,
  plan_hash_value,
  trim(operation) || ' ' || trim (options) oper_option,
  filter_predicates
from dba_hist_sql_plan
where object_owner = :bind_own
      and
      object_name = :bind_tab
      and
      filter_predicates is not null
order by sql_id, plan_hash_value
;
--
-- sql_ids with filters on table access - current
--
col oper_option form a50 Heading "Operation"
ttitle skip 2 center 'Table Access Filters - Current' skip 2
--
select distinct
  sql_id,
  plan_hash_value,
  trim(operation) || ' ' || trim (options) oper_option,
  filter_predicates
from v$sql_plan
where object_owner = :bind_own
      and
      object_name = :bind_tab
      and
      filter_predicates is not null
order by sql_id, plan_hash_value
;
--
spool off
set markup html off
