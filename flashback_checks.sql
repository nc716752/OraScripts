alter session set nls_date_format = 'dd-mon-yyyy hh24:mi:ss';
col name format a36

SELECT CREATION_TIME, OBJECT_TYPE, MESSAGE_TYPE, MESSAGE_LEVEL,REASON, SUGGESTED_ACTION
FROM DBA_OUTSTANDING_ALERTS
;

SELECT * FROM V$FLASH_RECOVERY_AREA_USAGE;

col oldest_flashback_scn format 9999999999999999
select sysdate "Current Time", oldest_flashback_scn, oldest_flashback_time, estimated_flashback_size/1024/1024/1024 "Est. Size (GB)" from v$flashback_database_log;

col "Used (%)" format 999.99
col "Used (GB)" format 9999.99
col "Reclaimable (%)" format 999.99
col "Reclaimable (GB)" format 9999.99

select vrfd.name,
       vrfd.limit "Limit (GB)",
       vrfd.used  "Used (GB)",
       vrfd.used / vrfd.limit * 100  "Used (%)",
       vrfd.reclaimable "Reclaimable (GB)",
       vrfd.reclaimable / vrfd.limit * 100  "Reclaimable (%)",
       vrfd.number_of_files
from ( select name,
              space_limit /1024/1024/1024 limit,
              space_used /1024/1024/1024 used, 
              space_reclaimable /1024/1024/1024 reclaimable,
              number_of_files
       from V$RECOVERY_FILE_DEST
     ) vrfd
;

select name, time,guarantee_flashback_database from v$restore_point;

select max(rpage.hours) age
from (
select 0.0 hours from dual
union all
select (sysdate - cast(TIME as date)) * 24 hours from v$restore_point
) rpage
;
