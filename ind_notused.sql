clear columns
clear breaks
set pagesize 200 linesize 200
col table_name format a26
col owner format a16
col index_name format a30
ttitle Left 'Indexes not used during AWR retention, But Tables Accessed' skip 2
break on din.table_owner on din.table_name  on din.index_name 
--
select din.table_owner, din.table_name, din.index_name, din.uniqueness
from dba_indexes din,
     ( select distinct object_owner, object_name, object_type
       from DBA_HIST_SQL_PLAN
       where object_owner not in ('SYS','SYSTEM')
         and object_type = 'TABLE'
     ) awr
where din.table_name = awr.object_name
  and din.table_owner = awr.object_owner
  and (din.owner, din.index_name)
       not in (select object_owner, object_name
               from DBA_HIST_SQL_PLAN
               where object_owner not in ('SYS','SYSTEM')
                 and object_type like 'INDEX%'
               )
order by din.table_owner, din.table_name, din.index_name
;
