-- ========================================================
-- list index size information for an Index or all indexes for a Table
-- use * to select all indexes
-- Specifing * from both index and table returns no rows
-- ========================================================
clear columns
clear breaks
set pagesize 100 linesize 200
undefine tab
undefine ind
set verify off
set echo off
select owner, index_name, blevel, leaf_blocks, distinct_keys, num_rows,
       avg_leaf_blocks_per_key, avg_data_blocks_per_key, last_analyzed, sample_size
from dba_indexes
where (table_name = '&&tab' or '&tab' = '*' )
      and
      (index_name = '&&ind' or  ('&ind' = '*' and '&tab' != '*'))
;
