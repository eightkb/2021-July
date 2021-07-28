dbcc sqlperf('sys.dm_os_wait_stats', 'clear')
go
SELECT es.session_id, er.status, er.blocking_session_id, er.command, er.wait_type, er.last_wait_type, er.wait_resource, er.wait_time
FROM sys.dm_exec_requests er
INNER JOIN sys.dm_exec_sessions es
ON er.session_id = es.session_id
AND es.is_user_process = 1;
GO
select * from sys.dm_os_wait_stats
order by waiting_tasks_count desc
go