select 'alter system kill session ''' || sid || ',' || serial# || ''' immediate;' kill
from v$session
where username = '&user';
