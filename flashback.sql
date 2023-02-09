-- configure (size first)
alter system set db_recovery_file_dest_size=35G sid='*' SCOPE=both;
alter system set db_recovery_file_dest_size=18000M sid='*' SCOPE=both;
alter system set db_recovery_file_dest='/tlvzodbd02/ora/flashback01' sid='*' SCOPE=both;

select flashback_on from v$database;

alter database flashback on;

alter system set db_flashback_retention_target=1440 sid='*' scope=both;  -- 1 day in mins
alter system set db_flashback_retention_target=720 sid='*' scope=both;  -- 1/2 day

-- also should set UNDO_RETENTION to a sensible value:

alter system set undo_retention=86400 sid='*' scope=both; -- 1 day in secs
alter system set undo_retention=43200 sid='*' scope=both;

-- create restore point
create restore point Jan212020 GUARANTEE FLASHBACK DATABASE;

select name, time,guarantee_flashback_database from v$restore_point;

-- flash back
shutdown immediate;
startup mount;

flashback database to restore point AMQ_Mig;
alter database open resetlogs;

-- drop restore point
col name format a32
col time format a32
select name, time,guarantee_flashback_database from v$restore_point;
drop restore point BSKYB30469;

create restore point VCMFIXES GUARANTEE FLASHBACK DATABASE;