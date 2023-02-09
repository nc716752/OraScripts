clear columns
clear breaks
undefine grantee 
set pagesize 100 linesize 200
set pause on 
set pause Continues... 
set verify off
 
select 'Column' "Level",c.privilege,c.grantable,c.owner,c.table_name,c.column_name 
from dba_col_privs c 
where grantee = upper('&&grantee') 
union 
select 'Role' GrType,r.granted_role obj,r.admin_option a, null,null,null 
from dba_role_privs r 
where r.grantee = upper('&grantee') 
union 
select 'Sys Priv',s.privilege,s.admin_option,null,null,null 
from dba_sys_privs s 
where s.grantee = upper('&grantee') 
union 
select 'table',t.privilege,t.grantable,t.owner,t.table_name,null 
from dba_tab_privs t 
where t.grantee = upper('&grantee') 
and t.privilege !='EXECUTE' 
union 
select 'Program', e.privilege,e.grantable,e.owner,e.table_name,null 
from dba_tab_privs e 
where e.grantee = upper('&grantee') 
and e.privilege ='EXECUTE' 
order by 1,2,4,5,6 
/ 
