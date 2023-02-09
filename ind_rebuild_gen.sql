clear columns
clear breaks

alter session set nls_date_format = 'dd-Mon-yyyy hh24:mi:ss';
column owner format A20
column index_name format A32
column index_type format A24

select owner, index_type, index_name, blevel, last_analyzed from dba_indexes where owner = '&schema';

select owner, index_type, index_name, blevel, last_analyzed from dba_indexes where blevel > 1 and owner not in ('SYS', 'SYSTEM', 'XDB', 'DBSNMP', 'OUTLN', 'GSMADMIN_INTERNAL');

select owner, index_type, index_name, blevel, last_analyzed from dba_indexes 
where last_analyzed < (sysdate - 30) and owner not in ('SYS', 'SYSTEM', 'XDB', 'DBSNMP', 'OUTLN', 'GSMADMIN_INTERNAL');

set heading off feedback off pagesize 0 linesize 132
select 'alter index ' || OWNER || '.' || INDEX_NAME || ' rebuild online;' rebuild from dba_indexes where owner = '&schema' and index_type like '%NORMAL%';

select 'alter index ' || OWNER || '.' || INDEX_NAME || ' rebuild online;' rebuild
   from dba_indexes
   where owner = '&schema' and index_type like '%NORMAL%' and table_name = '&tabnam';

select 'alter index ' || OWNER || '.' || INDEX_NAME || ' rebuild online;' rebuild 
from dba_indexes 
where index_type like '%NORMAL%' 
and last_analyzed < (sysdate - 30) 
and owner not in ('SYS', 'SYSTEM', 'XDB', 'DBSNMP', 'OUTLN', 'GSMADMIN_INTERNAL');
