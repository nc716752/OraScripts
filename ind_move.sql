col index_name format a36
col owner format a16
col index_type format a20
col tablespace_name format a36
select owner, index_name, index_type, tablespace_name, blevel, leaf_blocks, LAST_ANALYZED
from dba_indexes
where owner = '&own'
  and tablespace_name like '%DATA%'
  and index_type not in ('LOB', 'IOT - TOP')
order by leaf_blocks
;

select 'Alter index ' || owner || '.' || index_name || ' rebuild tablespace ' || replace(tablespace_name,'DATA','INDEX') || ';' "Alter"
from dba_indexes
where owner = '&own'
  and tablespace_name like '%DATA%'
  and index_type not in ('LOB', 'IOT - TOP')
;

-- all users except ...
select 'Alter index ' || di.owner || '.' || di.index_name || ' rebuild tablespace ' || replace(di.tablespace_name,'DATA','INDEX') || ';' "Alter"
from dba_indexes di
where di.tablespace_name like '%DATA%'
  and di.owner not in ('SYS', 'SYSTEM', 'SKYUTILS', 'SQLTXPLAIN', 'XDB', 'CTX')
  and di.index_type not in ('LOB', 'IOT - TOP')
  and exists (select dt.tablespace_name from dba_tablespaces dt where dt.tablespace_name = replace(di.tablespace_name,'DATA','INDEX') )
;

select 'Alter index ' || owner || '.' || index_name || ' rebuild tablespace ' || replace(tablespace_name,'DATA','IND') || ';' "Alter"
from dba_indexes
where owner = '&own'
  and tablespace_name like '%DATA%'
  and index_type not in ('LOB', 'IOT - TOP')
;

select 'Alter index ' || owner || '.' || index_name || ' rebuild tablespace ' || replace(tablespace_name,'DATA','IDX') || ';' "Alter"
from dba_indexes
where owner = '&own'
  and tablespace_name like '%DATA%'
  and index_type not in ('LOB', 'IOT - TOP')
;

select 'Alter index ' || owner || '.' || index_name || ' rebuild tablespace ' || replace(tablespace_name,'USERS_AUTO_01','&indts') || ';' "Alter"
from dba_indexes
where owner = '&own'
  and tablespace_name = 'USERS_AUTO_01'
  and index_type not in ('LOB', 'IOT - TOP')
;


select 'Alter index ' || owner || '.' || index_name || ' rebuild tablespace ' || replace(tablespace_name,'TS4K','TSIND4K') || ';' "Alter"
from dba_indexes
where tablespace_name = 'TS4K'
  and index_type not in ('LOB', 'IOT - TOP')
;

select 'Alter index ' || owner || '.' || index_name || ' rebuild tablespace ' || replace(tablespace_name,'TS16K','TSIND4K') || ';' "Alter"
from dba_indexes
where tablespace_name = 'TS16K'
  and index_type not in ('LOB', 'IOT - TOP')
;

select 'Alter index ' || owner || '.' || index_name || ' rebuild tablespace ' || replace(tablespace_name,'TS32K','TSIND4K') || ';' "Alter"
from dba_indexes
where tablespace_name = 'TS32K'
  and index_type not in ('LOB', 'IOT - TOP')
;

select 'Alter index ' || owner || '.' || index_name || ' rebuild tablespace ' || replace(tablespace_name,'USERS_TABLESPACE','SSR_INDEX_SPACE') || ';' "Alter"
from dba_indexes
where owner = 'BFS'
  and tablespace_name = 'USERS_TABLESPACE'
  and index_type not in ('LOB', 'IOT - TOP')
;
