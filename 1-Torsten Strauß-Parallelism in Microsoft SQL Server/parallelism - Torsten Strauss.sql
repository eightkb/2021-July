/*******************************************************************************

	Date:					August 2020
	Session:			
	SQL Server Version:		2017 +

	Author:					Torsten Strauss
							https://inside-sqlserver.com 
							https://sarpedonqualitylab.com/

	This script is intended only as a supplement to demos and lectures
	given by Torsten Strauss.  
  
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.

*******************************************************************************/

/*******************************************************************************

	parallelism - preparation

*******************************************************************************/

-- Do not execute!
SET PARSEONLY ON;
GO

EXEC sys.sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

USE AdventureWorks2017;
GO

-- Create a table
DROP TABLE IF EXISTS test;
GO

CREATE TABLE test ( col1 int NOT NULL);
GO

WITH cte
AS
	(
		SELECT numbers.col1
		FROM ( VALUES ( 0 )
			   ,	  ( 1 )
			   ,	  ( 2 )
			   ,	  ( 3 )
			   ,	  ( 4 )
			   ,	  ( 5 )
			   ,	  ( 6 )
			   ,	  ( 7 )
			   ,	  ( 8 )
			   ,	  ( 9 )
			 ) AS numbers ( col1 )
	)
INSERT dbo.test
	(
		col1
	)
SELECT (c1.col1 * 100000 + c2.col1 * 10000 + c3.col1 * 1000 + c4.col1 * 100
		+ c5.col1 * 10 + c6.col1 * 1
	   ) % 2
FROM
	cte AS c1
CROSS JOIN cte AS c2
CROSS JOIN cte AS c3
CROSS JOIN cte AS c4
CROSS JOIN cte AS c5
CROSS JOIN cte AS c6;
GO



-- Create a table
DROP TABLE IF EXISTS big_table1;
GO

CREATE TABLE big_table1
(
	id int IDENTITY NOT NULL
  , col1 int NOT NULL
  , col2 int NOT NULL
  , filler char(200) NULL
);
GO

WITH cte
AS
	(
		SELECT numbers.col1
		FROM ( VALUES ( 0 )
			   ,	  ( 1 )
			   ,	  ( 2 )
			   ,	  ( 3 )
			   ,	  ( 4 )
			   ,	  ( 5 )
			   ,	  ( 6 )
			   ,	  ( 7 )
			   ,	  ( 8 )
			   ,	  ( 9 )
			 ) AS numbers ( col1 )
	)
INSERT big_table1
	(
		col1, col2
	)
SELECT (c1.col1 * 100000 + c2.col1 * 10000 + c3.col1 * 1000 + c4.col1 * 100
		+ c5.col1 * 10 + c6.col1 * 1
	   )
  , (c1.col1 * 100000 + c2.col1 * 10000 + c3.col1 * 1000 + c4.col1 * 100
	 + c5.col1 * 10 + c6.col1 * 1
	) % 2
FROM
	cte AS c1
CROSS JOIN cte AS c2
CROSS JOIN cte AS c3
CROSS JOIN cte AS c4
CROSS JOIN cte AS c5
CROSS JOIN cte AS c6;
GO

ALTER TABLE big_table1 ADD CONSTRAINT PKCL_big_table1_id PRIMARY KEY (id);
GO



-- Create a table
DROP TABLE IF EXISTS big_table2;
GO

CREATE TABLE big_table2
(
	id int IDENTITY NOT NULL
  , col1 int NOT NULL
  , col2 int NOT NULL
  , filler char(200) NULL
);
GO

WITH cte
AS
	(
		SELECT numbers.col1
		FROM ( VALUES ( 0 )
			   ,	  ( 1 )
			   ,	  ( 2 )
			   ,	  ( 3 )
			   ,	  ( 4 )
			   ,	  ( 5 )
			   ,	  ( 6 )
			   ,	  ( 7 )
			   ,	  ( 8 )
			   ,	  ( 9 )
			 ) AS numbers ( col1 )
	)
INSERT big_table2
	(
		col1, col2
	)
SELECT (c1.col1 * 100000 + c2.col1 * 10000 + c3.col1 * 1000 + c4.col1 * 100
		+ c5.col1 * 10 + c6.col1 * 1
	   )
  , (c1.col1 * 100000 + c2.col1 * 10000 + c3.col1 * 1000 + c4.col1 * 100
	 + c5.col1 * 10 + c6.col1 * 1
	) % 2
FROM
	cte AS c1
CROSS JOIN cte AS c2
CROSS JOIN cte AS c3
CROSS JOIN cte AS c4
CROSS JOIN cte AS c5
CROSS JOIN cte AS c6;
GO

ALTER TABLE big_table2 ADD CONSTRAINT PKCL_big_table2_id PRIMARY KEY (id);
GO



/*******************************************************************************

	parallelism

*******************************************************************************/

/*

	SQL Server can execute queries using multiple CPUs or cores simultaneously.
	
	Parallelism increases the overhead associated with executing a query which 
	influence the overall execution time of the query. 

	Parallelism assigns more threads to a query execution and can therefore lead 
	to thread pool starvation and system performance degradation

	Parallelism is only useful on servers running a relatively small number of 
	concurrent queries.
	
	SQL Server parallelizes queries by horizontally partitioning the input data 
	into approximately equal-sized sets, assigning one set to each CPU or core, 
	and then performing the same operation (such as aggregate, join, sort, 
	etc.) on each set.

	There is no guarantee that the best parallel plan found will have a lower 
	cost than the best serial plan, so the serial plan may still end up being 
	the better plan.

	For the optimizer even to consider a parallel plan, the following criteria 
	must be met:

	*	SQL Server must be running on a multiprocessor, multicore or 
		hyperthreaded machine.
		
	*	The processor affinity configuration must allow SQL Server to use at 
		least two processors.
		
	*	The max degree of parallelism advanced configuration option must be set 
		to zero (the default) or to more than one.
		
	*	The MAX_DOP configuration for Resource Governor must also allow the use 
		of parallel plans.
		
	*	The estimated cost to run a serial plan for a query is higher than the 
		value set in cost threshold for parallelism.

*/



/*******************************************************************************

	parallelism - system requirements

*******************************************************************************/

/*******************************************************************************

	parallelism - system requirements
	multiprocessor, multicore or hyperthreaded 

*******************************************************************************/

/*
	
	SQL Server must be running on a multiprocessor, multicore or hyperthreaded 
	machine.

*/

-- cpu_count : number of logical CPUs on the system
-- hyperthread_ratio : number of logical cores
-- physical_cpu_count : number of physical cores
SELECT
	cpu_count
  , hyperthread_ratio
  , cpu_count / hyperthread_ratio AS physical_cpu_count
FROM
	sys.dm_os_sys_info;
GO



/*******************************************************************************

	parallelism - system requirements
	processor affinity

*******************************************************************************/

/*

	The processor affinity configuration must allow SQL Server to use at least 
	two processors.

*/

-- Set PROCESS AFFINITY CPU = AUTO (8 cores)
ALTER SERVER CONFIGURATION SET PROCESS AFFINITY CPU = AUTO;
GO

-- Set cost threshold for parallelism to 5 (default)
-- Set max degree of parallelism to 0 (all cores)
EXEC sys.sp_configure N'cost threshold for parallelism', N'5';
EXEC sys.sp_configure 'max degree of parallelism', 0;
RECONFIGURE;
GO

-- cost threshold for parallelism : 5
-- max degree of parallelism : 0
SELECT
	name, value_in_use
FROM
	sys.configurations
WHERE
	name = N'cost threshold for parallelism'
	OR name LIKE 'max degree of parallelism';
GO

-- cpu_count : 8 
SELECT cpu_count FROM sys.dm_os_sys_info;
GO

-- affinity mask is used for the first 32 processors
-- affinity64 mask is used for additional 32 processors
-- affinity mask : 0 (automatic)
SELECT
	name, value_in_use
FROM
	sys.configurations
WHERE
	name = 'affinity mask'
	OR name = 'affinity64 mask'
GO

USE AdventureWorks2017;
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

-- Execute with discard results 
-- Query is running in parallel with 8 cores
-- Costs : 24,2383
-- CPU time = 953 ms,  elapsed time = 386 ms.
-- Degree of Parallelism : 8
SELECT
	col1, COUNT (filler)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE);
GO

-- Set PROCESSOR AFFINITY to use CPU 2 only (starts with CPU 0)
ALTER SERVER CONFIGURATION SET PROCESS AFFINITY CPU = 2;
GO

-- affinity mask is used for the first 32 processors
-- affinity64 mask is used for additional 32 processors
-- affinity mask : 4 (CPU1 : 2, CPU2 : 4, CPU3 : 8 ...)
SELECT
	name, value_in_use
FROM
	sys.configurations
WHERE
	name = 'affinity mask'
	OR name = 'affinity64 mask'
GO

-- Only scheduler 2 | CPU 2 can be used by SQL OS
SELECT
	parent_node_id AS numa_node, scheduler_id, cpu_id, status
FROM
	sys.dm_os_schedulers
WHERE
	status IN (
				  'VISIBLE ONLINE', 'VISIBLE OFFLINE'
			  );
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

-- Execute with discard results 
-- Query is running in serial now since only one cpu / core is assigned 
-- Non Parallel Plan Reason : EstimatedDOPIsOne
-- CPU time = 516 (953) ms,  elapsed time = 556 (386) ms.
-- Costs : 68,5153 (24,2383)
-- Degree of Parallelism : 0
SELECT
	col1, COUNT (filler)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE);
GO

-- Housekeeping
ALTER SERVER CONFIGURATION SET PROCESS AFFINITY CPU = AUTO;
EXEC sys.sp_configure N'cost threshold for parallelism', N'50';
EXEC sys.sp_configure 'max degree of parallelism', 0;
RECONFIGURE;
SELECT
	name, value_in_use
FROM
	sys.configurations
WHERE
	name = 'affinity mask'
	OR name = 'affinity64 mask'
GO



/*******************************************************************************

	parallelism - system requirements
	maximum degree of parallelism

*******************************************************************************/

/*

	The max degree of parallelism advanced configuration option must be set to 
	zero (the default) or to more than one.

	The MAX_DOP configuration for Resource Governor must also allow the use of 
	parallel plans.

*/

-- Set cost threshold for parallelism to 5 (default)
-- Set max degree of parallelism to 0 (all cores)
EXEC sys.sp_configure N'cost threshold for parallelism', N'5';
EXEC sys.sp_configure 'max degree of parallelism', 0;
RECONFIGURE;
GO

-- maximum degree of parallelism (DOP) on server and database level
-- max degree of parallelism : 0
-- max degree of parallelism = 0 or max degree of parallelism > 0
SELECT
	'server' AS level, name, value_in_use
FROM
	sys.configurations
WHERE
	name = N'max degree of parallelism'
UNION ALL
SELECT
	'database' AS level, name, value
FROM
	sys.database_scoped_configurations
WHERE
	name = N'MAXDOP'
GO

-- Execute with discard results
-- Query is running in parallel
-- Degree of Parallelism : 8
SELECT
	col1, COUNT (filler)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE);
GO

-- Change the max degree of parallelism from 0 (default) to 1
EXEC sys.sp_configure N'max degree of parallelism', N'1';
RECONFIGURE;
GO

-- Query is running in serial since max degree of parallelism is limited to 1
-- Non Parallel Plan Reason : MaxDOPSetToOne
-- Degree of Parallelism : 0
SELECT
	col1, COUNT (filler)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE);
GO

-- Overwrite max degree of parallelism on query level
-- Query is running in parallel although max degree of parallelism is limited to 1
-- MAXDOP : 0
-- Degree of Parallelism : 8
SELECT
	col1, COUNT (filler)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE, MAXDOP 0);
GO

-- Set the max degree of parallelism to 0 (default)
EXEC sys.sp_configure N'max degree of parallelism', N'0';
RECONFIGURE;
GO

-- Overwrite max degree of parallelism on query level
-- Query is running serially although max degree of parallelism is not limited
-- Non Parallel Plan Reason : MaxDOPSetToOne
-- MAXDOP : 1
-- Degree of Parallelism : 0
SELECT
	col1, COUNT (filler)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE, MAXDOP 1);
GO

-- Database scoped configuration
-- MAXDOP : 0
SELECT *
FROM
	sys.database_scoped_configurations
WHERE
	name = N'MAXDOP';
GO

-- Degree of Parallelism : 8
SELECT
	col1, COUNT (filler)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE)
GO

-- Set MAXDOP to 1 for just the AdventureWorks database
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 1;
GO

-- Non Parallel Plan Reason : MaxDOPSetToOne
-- Degree of Parallelism : 0
SELECT
	col1, COUNT (filler)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE, MAXDOP 1);
GO

-- Overwrite the MAXDOP database scoped configuration
-- MAXDOP : 0
-- Degree of Parallelism : 8
SELECT
	col1, COUNT (filler)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE, MAXDOP 0);
GO

-- Housekeeping
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
EXEC sys.sp_configure N'cost threshold for parallelism', N'50';
EXEC sys.sp_configure 'max degree of parallelism', 0;
RECONFIGURE;
GO



/*******************************************************************************

	parallelism - resource governor - dop

*******************************************************************************/

/*
	
	Resource Governor is an enterprise feature which you can use to manage 
	SQL Server workload and system resource consumption. Resource Governor 
	enables you to specify limits on the amount of CPU, physical I/O, and memory 
	that incoming application requests can use.

*/

USE master;
GO

-- Set cost threshold for parallelism to 5
EXEC sys.sp_configure 'cost threshold for parallelism', 5;
RECONFIGURE;
GO

-- Create a resource pool 
CREATE RESOURCE POOL myPool1
WITH
	(
		MIN_CPU_PERCENT = 0
	  , MAX_CPU_PERCENT = 25
	);
GO

-- Create a workload group in the resource pool with max_dop : 2
CREATE WORKLOAD GROUP myWorkloadGroup1 WITH (MAX_DOP = 2) USING myPool1;
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

DROP FUNCTION IF EXISTS fn_classifier
GO

-- Create the classifier function
CREATE FUNCTION fn_classifier
()
RETURNS sysname
WITH SCHEMABINDING
AS
	BEGIN
		DECLARE @workload_group sysname;

		IF (SUSER_NAME () = 'test_myWorkloadGroup1')
			SET @workload_group = 'myWorkloadGroup1';

		RETURN @workload_group;
	END;
GO

-- Apply the classifier function 
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo.fn_classifier);
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

-- Create the login test_myWorkloadGroup1
CREATE LOGIN test_myWorkloadGroup1
WITH
	PASSWORD = 'Pa$$w0rd', CHECK_POLICY = OFF;
GO

-- Add the login to the sysadmin role
ALTER SERVER ROLE sysadmin ADD MEMBER test_myWorkloadGroup1;
GO

-- Get the resource workload group statistics for the workload group 
-- myWorkloadGroup1
-- max_dop : 2
-- effective_max_dop : 2
SELECT
	rpool.name AS resource_pools_name
  , rgroup.name AS workload_group_name
  , rgroup.max_dop
  , rgroup.effective_max_dop
FROM
	sys.dm_resource_governor_resource_pools AS rpool
LEFT OUTER JOIN
	sys.dm_resource_governor_workload_groups AS rgroup
ON
	rpool.pool_id = rgroup.pool_id
WHERE
	rgroup.name = 'myWorkloadGroup1';
GO

-- Login as test_myWorkloadGroup1 in a new session
SELECT SUSER_NAME ();
SELECT dbo.fn_classifier () AS workload_group;
SELECT
	s.session_id
  , s.group_id AS workload_group_id
  , CAST(g.name AS nvarchar(20)) AS workload_group
  , s.login_time
  , login_name
FROM
	sys.dm_exec_sessions AS s
INNER JOIN
	sys.dm_resource_governor_workload_groups AS g
ON
	g.group_id = s.group_id
WHERE
	session_id = @@SPID;
GO

-- Run the query in the workload group myWorkloadGroup1 
-- Resource governor sets the max dop to 2
-- Costs : 24,1803
-- Degree of parallelism : 2
USE AdventureWorks2017
SELECT
	col1, COUNT (filler)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE);
GO

-- Get the resource workload group statistics for the workload group 
-- myWorkloadGroup1
-- max_dop : 2
-- effective_max_dop : 2
SELECT
	rpool.name AS resource_pools_name
  , rgroup.name AS workload_group_name
  , rgroup.statistics_start_time
  , rgroup.total_request_count
  , rgroup.active_request_count
  , rgroup.max_dop
  , rgroup.effective_max_dop
FROM
	sys.dm_resource_governor_resource_pools AS rpool
LEFT OUTER JOIN
	sys.dm_resource_governor_workload_groups AS rgroup
ON
	rpool.pool_id = rgroup.pool_id
WHERE
	rgroup.name = 'myWorkloadGroup1';
GO

-- Set max_dop to 1
ALTER WORKLOAD GROUP myWorkloadGroup1 WITH (MAX_DOP = 1) USING myPool1;
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

-- Reconnect in the other session and re-run the query
-- Resource governor sets the max dop to 1
-- ThreadStat : 0
-- Costs : 24,1803
-- Degree of parallelism : 0
-- No Non Parallel Plan Reason and query execution plan shows parallelism!
SELECT
	col1, COUNT (filler)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE);
GO

-- Get the resource workload group statistics for the workload group 
-- myWorkloadGroup1
-- Resource governor forces query to run in serial
-- max_dop : 1
-- effective_max_dop : 1
SELECT
	rpool.name AS resource_pools_name
  , rgroup.name AS workload_group_name
  , rgroup.statistics_start_time
  , rgroup.total_request_count
  , rgroup.active_request_count
  , rgroup.max_dop
  , rgroup.effective_max_dop
FROM
	sys.dm_resource_governor_resource_pools AS rpool
LEFT OUTER JOIN
	sys.dm_resource_governor_workload_groups AS rgroup
ON
	rpool.pool_id = rgroup.pool_id
WHERE
	rgroup.name = 'myWorkloadGroup1';
GO

-- Housekeeping
EXEC sys.sp_configure 'cost threshold for parallelism', 50;
RECONFIGURE;
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL);
GO
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO
DROP FUNCTION IF EXISTS dbo.fn_classifier
GO
DROP WORKLOAD GROUP myWorkloadGroup1
GO
DROP RESOURCE POOL myPool1
GO
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO
DROP LOGIN test_myWorkloadGroup1;
GO



/*******************************************************************************

	parallelism - system requirements
	cost threshold for parallelism

*******************************************************************************/

/*	
	
	The estimated cost to run a serial plan for a query is higher than the 
	value set in cost threshold for parallelism.

*/

-- Set cost threshold for parallelism to 5 (default)
EXEC sys.sp_configure 'cost threshold for parallelism', 5;
RECONFIGURE;
GO

-- cost threshold for parallelism : 5 (default)
SELECT
	name, value_in_use
FROM
	sys.configurations
WHERE
	name = N'cost threshold for parallelism';
GO

USE AdventureWorks2017;
GO

-- Force to run the query on one core only 
-- NonParallelPlanReason : MaxDOPSetToOne
-- Degree of Parallelism : 0
-- Costs : 29,125
SELECT
	col1, COUNT (col1)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE, MAXDOP 1);
GO

-- Query is running in parallel
-- Degree of Parallelism : 8
-- Costs : 29,125 > cost threshold for parallelism 5
-- Costs : 21,9063 | 29,125
SELECT
	col1, COUNT (col1)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE)
GO



-- A parallel plan is not considered due to the MAXDOP limitation
-- Search phase 1 and 2 are executed one time only each.
-- end search(1),  cost: 70712.3 tasks: 2539 time: 0 net: 0 total: 0 net: 0.01
-- end search(2),  cost: 70712.3 tasks: 2777 time: 0 net: 0 total: 0 net: 0.012
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

SELECT COUNT(*)
FROM
	Production.Product AS pr
INNER JOIN
	Production.ProductSubcategory AS su
ON
	pr.ProductSubcategoryID = su.ProductSubcategoryID
INNER JOIN
	Sales.SalesOrderDetail AS de
ON
	de.ProductID = pr.ProductID
LEFT JOIN
	Production.ProductSubcategory
ON
	pr.ProductSubcategoryID = pr.ProductSubcategoryID
INNER JOIN
	Sales.SpecialOffer AS soff
ON
	de.SpecialOfferID = soff.SpecialOfferID
LEFT JOIN
	Sales.SalesOrderHeader AS he
ON
	he.SalesOrderID = de.SalesOrderID
OPTION (MAXDOP 1, QUERYTRACEON 8675, QUERYTRACEON 3604);
GO

-- compile_time_ms : 14
-- compile_cpu_ms : 14
-- compile_memory_kb : 1376
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH XMLNAMESPACES
	(
		DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
	)
SELECT
	compile_time_ms
  , compile_cpu_ms
  , compile_memory_kb
  , qs.execution_count
  , qs.total_elapsed_time / 1000 AS duration_ms
  , qs.total_worker_time / 1000 AS cputime_ms
  , (qs.total_elapsed_time / qs.execution_count) / 1000 AS avg_duration_ms
  , (qs.total_worker_time / qs.execution_count) / 1000 AS avg_cputime_ms
  , qs.max_elapsed_time / 1000 AS max_duration_ms
  , qs.max_worker_time / 1000 AS max_cputime_ms
  , SUBSTRING (
				  st.text, (qs.statement_start_offset / 2) + 1
				, (CASE qs.statement_end_offset
					   WHEN -1
							THEN DATALENGTH (st.text)
					   ELSE qs.statement_end_offset
				   END - qs.statement_start_offset
				  ) / 2 + 1
			  ) AS statement_text
  , qs.query_hash
  , qs.query_plan_hash
FROM
	(
		SELECT
			c.value (
						'xs:hexBinary(substring((@QueryHash)[1],3))'
					  , 'varbinary(max)'
					) AS query_hash
		  , c.value (
						'xs:hexBinary(substring((@QueryPlanHash)[1],3))'
					  , 'varbinary(max)'
					) AS query_plan_hash
		  , c.value ('(QueryPlan/@CompileTime)[1]', 'int') AS compile_time_ms
		  , c.value ('(QueryPlan/@CompileCPU)[1]', 'int') AS compile_cpu_ms
		  , c.value ('(QueryPlan/@CompileMemory)[1]', 'int') AS compile_memory_kb
		  , qp.query_plan
		FROM
			sys.dm_exec_cached_plans AS cp
		CROSS APPLY sys.dm_exec_query_plan (cp.plan_handle) AS qp
		CROSS APPLY qp.query_plan.nodes ('ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS n(c)
	) AS tab
JOIN
	sys.dm_exec_query_stats AS qs
ON
	tab.query_hash = qs.query_hash
CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS st
WHERE
	qs.query_plan_hash IN (
						   0x42C35150C78B4D7C, 0x385846F82BCB64B4
					   )
ORDER BY
	compile_Memory_KB DESC
OPTION (RECOMPILE, MAXDOP 1);
GO

-- A parallel plan is considered.
-- Search phase 1 is executed two times.
-- First optimization in search phase 1 considers the serial plan the second 
-- considers the parallel plan.
-- end search(1),  cost: 70712.3 tasks: 2539 time: 0 net: 0 total: 0 net: 0.012
-- end search(1),  cost: 67414.8 tasks: 4744 time: 0 net: 0 total: 0 net: 0.022
-- end search(2),  cost: 67414.8 tasks: 5137 time: 0 net: 0 total: 0 net: 0.024
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

SELECT COUNT(*)
FROM
	Production.Product AS pr
INNER JOIN
	Production.ProductSubcategory AS su
ON
	pr.ProductSubcategoryID = su.ProductSubcategoryID
INNER JOIN
	Sales.SalesOrderDetail AS de
ON
	de.ProductID = pr.ProductID
LEFT JOIN
	Production.ProductSubcategory
ON
	pr.ProductSubcategoryID = pr.ProductSubcategoryID
INNER JOIN
	Sales.SpecialOffer AS soff
ON
	de.SpecialOfferID = soff.SpecialOfferID
LEFT JOIN
	Sales.SalesOrderHeader AS he
ON
	he.SalesOrderID = de.SalesOrderID
OPTION (QUERYTRACEON 8675, QUERYTRACEON 3604);
GO

-- Parallelism consumes more computing power and memory for compiling the execution plan
-- compile_time_ms : 26 (14)
-- compile_cpu_ms : 26 (14)
-- compile_memory_kb : 1752 (1376)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH XMLNAMESPACES
	(
		DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
	)
SELECT
	compile_time_ms
  , compile_cpu_ms
  , compile_memory_kb
  , qs.execution_count
  , qs.total_elapsed_time / 1000 AS duration_ms
  , qs.total_worker_time / 1000 AS cputime_ms
  , (qs.total_elapsed_time / qs.execution_count) / 1000 AS avg_duration_ms
  , (qs.total_worker_time / qs.execution_count) / 1000 AS avg_cputime_ms
  , qs.max_elapsed_time / 1000 AS max_duration_ms
  , qs.max_worker_time / 1000 AS max_cputime_ms
  , SUBSTRING (
				  st.text, (qs.statement_start_offset / 2) + 1
				, (CASE qs.statement_end_offset
					   WHEN -1
							THEN DATALENGTH (st.text)
					   ELSE qs.statement_end_offset
				   END - qs.statement_start_offset
				  ) / 2 + 1
			  ) AS statement_text
  , qs.query_hash
  , qs.query_plan_hash
FROM
	(
		SELECT
			c.value (
						'xs:hexBinary(substring((@QueryHash)[1],3))'
					  , 'varbinary(max)'
					) AS query_hash
		  , c.value (
						'xs:hexBinary(substring((@QueryPlanHash)[1],3))'
					  , 'varbinary(max)'
					) AS query_plan_hash
		  , c.value ('(QueryPlan/@CompileTime)[1]', 'int') AS compile_time_ms
		  , c.value ('(QueryPlan/@CompileCPU)[1]', 'int') AS compile_cpu_ms
		  , c.value ('(QueryPlan/@CompileMemory)[1]', 'int') AS compile_memory_kb
		  , qp.query_plan
		FROM
			sys.dm_exec_cached_plans AS cp
		CROSS APPLY sys.dm_exec_query_plan (cp.plan_handle) AS qp
		CROSS APPLY qp.query_plan.nodes ('ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS n(c)
	) AS tab
JOIN
	sys.dm_exec_query_stats AS qs
ON
	tab.query_hash = qs.query_hash
CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS st
WHERE
	qs.query_plan_hash IN (
						   0x42C35150C78B4D7C, 0x385846F82BCB64B4
					   )
ORDER BY
	compile_Memory_KB DESC
OPTION (RECOMPILE, MAXDOP 1);
GO

-- Housekeeping
EXEC sys.sp_configure 'cost threshold for parallelism', 5;
RECONFIGURE;
GO



/*******************************************************************************

	parallelism - QueryTraceOn 8649 and ENABLE_PARALLEL_PLAN_PREFERENCE

*******************************************************************************/

/*
	
	QueryTraceOn 8649 and the query hint ENABLE_PARALLEL_PLAN_PREFERENCE will 
	force SQL Server to use a parallel plan if possible.

*/

USE AdventureWorks2017;
GO

-- Set cost threshold for parallelism to 50
EXEC sys.sp_configure 'cost threshold for parallelism', 50;
RECONFIGURE;
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

-- Degree of Parallelism : 1
-- CPU time = 344 ms,  elapsed time = 431 ms.
-- Costs : 29,125
SELECT
	col1, COUNT (col1)
FROM
	big_table1
GROUP BY
	col1
OPTION (RECOMPILE)
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

-- Parallel plan forced by QueryTraceOn 8649
-- Almost no performance gain but keeping more CPUs bussy.
-- Degree of Parallelism : 8
-- CPU time = 1185 (344) ms,  elapsed time = 374 (431) ms
-- Costs : 21,9603 | 29,125
SELECT
	col1, COUNT (col1)
FROM
	big_table1
GROUP BY
	col1
OPTION (QUERYTRACEON 8649);
GO

-- Alternative
-- Parallel plan forced by ENABLE_PARALLEL_PLAN_PREFERENCE 8649
SELECT
	col1, COUNT (col1)
FROM
	big_table1
GROUP BY
	col1
OPTION (USE HINT ('ENABLE_PARALLEL_PLAN_PREFERENCE'));
GO

-- Housekeeping
EXEC sys.sp_configure 'cost threshold for parallelism', 50;
RECONFIGURE;
GO



/*******************************************************************************

	parallelism - processor affinity

*******************************************************************************/

/*

	To carry out multitasking, Microsoft Windows sometimes move threads among 
	different processors. Although efficient from an operating system point of 
	view, this activity can reduce SQL Server performance under heavy system 
	loads, as each processor cache is repeatedly reloaded with data. 
	Assigning processors to specific threads can improve performance under these 
	conditions by eliminating processor reloads and reducing thread migration 
	across processors, which reduces context switching. Such an association 
	between a thread and a processor is called processor affinity.

	By segregating SQL Server threads from running on particular processors, 
	Microsoft Windows can better evaluate the system's handling of processes 
	specific to Windows. 
	For example, on an 8-CPU server running two instances of SQL Server 
	(instance A and B), the system administrator could use the affinity mask 
	option to assign the first set of 4 CPUs to instance A and the second set 
	of 4 to instance.

	When using hardware-based non-uniform memory access (NUMA) and the affinity 
	mask is set, every scheduler in a node binds to its own CPU. When the 
	affinity mask is not set, each scheduler is bound to the group of CPUs within 
	the NUMA node and a scheduler mapped to NUMA node N1 can schedule work on 
	any CPU in the node, but not on CPUs associated with another node.

	Any operation running on a single NUMA node can only use buffer pages from 
	that node. When an operation is run in parallel on CPUs from multiple nodes, 
	memory can be used from any node involved.

*/

USE AdventureWorks2017;
GO

-- Set PROCESS AFFINITY CPU = AUTO (8 cores)
ALTER SERVER CONFIGURATION SET PROCESS AFFINITY CPU = AUTO;
GO

-- Confirm that queries can use more than on core
-- maximum degree of parallelism (DOP) on server and database level
-- max degree of parallelism : 0
-- max degree of parallelism = 0 or max degree of parallelism > 0
SELECT
	'server' AS level, name, value_in_use
FROM
	sys.configurations
WHERE
	name = N'max degree of parallelism'
UNION ALL
SELECT
	'database' AS level, name, value
FROM
	sys.database_scoped_configurations
WHERE
	name = N'MAXDOP'
GO

-- Set cost threshold for parallelism to 50
EXEC sys.sp_configure 'cost threshold for parallelism', 50;
RECONFIGURE;
GO

-- cost threshold for parallelism : 50
SELECT
	name, value_in_use
FROM
	sys.configurations
WHERE
	name = N'cost threshold for parallelism';
GO

-- MAXDOP : 1
-- Degree of Parallelism : 1
SELECT
	ProductID, COUNT(*)
FROM
	Sales.SalesOrderDetailMedium
GROUP BY
	ProductID
OPTION (RECOMPILE, MAXDOP 1);
GO

-- Open Resource Monitor
-- All eight cores are busy
-- The scheduler moves between the cores although MaxDOP is set to 1

-- Run in another session
-- Only one thread is used
-- affinity : 255 = 1111 1111 (the scheduler can use all 8 cores)
DECLARE @session_id AS int;
-- Adjust the @session_id
SET @session_id = 57;
SELECT
	thr.affinity
  , se.session_id AS session_id
  , DB_NAME(re.database_id) AS request_database_name
  , re.dop AS request_DOP
  , re.parallel_worker_count AS request_parallel_worker_count
  , SUBSTRING(
				 t.text, (re.statement_start_offset / 2) + 1
			   , ((CASE re.statement_end_offset
					   WHEN -1
							THEN DATALENGTH(t.text)
					   ELSE re.statement_end_offset
				   END - re.statement_start_offset
				  ) / 2
				 ) + 1
			 ) AS request_statement_text
  , query_plan AS request_sql_query_plan
  , ta.task_address AS task_address
  , ta.task_state AS task_state
  , ta.context_switches_count AS task_context_switches_count
  , ta.scheduler_id AS task_scheduler_id
  , ta.exec_context_id AS task_exec_context_id
  , sch.scheduler_id AS scheduler_id
  , sch.cpu_id AS scheduler_cpu_id
  , sch.status AS scheduler_status
  , sch.is_idle AS scheduler_is_idle
  , sch.preemptive_switches_count AS scheduler_preemptive_switches_count
  , sch.context_switches_count AS scheduler_context_switches_count
  , sch.current_tasks_count AS scheduler_current_tasks_count
  , sch.runnable_tasks_count AS scheduler_runnable_tasks_count
  , sch.current_workers_count AS scheduler_current_workers_count
  , sch.active_workers_count AS scheduler_active_workers_count
  , sch.work_queue_count AS scheduler_work_queue_count
  , wo.worker_address AS worker_address
  , wo.is_preemptive AS worker_is_preemptive
  , wo.context_switch_count AS worker_context_switch_count
  , wo.thread_address AS worker_thread_address
  , thr.os_thread_id AS os_thread_id
FROM
	sys.dm_exec_sessions AS se
LEFT JOIN
	sys.dm_exec_requests AS re
ON
	re.session_id = se.session_id
LEFT JOIN
	sys.dm_os_tasks AS ta
ON
	ta.session_id = re.session_id
LEFT JOIN
	sys.dm_os_schedulers AS sch
ON
	sch.scheduler_id = ta.scheduler_id
LEFT JOIN
	sys.dm_os_workers AS wo
ON
	wo.worker_address = ta.worker_address
LEFT JOIN
	sys.dm_os_threads AS thr
ON
	ta.worker_address = thr.worker_address
OUTER APPLY sys.dm_exec_sql_text(re.sql_handle) AS t
OUTER APPLY sys.dm_exec_query_plan(re.plan_handle) AS prd
WHERE
	is_user_process = 1
	AND se.session_id = @session_id;
GO



-- Degree of Parallelism : 8
SELECT
	ProductID, COUNT(*)
FROM
	Sales.SalesOrderDetailMedium
GROUP BY
	ProductID
OPTION (RECOMPILE);
GO

-- Open Resource Monitor
-- All eight cores are busy but CPU consumption is much higer since nine thrads
-- can work in parallel
-- The query uses nine threads on nine schedulers and the schedulers can move 
-- between the cores. 

-- Run in another session
-- All schedulers are busy
-- 17 threads on different schedulers
-- affinity : 255 = 1111 1111 (the scheduler can use all 8 cores)
DECLARE @session_id AS int;
-- Adjust the @session_id
SET @session_id = 57;
SELECT
	thr.affinity
  , se.session_id AS session_id
  , DB_NAME(re.database_id) AS request_database_name
  , re.dop AS request_DOP
  , re.parallel_worker_count AS request_parallel_worker_count
  , SUBSTRING(
				 t.text, (re.statement_start_offset / 2) + 1
			   , ((CASE re.statement_end_offset
					   WHEN -1
							THEN DATALENGTH(t.text)
					   ELSE re.statement_end_offset
				   END - re.statement_start_offset
				  ) / 2
				 ) + 1
			 ) AS request_statement_text
  , query_plan AS request_sql_query_plan
  , ta.task_address AS task_address
  , ta.task_state AS task_state
  , ta.context_switches_count AS task_context_switches_count
  , ta.scheduler_id AS task_scheduler_id
  , ta.exec_context_id AS task_exec_context_id
  , sch.scheduler_id AS scheduler_id
  , sch.cpu_id AS scheduler_cpu_id
  , sch.status AS scheduler_status
  , sch.is_idle AS scheduler_is_idle
  , sch.preemptive_switches_count AS scheduler_preemptive_switches_count
  , sch.context_switches_count AS scheduler_context_switches_count
  , sch.current_tasks_count AS scheduler_current_tasks_count
  , sch.runnable_tasks_count AS scheduler_runnable_tasks_count
  , sch.current_workers_count AS scheduler_current_workers_count
  , sch.active_workers_count AS scheduler_active_workers_count
  , sch.work_queue_count AS scheduler_work_queue_count
  , wo.worker_address AS worker_address
  , wo.is_preemptive AS worker_is_preemptive
  , wo.context_switch_count AS worker_context_switch_count
  , wo.thread_address AS worker_thread_address
  , thr.os_thread_id AS os_thread_id
FROM
	sys.dm_exec_sessions AS se
LEFT JOIN
	sys.dm_exec_requests AS re
ON
	re.session_id = se.session_id
LEFT JOIN
	sys.dm_os_tasks AS ta
ON
	ta.session_id = re.session_id
LEFT JOIN
	sys.dm_os_schedulers AS sch
ON
	sch.scheduler_id = ta.scheduler_id
LEFT JOIN
	sys.dm_os_workers AS wo
ON
	wo.worker_address = ta.worker_address
LEFT JOIN
	sys.dm_os_threads AS thr
ON
	ta.worker_address = thr.worker_address
OUTER APPLY sys.dm_exec_sql_text(re.sql_handle) AS t
OUTER APPLY sys.dm_exec_query_plan(re.plan_handle) AS prd
WHERE
	is_user_process = 1
	AND se.session_id = @session_id;
GO



-- Set PROCESS AFFINITY CPU = AUTO (2 cores)
ALTER SERVER CONFIGURATION SET PROCESS AFFINITY CPU = 1 TO 2;
GO

-- Only scheduler 1 and 2 or online
SELECT *
FROM
	sys.dm_os_schedulers
WHERE
	status <> N'HIDDEN ONLINE';
GO

-- MAXDOP : 1
-- Degree of Parallelism : 1
SELECT
	ProductID, COUNT(*)
FROM
	Sales.SalesOrderDetailMedium
GROUP BY
	ProductID
OPTION (RECOMPILE, MAXDOP 1);
GO

-- Open Resource Monitor
-- Only core 2 is busy
-- The query uses only one thread on one scheduler since the schedulers cannot 
-- move between the cores anymore due to the process affinity setting.

-- Run in another session
-- Only core 2 is busy 
-- The core is bound to scheduler 2
-- affinity : 4 = 0000 0100 (the scheduler can use core 3(2) only)
DECLARE @session_id AS int;
-- Adjust the @session_id
SET @session_id = 80;
SELECT
	thr.affinity
  , se.session_id AS session_id
  , DB_NAME(re.database_id) AS request_database_name
  , re.dop AS request_DOP
  , re.parallel_worker_count AS request_parallel_worker_count
  , SUBSTRING(
				 t.text, (re.statement_start_offset / 2) + 1
			   , ((CASE re.statement_end_offset
					   WHEN -1
							THEN DATALENGTH(t.text)
					   ELSE re.statement_end_offset
				   END - re.statement_start_offset
				  ) / 2
				 ) + 1
			 ) AS request_statement_text
  , query_plan AS request_sql_query_plan
  , ta.task_address AS task_address
  , ta.task_state AS task_state
  , ta.context_switches_count AS task_context_switches_count
  , ta.scheduler_id AS task_scheduler_id
  , ta.exec_context_id AS task_exec_context_id
  , sch.scheduler_id AS scheduler_id
  , sch.cpu_id AS scheduler_cpu_id
  , sch.status AS scheduler_status
  , sch.is_idle AS scheduler_is_idle
  , sch.preemptive_switches_count AS scheduler_preemptive_switches_count
  , sch.context_switches_count AS scheduler_context_switches_count
  , sch.current_tasks_count AS scheduler_current_tasks_count
  , sch.runnable_tasks_count AS scheduler_runnable_tasks_count
  , sch.current_workers_count AS scheduler_current_workers_count
  , sch.active_workers_count AS scheduler_active_workers_count
  , sch.work_queue_count AS scheduler_work_queue_count
  , wo.worker_address AS worker_address
  , wo.is_preemptive AS worker_is_preemptive
  , wo.context_switch_count AS worker_context_switch_count
  , wo.thread_address AS worker_thread_address
  , thr.os_thread_id AS os_thread_id
FROM
	sys.dm_exec_sessions AS se
LEFT JOIN
	sys.dm_exec_requests AS re
ON
	re.session_id = se.session_id
LEFT JOIN
	sys.dm_os_tasks AS ta
ON
	ta.session_id = re.session_id
LEFT JOIN
	sys.dm_os_schedulers AS sch
ON
	sch.scheduler_id = ta.scheduler_id
LEFT JOIN
	sys.dm_os_workers AS wo
ON
	wo.worker_address = ta.worker_address
LEFT JOIN
	sys.dm_os_threads AS thr
ON
	ta.worker_address = thr.worker_address
OUTER APPLY sys.dm_exec_sql_text(re.sql_handle) AS t
OUTER APPLY sys.dm_exec_query_plan(re.plan_handle) AS prd
WHERE
	is_user_process = 1
	AND se.session_id = @session_id;
GO



-- Degree of Parallelism : 2
SELECT
	ProductID, COUNT(*)
FROM
	Sales.SalesOrderDetailMedium
GROUP BY
	ProductID
OPTION (RECOMPILE);
GO

-- Open Resource Monitor
-- Only core 1 and 2 are busy
-- Core 2 is bound to scheduler 1
-- Core 3 is bound to scheduler 2
-- The query uses three threads on two scheduler and the schedulers cannot 
-- move between the cores anymore due to the process affinity setting.

-- Run in another session
-- 4 threads
-- Only core 1 and 2 are busy 
-- affinity : 2 = 0000 0010 (the scheduler can use core 2(1) only)
-- affinity : 4 = 0000 0100 (the scheduler can use core 3(2) only)
DECLARE @session_id AS int;
-- Adjust the @session_id
SET @session_id = 74;
SELECT
	thr.affinity
  , se.session_id AS session_id
  , DB_NAME(re.database_id) AS request_database_name
  , re.dop AS request_DOP
  , re.parallel_worker_count AS request_parallel_worker_count
  , SUBSTRING(
				 t.text, (re.statement_start_offset / 2) + 1
			   , ((CASE re.statement_end_offset
					   WHEN -1
							THEN DATALENGTH(t.text)
					   ELSE re.statement_end_offset
				   END - re.statement_start_offset
				  ) / 2
				 ) + 1
			 ) AS request_statement_text
  , query_plan AS request_sql_query_plan
  , ta.task_address AS task_address
  , ta.task_state AS task_state
  , ta.context_switches_count AS task_context_switches_count
  , ta.scheduler_id AS task_scheduler_id
  , ta.exec_context_id AS task_exec_context_id
  , sch.scheduler_id AS scheduler_id
  , sch.cpu_id AS scheduler_cpu_id
  , sch.status AS scheduler_status
  , sch.is_idle AS scheduler_is_idle
  , sch.preemptive_switches_count AS scheduler_preemptive_switches_count
  , sch.context_switches_count AS scheduler_context_switches_count
  , sch.current_tasks_count AS scheduler_current_tasks_count
  , sch.runnable_tasks_count AS scheduler_runnable_tasks_count
  , sch.current_workers_count AS scheduler_current_workers_count
  , sch.active_workers_count AS scheduler_active_workers_count
  , sch.work_queue_count AS scheduler_work_queue_count
  , wo.worker_address AS worker_address
  , wo.is_preemptive AS worker_is_preemptive
  , wo.context_switch_count AS worker_context_switch_count
  , wo.thread_address AS worker_thread_address
  , thr.os_thread_id AS os_thread_id
FROM
	sys.dm_exec_sessions AS se
LEFT JOIN
	sys.dm_exec_requests AS re
ON
	re.session_id = se.session_id
LEFT JOIN
	sys.dm_os_tasks AS ta
ON
	ta.session_id = re.session_id
LEFT JOIN
	sys.dm_os_schedulers AS sch
ON
	sch.scheduler_id = ta.scheduler_id
LEFT JOIN
	sys.dm_os_workers AS wo
ON
	wo.worker_address = ta.worker_address
LEFT JOIN
	sys.dm_os_threads AS thr
ON
	ta.worker_address = thr.worker_address
OUTER APPLY sys.dm_exec_sql_text(re.sql_handle) AS t
OUTER APPLY sys.dm_exec_query_plan(re.plan_handle) AS prd
WHERE
	is_user_process = 1
	AND se.session_id = @session_id;
GO


-- ! Skip - to less time !
https://docs.microsoft.com/en-us/sysinternals/downloads/cpustres

-- Produce a CPU workload of 100% on CPU1 (not CPU0)

-- Degree of Parallelism : 2
-- The query is almost blocked without using Traceflag 8002 
SELECT
	ProductID, COUNT(*)
FROM
	Sales.SalesOrderDetailMedium
GROUP BY
	ProductID
OPTION (RECOMPILE);
GO

-- Run in another session
-- Only core 2 is busy 
-- affinity : 2 = 0000 0010 (the scheduler can use core 2(1) only)
-- affinity : 4 = 0000 0100 (the scheduler can use core 3(2) only)
-- Core 1 : SUSPENDED | scheduler_runnable_tasks_count : 0
DECLARE @session_id AS int;
-- Adjust the @session_id
SET @session_id = 74;
SELECT
	thr.affinity
  , se.session_id AS session_id
  , DB_NAME(re.database_id) AS request_database_name
  , re.dop AS request_DOP
  , re.parallel_worker_count AS request_parallel_worker_count
  , SUBSTRING(
				 t.text, (re.statement_start_offset / 2) + 1
			   , ((CASE re.statement_end_offset
					   WHEN -1
							THEN DATALENGTH(t.text)
					   ELSE re.statement_end_offset
				   END - re.statement_start_offset
				  ) / 2
				 ) + 1
			 ) AS request_statement_text
  , query_plan AS request_sql_query_plan
  , ta.task_address AS task_address
  , ta.task_state AS task_state
  , ta.context_switches_count AS task_context_switches_count
  , ta.scheduler_id AS task_scheduler_id
  , ta.exec_context_id AS task_exec_context_id
  , sch.scheduler_id AS scheduler_id
  , sch.cpu_id AS scheduler_cpu_id
  , sch.status AS scheduler_status
  , sch.is_idle AS scheduler_is_idle
  , sch.preemptive_switches_count AS scheduler_preemptive_switches_count
  , sch.context_switches_count AS scheduler_context_switches_count
  , sch.current_tasks_count AS scheduler_current_tasks_count
  , sch.runnable_tasks_count AS scheduler_runnable_tasks_count
  , sch.current_workers_count AS scheduler_current_workers_count
  , sch.active_workers_count AS scheduler_active_workers_count
  , sch.work_queue_count AS scheduler_work_queue_count
  , wo.worker_address AS worker_address
  , wo.is_preemptive AS worker_is_preemptive
  , wo.context_switch_count AS worker_context_switch_count
  , wo.thread_address AS worker_thread_address
  , thr.os_thread_id AS os_thread_id
FROM
	sys.dm_exec_sessions AS se
LEFT JOIN
	sys.dm_exec_requests AS re
ON
	re.session_id = se.session_id
LEFT JOIN
	sys.dm_os_tasks AS ta
ON
	ta.session_id = re.session_id
LEFT JOIN
	sys.dm_os_schedulers AS sch
ON
	sch.scheduler_id = ta.scheduler_id
LEFT JOIN
	sys.dm_os_workers AS wo
ON
	wo.worker_address = ta.worker_address
LEFT JOIN
	sys.dm_os_threads AS thr
ON
	ta.worker_address = thr.worker_address
OUTER APPLY sys.dm_exec_sql_text(re.sql_handle) AS t
OUTER APPLY sys.dm_exec_query_plan(re.plan_handle) AS prd
WHERE
	is_user_process = 1
	AND se.session_id = @session_id;
GO


-- Enable TraceFlag 8002 in the startup parameter and restart SQL Server


/*

	https://docs.microsoft.com/de-de/archive/blogs/psssql/sql-server-clarifying-the-numa-configuration-information

	Trace flag 8002 is used to treat the affinity mask as a group setting. 
	Usually the affinity mask sets the threads on the scheduler to only use one 
	CPU for the matching affinity bit. The trace flag tells SQL OS to treat the 
	mask as a group (process affinity like). It groups the bits for the same node 
	toghether and allow any scheduler ONLINE for that node to use any of the CPUs 
	that match the bits.

	Let us say you had the following affinity for NODE 0 on the system.

	0011 - Use CPU 1 and CPU 2

	Without trace flag you would get a scheduler for CPU 1 and a scheduler for 
	CPU 2. The workers on scheduler 1 could only use CPU 1 and the workers on 
	scheduler 2 could only use CPU 2.

	With the trace flag you get the same scheduler layout but the thread on 
	scheduler 1 and scheduler 2 would set their affinity mask to 11 so they 
	could run on either CPU 1 or CPU 2. This allows you to configure an instance 
	of SQL to use a specific set of CPUs but not lock each scheduler into their 
	respective CPUs, allowing Windows to move the threads on a per CPU resource 
	use need.

*/

-- Ensure that trace flag 8002 is set
DBCC TRACEON(3604, -1);
DBCC TRACESTATUS;
GO

https://docs.microsoft.com/en-us/sysinternals/downloads/cpustres

-- Produce a CPU workload of 100% on CPU1 or CPU2

-- Traceflag 8002
-- Degree of Parallelism : 2
-- This time the query is not blocked since the schedulers can move from the 
-- busy core to the other idle core.
SELECT
	ProductID, COUNT(*)
FROM
	Sales.SalesOrderDetailMedium
GROUP BY
	ProductID
OPTION (RECOMPILE);
GO

-- Run in another session
-- Only core 2 is busy 
-- affinity : 6 = 0000 0110 (the scheduler can use core 2(1) and core 3(2))
-- Core 1 : SUSPENDED | scheduler_runnable_tasks_count : 0
DECLARE @session_id AS int;
-- Adjust the @session_id
SET @session_id = 60;
SELECT
	thr.affinity
  , se.session_id AS session_id
  , DB_NAME(re.database_id) AS request_database_name
  , re.dop AS request_DOP
  , re.parallel_worker_count AS request_parallel_worker_count
  , SUBSTRING(
				 t.text, (re.statement_start_offset / 2) + 1
			   , ((CASE re.statement_end_offset
					   WHEN -1
							THEN DATALENGTH(t.text)
					   ELSE re.statement_end_offset
				   END - re.statement_start_offset
				  ) / 2
				 ) + 1
			 ) AS request_statement_text
  , query_plan AS request_sql_query_plan
  , ta.task_address AS task_address
  , ta.task_state AS task_state
  , ta.context_switches_count AS task_context_switches_count
  , ta.scheduler_id AS task_scheduler_id
  , ta.exec_context_id AS task_exec_context_id
  , sch.scheduler_id AS scheduler_id
  , sch.cpu_id AS scheduler_cpu_id
  , sch.status AS scheduler_status
  , sch.is_idle AS scheduler_is_idle
  , sch.preemptive_switches_count AS scheduler_preemptive_switches_count
  , sch.context_switches_count AS scheduler_context_switches_count
  , sch.current_tasks_count AS scheduler_current_tasks_count
  , sch.runnable_tasks_count AS scheduler_runnable_tasks_count
  , sch.current_workers_count AS scheduler_current_workers_count
  , sch.active_workers_count AS scheduler_active_workers_count
  , sch.work_queue_count AS scheduler_work_queue_count
  , wo.worker_address AS worker_address
  , wo.is_preemptive AS worker_is_preemptive
  , wo.context_switch_count AS worker_context_switch_count
  , wo.thread_address AS worker_thread_address
  , thr.os_thread_id AS os_thread_id
FROM
	sys.dm_exec_sessions AS se
LEFT JOIN
	sys.dm_exec_requests AS re
ON
	re.session_id = se.session_id
LEFT JOIN
	sys.dm_os_tasks AS ta
ON
	ta.session_id = re.session_id
LEFT JOIN
	sys.dm_os_schedulers AS sch
ON
	sch.scheduler_id = ta.scheduler_id
LEFT JOIN
	sys.dm_os_workers AS wo
ON
	wo.worker_address = ta.worker_address
LEFT JOIN
	sys.dm_os_threads AS thr
ON
	ta.worker_address = thr.worker_address
OUTER APPLY sys.dm_exec_sql_text(re.sql_handle) AS t
OUTER APPLY sys.dm_exec_query_plan(re.plan_handle) AS prd
WHERE
	is_user_process = 1
	AND se.session_id = @session_id;
GO

-- Housekeeping
ALTER SERVER CONFIGURATION SET PROCESS AFFINITY CPU = AUTO;
GO

-- Disable TraceFlag 8002 in the startup parameter and restart SQL Server
DBCC TRACEON(3604, -1);
DBCC TRACESTATUS;
GO



/*******************************************************************************

	parallelism - NUMA

*******************************************************************************/

/*
	
	SQL Server memory nodes are mapped directly to the hardware NUMA nodes in 
	order to reduce the need for remote memory access.

*/

-- Get NUMA details
-- node_id : 0 | cpu_affinity_mask : 255 
-- Cores assigned to NUMA node 0
-- 0000 0000 1111 1111
-- node_id : 1 | cpu_affinity_mask : 65280 
-- Cores assigned to NUMA node 1
-- 1111 1111 0000 0000
SELECT
	online_scheduler_mask, *
FROM
	sys.dm_os_nodes;
GO

-- Memory nodes are aligned, and stay aligned, with the memory locality per CPU 
-- presented by the operating system
-- memory_node_id : 0 | cpu_affinity_mask : 255 ( 0000 0000 1111 1111 )
-- memory_node_id : 1 | cpu_affinity_mask : 65280 ( 1111 1111 0000 0000 )
SELECT * FROM sys.dm_os_memory_nodes;
GO

-- Skip
-- Get the cache types which can be saved in the memory nodes
SELECT DISTINCT
	type, name
FROM
	sys.dm_os_memory_clerks
ORDER BY
	type, name;
GO

-- Get the set of all memory clerks with their numa assignment
SELECT
	parent_memory_broker_type
  , type
  , name
  , memory_node_id
  , virtual_memory_committed_kb
  , shared_memory_committed_kb
  , pages_kb
FROM
	sys.dm_os_memory_clerks;
GO

-- Skip
-- Get the cache types which allocate memory in the numa nodes
-- All caches can be created on all available nodes despite the lock manager
-- Lock Manager : Node 0 
-- Uneven distribution
SELECT
	type
  , memory_node_id
  , SUM(virtual_memory_committed_kb) AS virtual_memory_committed_kb
  , SUM(shared_memory_committed_kb) AS shared_memory_committed_kb
  , SUM(pages_kb) AS pages_kb
FROM
	sys.dm_os_memory_clerks
WHERE
	virtual_memory_committed_kb > 0
	OR shared_memory_committed_kb > 0
	OR pages_kb > 0
GROUP BY
	type, name, memory_node_id
ORDER BY
	type, memory_node_id;
GO


USE master;
GO

-- Create a table
DROP TABLE IF EXISTS test;
GO

CREATE TABLE test ( col1 int NOT NULL);
GO

WITH cte
AS
	(
		SELECT numbers.col1
		FROM ( VALUES ( 0 )
			   ,	  ( 1 )
			   ,	  ( 2 )
			   ,	  ( 3 )
			   ,	  ( 4 )
			   ,	  ( 5 )
			   ,	  ( 6 )
			   ,	  ( 7 )
			   ,	  ( 8 )
			   ,	  ( 9 )
			 ) AS numbers ( col1 )
	)
INSERT dbo.test
	(
		col1
	)
SELECT (c1.col1 * 100000 + c2.col1 * 10000 + c3.col1 * 1000 + c4.col1 * 100
		+ c5.col1 * 10 + c6.col1 * 1
	   ) % 2
FROM
	cte AS c1
CROSS JOIN cte AS c2
CROSS JOIN cte AS c3
CROSS JOIN cte AS c4
CROSS JOIN cte AS c5
CROSS JOIN cte AS c6
GO

-- Set cost threshold for parallelism to 5 (default)
-- Set max degree of parallelism to 8 (cores in one NUMA)
EXEC sys.sp_configure N'show advanced options', N'1';
RECONFIGURE;
EXEC sys.sp_configure N'cost threshold for parallelism', N'5';
EXEC sys.sp_configure N'max degree of parallelism', N'8'
RECONFIGURE;
EXEC sys.sp_configure N'show advanced options', N'0';
RECONFIGURE;
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

-- cost threshold for parallelism : 5
-- max degree of parallelism : 8
SELECT
	name, value_in_use
FROM
	sys.configurations
WHERE
	name = N'cost threshold for parallelism'
	OR name LIKE 'max degree of parallelism';
GO

CHECKPOINT;
DBCC DROPCLEANBUFFERS;

-- memory_node_id : 0 | pages_kb : 8720
-- memory_node_id : 1 | pages_kb : 17944
SELECT
	type, memory_node_id, pages_kb
FROM
	sys.dm_os_memory_clerks
WHERE
	type = N'MEMORYCLERK_SQLBUFFERPOOL';
GO

-- Query is running in parallel
-- Degree of Parallelism : 8
SELECT
	col1, COUNT (col1)
FROM
	test
GROUP BY
	col1
OPTION (RECOMPILE);
GO

-- Only memory_node_id 1 saves MEMORYCLERK_SQLBUFFERPOOL
-- memory_node_id : 0 | pages_kb : 8720 (6064)
-- memory_node_id : 1 | pages_kb : 42856 (36864)
SELECT
	type, memory_node_id, pages_kb
FROM
	sys.dm_os_memory_clerks
WHERE
	type = N'MEMORYCLERK_SQLBUFFERPOOL';
GO

-- Set max degree of parallelism to 0 (all cores from two NUMA nodes)
EXEC sys.sp_configure N'show advanced options', N'1';
RECONFIGURE;
EXEC sys.sp_configure N'cost threshold for parallelism', N'5';
EXEC sys.sp_configure N'max degree of parallelism', N'0'
RECONFIGURE;
EXEC sys.sp_configure N'show advanced options', N'0';
RECONFIGURE;
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

-- cost threshold for parallelism : 5
-- max degree of parallelism : 0
SELECT
	name, value_in_use
FROM
	sys.configurations
WHERE
	name = N'cost threshold for parallelism'
	OR name LIKE 'max degree of parallelism';
GO

CHECKPOINT;
DBCC DROPCLEANBUFFERS;

-- memory_node_id : 0 | pages_kb : 6224
-- memory_node_id : 1 | pages_kb : 13496
SELECT
	type, memory_node_id, pages_kb
FROM
	sys.dm_os_memory_clerks
WHERE
	type = N'MEMORYCLERK_SQLBUFFERPOOL';
GO

-- Query is running in parallel
-- Degree of Parallelism : 16
SELECT
	col1, COUNT (col1)
FROM
	test
GROUP BY
	col1
OPTION (RECOMPILE);
GO

-- Exchanging memory between the numa nodes is much slower than within the same
-- nume node.
-- Both memory_node_ids save MEMORYCLERK_SQLBUFFERPOOL
-- memory_node_id : 0 | pages_kb : 18040 (8600)
-- memory_node_id : 1 | pages_kb : 26096 (10144)
SELECT
	type, memory_node_id, pages_kb
FROM
	sys.dm_os_memory_clerks
WHERE
	type = N'MEMORYCLERK_SQLBUFFERPOOL';
GO

-- Housekeeping
EXEC sys.sp_configure N'show advanced options', N'1';
RECONFIGURE;
EXEC sys.sp_configure N'cost threshold for parallelism', N'50';
EXEC sys.sp_configure N'max degree of parallelism', N'8'
RECONFIGURE;
EXEC sys.sp_configure N'show advanced options', N'0';
RECONFIGURE;
GO



/*******************************************************************************

	parallelism - NUMA - latency

*******************************************************************************/

	https://docs.microsoft.com/en-us/sysinternals/downloads/coreinfo

	-- coreinfo.exe
	-- Coreinfo evaluates the approximate cross-NUMA Node access cost.
	-- Ensure that MAXDOP is set according to the NUMA architecture.

/*

	Logical Processor to NUMA Node Map:
	********--------  NUMA Node 0
	--------********  NUMA Node 1

	Approximate Cross-NUMA Node Access Cost (relative to fastest):
		 00  01
	00: 1.0 1.3
	01: 1.2 1.0

*/

/*

	miscellaneous \ Parallelism MAXDOP.xlsx

	Starting with SQL Server 2016 (13.x), during service startup if the 
	Database Engine detects more than eight physical cores per NUMA node or 
	socket at startup, soft-NUMA nodes are created automatically by default. 
	The Database Engine places logical processors from the same physical core 
	into different soft-NUMA nodes. The recommendations in the table below are 
	aimed at keeping all the worker threads of a parallel query within the same 
	soft-NUMA node. This will improve the performance of the queries and 
	distribution of worker threads across the NUMA nodes for the workload.

*/

-- Get the soft numa configuration for machines with more than eight physical 
-- cores per NUMA node.
SELECT
	softnuma_configuration, softnuma_configuration_desc
FROM
	sys.dm_os_sys_info;
GO



/*******************************************************************************

	parallelism - query execution time

*******************************************************************************/

USE AdventureWorks2017
GO

SET STATISTICS TIME ON;
GO

-- Set cost threshold for parallelism to 5 (default)
EXEC sys.sp_configure N'cost threshold for parallelism', N'5';
RECONFIGURE;
GO

CHECKPOINT
DBCC DROPCLEANBUFFERS;
GO

-- Execute in another session without discarding the results
-- Parallel execution with 8 cores
-- CXPACKET and CXCONSUMER waits
SELECT *
FROM
	dbo.big_table1 AS t1
INNER JOIN
	dbo.big_table1 AS t2
ON
	t1.col1 = t2.col1
	AND t1.col2 = t2.col2
OPTION (RECOMPILE);
--OPTION (RECOMPILE, MAXDOP 1);
--OPTION (RECOMPILE, MAXDOP 2);
--OPTION (RECOMPILE, MAXDOP 3);
--OPTION (RECOMPILE, MAXDOP 4);
--OPTION (RECOMPILE, MAXDOP 5);
--OPTION (RECOMPILE, MAXDOP 6);
--OPTION (RECOMPILE, MAXDOP 7);
GO

-- Set SPID accordingly
-- CXPACKET : 4103
-- CXCONSUMER : 0
DECLARE @session_id int = 71;
SELECT *
FROM
	sys.dm_exec_session_wait_stats
WHERE
	session_id = @session_id
	AND wait_type IN (
						 'CXPACKET', 'CXCONSUMER'
					 );
GO

CHECKPOINT
DBCC DROPCLEANBUFFERS;
GO

-- Execute in another session
-- Serial execution 
SELECT *
FROM
	dbo.big_table1 AS t1
INNER JOIN
	dbo.big_table1 AS t2
ON
	t1.col1 = t2.col1
	AND t1.col2 = t2.col2
OPTION (RECOMPILE, MAXDOP 1);
GO

-- Set SPID accordingly
-- CXPACKET : 0
-- CXCONSUMER : 0
DECLARE @session_id int = 62;
SELECT *
FROM
	sys.dm_exec_session_wait_stats
WHERE
	session_id = @session_id
	AND wait_type IN (
						 'CXPACKET', 'CXCONSUMER'
					 );
GO

-- Housekeeping
EXEC sys.sp_configure N'cost threshold for parallelism', N'50';
RECONFIGURE;
GO

/*

	miscellaneous \ parallel query time and waits.pbix

	The parallel execution of the query causes an overhead resulting in longer 
	execution time, CXPACKET and CXCONSUMER waits. The more cores working for 
	the query, the longer the query waits for CXPACKET and CXCONSUMER and the 
	longer the total execution time but the CPU time in ms per core is almost 
	the same for all different parallelization degrees.

*/



/*******************************************************************************

	parallelism  - CXPACKET (Class Exchange Packet)

*******************************************************************************/

/*

	The CXPACKET wait type occurs whenever a query is being executed in
	parallel instead of serially.

	Parallel queries will use multiple worker threads to execute a request. 
	Along with the worker threads that are created to perform the work 
	requested, a parallel query will also use a 0 thread. 
	This 0 thread (control thread) is to coordinate the work of the other 
	worker threads.

	While the 0 thread is waiting for the other worker threads to finish the 
	work they were assigned to perform, it will record wait times of the 
	CXPACKET Wait Type.
	The SQL Server CXPACKET wait type is always present in parallel execution 
	even under an ideal scenario.
	
	A query will be as fast as the slowest thread.

	An exchange operator which executes in parallel has n producer threads 
	(MAXDOP) and n consumer threads (MAXDOP). 
	
	The maximum number of threads a repartiton streams operator can use is 
	2 * MAXDOP + 1, for example 2 * 8 + 1 = 17 threads.
	The maximum number of threads a distribute streams operator can use is 
	1 * MAXDOP + 1 + 1, for example 1 * 8 + 1 + 1 = 10 threads.
	The maximum number of threads a gather streams operator can use is 
	1 * MAXDOP + 1 + 1, for example 1 * 8 + 1 + 1 = 10 threads.

	The producers push data to consumers. Therefore the consumers may have to 
	wait for the data the producers pushes. 
	Consequently, the producer waits are the ones that may require attention, 
	while consumer waits are a passive consequence of longer running producers.
	
	To avoid CXPACKET

	*	Reduce query complexitiy and implement supportive indexes.
		
	*	Change the Cost Threshold for Parallelism so that the threshold is high 
		enough that your large queries can benefit from using parallelism but 
		your small queries do not experience a negative impact.

	*	Lowering the Max Degree of Parallelism
		
	*	Improving cardinality estimations if actual rows are very different 
		from estimations. Improving estimations can include actions such as 
		updating or adding statistics, revising the underlying index design.

	CXCONSUMER 
	Occurs when a consumer thread waits for a producer thread to send rows.
	This is a wait type that is a normal part of parallel query execution, and 
	cannot be directly influenced by changing the above mentioned 
	configurations.

	If CXPACKET is accompanied by a PAGEIOLATCH_XX, it is a sign that the speed 
	of the disk is too slow to satisfy the number of parallel read and write 
	requests. In this case it is better to reduce MAXDOP.

	If CXPACKET is accompanied by an LCK_M_XX, this is an indication that 
	parallelism is not the cause of the wait. The reason for high CXPACKET is a 
	lock on whose release a thread must wait.
	
*/



/*******************************************************************************

	parallelism - actionable CXPACKET

*******************************************************************************/

USE AdventureWorks2017;
GO

-- Set cost threshold for parallelism to 5
EXEC sys.sp_configure N'cost threshold for parallelism', N'5';
RECONFIGURE
GO

-- cost threshold for parallelism : 5
-- max degree of parallelism : 0 | 8
SELECT
	name, value_in_use
FROM
	sys.configurations
WHERE
	name = N'cost threshold for parallelism'
	OR name LIKE 'max degree of parallelism';
GO

-- Create a heap
DROP TABLE IF EXISTS dbo.SalesOrderDetail;
GO

SELECT *
INTO SalesOrderDetail
FROM
	Sales.SalesOrderDetail;
GO

-- Reset the wait stats
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
GO

SET STATISTICS IO, TIME ON;
GO

-- Update one record but leave the transaction open
BEGIN TRAN;
UPDATE SalesOrderDetail
SET OrderQty = 2
WHERE
	SalesOrderID = 45165;
GO

-- Execute in another session
-- The query is blocked
SELECT
	SalesOrderID
  , SalesOrderDetailID
  , CarrierTrackingNumber
  , OrderQty
  , ProductID
  , ModifiedDate
FROM
	dbo.SalesOrderDetail
ORDER BY
	OrderQty DESC
OPTION (RECOMPILE);
GO

-- Get details per operator per thread
-- The Table Scan and Sort operator threads are waiting for a LCK_M_S
-- All others report CXPACKET
DECLARE @session_id int = 57;
SELECT
	ot.session_id
  , eqp.node_id
  , ot.scheduler_id
  , eqp.physical_operator_name
  , last_wait_type
  , task_state
  , exec_context_id
  -- , worker_migration_count
  , sql_handle
  , plan_handle
  , row_count
  , estimate_row_count
FROM
	sys.dm_os_tasks AS ot
LEFT JOIN
	sys.dm_os_workers AS ow
ON
	ot.worker_address = ow.worker_address
LEFT JOIN
	sys.dm_exec_query_profiles AS eqp
ON
	ow.task_address = eqp.task_address
WHERE
	ot.session_id = @session_id
ORDER BY
	session_id, scheduler_id, node_id;
GO

-- The session reading SalesOrderDetail is blocked by the session updating the 
-- table at the same time
EXECUTE sp_who2;
GO

-- LCK_M_S and CXPACKET
-- The high CXPACKET is caused by LCK_M_S
DECLARE @session_id int = 57;
SELECT *
FROM
	sys.dm_os_waiting_tasks
WHERE
	session_id = @session_id
GO

-- Rollback the update statement
ROLLBACK
GO	

-- LCK_M_S and CXPACKET
SELECT *
FROM
	sys.dm_os_wait_stats
WHERE
	wait_type IN (
					 'LCK_M_S', 'CXPACKET', 'CXCONSUMER'
				 )
ORDER BY
	wait_time_ms DESC;
GO

-- Housekeeping
DROP TABLE IF EXISTS dbo.SalesOrderDetail;
EXEC sys.sp_configure N'cost threshold for parallelism', N'50';
RECONFIGURE;
GO



/*******************************************************************************

	parallelism - threadpool starvation

*******************************************************************************/

/*

	Thread pool starvation occurs when there are no more free worker threads 
	available to process requests. 
	When this situation occurs, tasks that are currently waiting to be assigned
	to a worker thread will log the THREADPOOL Wait Type.
	
	The number of available worker threads are dependend on the number of CPUs
	and the OS architecture (32/64bit).

	Changing the setting "Maximum Worker Threads" to a higher value than the
	default can actually degrade the performance of your SQL Server because
	context-switching occurs far more often. 
	Another reason not to change the setting is that every worker thread 
	requires a bit of memory to operate; for 32-bit systems this is 512 KB per
	worker thread, and for 64-bit systems it is 2048 KB.

	On a very busy SQL Server Database Engine, it is possible to see a number 
	of active tasks that is over the limit set by reserved threads. These tasks 
	can belong to a branch that is not being used anymore and are in a 
	transient state, waiting for cleanup.

*/

-- Get the maximum number of worker threads
SELECT max_workers_count FROM sys.dm_os_sys_info;
GO

USE AdventureWorks2017;
GO

-- Set max worker threads to 128
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'max worker threads', 128;
RECONFIGURE;
GO

-- Get the maximum number of worker threads
SELECT max_workers_count FROM sys.dm_os_sys_info;
GO

-- Set cost threshold for parallelism to 5 (default)
EXEC sys.sp_configure N'cost threshold for parallelism', N'5';
RECONFIGURE;
GO

-- cost threshold for parallelism : 5
-- max degree of parallelism : 0 | 8
SELECT
	name, value_in_use
FROM
	sys.configurations
WHERE
	name = N'cost threshold for parallelism'
	OR name LIKE 'max degree of parallelism';
GO

-- Force a serial plan!
-- Degree of Parallelism : 0
-- Costs : 47,0002
SELECT *
FROM
	Sales.SalesOrderDetailSmall
ORDER BY
	OrderQty DESC
OPTION (MAXDOP 1);
GO

-- Reset wait statistics
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
GO

-- execution time : 37 seconds
-- Run the SQL statement 2 times on 80 threads (configured : 128)
-- "ostress.exe" -SMYPC\MYSQLSERVER2019A -dAdventureWorks2017 -Q"SELECT * FROM Sales.SalesOrderDetailSmall ORDER BY OrderQty DESC OPTION (MAXDOP 1);" -n80 -r2 -q

-- Get request details
SELECT
	se.session_id AS session_id
  , DB_NAME(re.database_id) AS request_database_name
  , re.status AS request_status
  , re.dop AS request_dop
  , re.parallel_worker_count AS request_parallel_worker_count
  , SUBSTRING(
				 t.text, (re.statement_start_offset / 2) + 1
			   , ((CASE re.statement_end_offset
					   WHEN -1
							THEN DATALENGTH(t.text)
					   ELSE re.statement_end_offset
				   END - re.statement_start_offset
				  ) / 2
				 ) + 1
			 ) AS request_statement_text
  , ta.task_address AS task_address
  , ta.task_state AS task_state
  , ta.context_switches_count AS task_context_switches_count
  , ta.exec_context_id AS task_exec_context_id
  , sch.scheduler_id AS scheduler_id
  , sch.cpu_id AS scheduler_cpu_id
  , sch.status AS scheduler_status
  , sch.is_idle AS scheduler_is_idle
  , sch.preemptive_switches_count AS scheduler_preemptive_switches_count
  , sch.context_switches_count AS scheduler_context_switches_count
  , sch.current_tasks_count AS scheduler_current_tasks_count
  , sch.runnable_tasks_count AS scheduler_runnable_tasks_count
  , sch.current_workers_count AS scheduler_current_workers_count
  , sch.active_workers_count AS scheduler_active_workers_count
  , sch.work_queue_count AS scheduler_work_queue_count
  , wo.worker_address AS worker_address
  , wo.is_preemptive AS worker_is_preemptive
  , wo.context_switch_count AS worker_context_switch_count
  , wo.state AS worker_state
  , thr.os_thread_id AS os_thread_id
FROM
	sys.dm_exec_sessions AS se WITH (NOLOCK)
LEFT JOIN
	sys.dm_exec_requests AS re WITH (NOLOCK)
ON
	re.session_id = se.session_id
LEFT JOIN
	sys.dm_resource_governor_resource_pools AS po WITH (NOLOCK)
ON
	re.group_id = po.pool_id
LEFT JOIN
	sys.dm_os_tasks AS ta WITH (NOLOCK)
ON
	ta.session_id = re.session_id
LEFT JOIN
	sys.dm_os_schedulers AS sch WITH (NOLOCK)
ON
	sch.scheduler_id = ta.scheduler_id
LEFT JOIN
	sys.dm_os_workers AS wo WITH (NOLOCK)
ON
	wo.worker_address = ta.worker_address
LEFT JOIN
	sys.dm_os_threads AS thr WITH (NOLOCK)
ON
	ta.worker_address = thr.worker_address
OUTER APPLY sys.dm_exec_sql_text(re.plan_handle) AS t
OUTER APPLY sys.dm_exec_query_plan(re.plan_handle) AS prd
WHERE
	is_user_process = 1;
GO

-- work_queue_count : 0
-- Number of schedulers for user requests (VISIBLE) is equal to the number of
-- logical CPUs
-- Current_tasks_count :
--	Number of current tasks that are associated with this scheduler. 
-- This count includes the following: 
--	Tasks that are waiting for a worker to execute them. 
--	Tasks that are currently waiting or running (in SUSPENDED or RUNNABLE state).
-- Runnable_tasks_count :
--	Number of workers, with tasks assigned to them, that are waiting to be
--	scheduled on the runnable queue
-- Current_workers_count :
--	Number of workers that are associated with this scheduler. 
--	This count includes workers that are not assigned any task
-- Active_workers_count :
--	Number of workers that are active. 
--	An active worker is never preemptive, must have an associated task, 
--	and is either running, runnable, or suspended
-- Work_queue_count :
--	Number of tasks in the pending queue. 
--	These tasks are waiting for a worker to pick them up
SELECT
	scheduler_id
,	current_tasks_count
,	runnable_tasks_count
,	current_workers_count
,	active_workers_count
,	work_queue_count
FROM sys.dm_os_schedulers WITH (NOLOCK)
WHERE status = 'VISIBLE ONLINE';
GO

-- No CXPACKET nor THREADPOOL
-- Wait_type : THREADPOOL
-- Wait_type : CXPACKET
SELECT *
FROM sys.dm_os_waiting_tasks WITH (NOLOCK)
WHERE
	wait_type IN ('THREADPOOL', 'CXPACKET');
GO

-- Get the wait statistics
-- THREADPOOL : 0
-- CXPACKET : 0
SELECT *
FROM
	sys.dm_os_wait_stats
WHERE
	wait_type IN (
					 'THREADPOOL', 'CXPACKET'
				 );
GO

-- Reset wait statistics
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
GO


-- Degree of Parallelism : 8
-- ThreadStat.Branches : 1
-- ThreadReservation.ReservedThreads : 8
SELECT *
FROM
	Sales.SalesOrderDetailSmall
ORDER BY
	OrderQty DESC;
GO 



-- Reset wait statistics
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
GO

-- 80 concurrent threads x max 8 threads per query = max 240 threads
-- Run the SQL statement 2 times on 80 threads (configured : 128)
-- "ostress.exe" -SMYPC\MYSQLSERVER2019A -dAdventureWorks2017 -Q"SELECT * FROM Sales.SalesOrderDetailSmall ORDER BY OrderQty DESC;" -n80 -r2 -q

/*

	The number of worker threads spawned for each task depends on the actual 
	available degree of parallelism (DOP) in the system based on current load. 
	This may differ from estimated DOP, which is based on the server 
	configuration for max degree of parallelism (MAXDOP). For example, the server
	configuration for MAXDOP may be 8 but the available DOP at runtime can be 
	only 2, which affects query performance.

	When a query or index operation starts executing on multiple worker threads 
	for parallel execution, the same number of worker threads is used until the 
	operation is completed. The SQL Server Database Engine re-examines the optimal 
	number of worker thread decisions every time an execution plan is retrieved 
	from the plan cache. For example, one execution of a query can result in the 
	use of a serial plan, a later execution of the same query can result in a 
	parallel plan using three worker threads, and a third execution can result in 
	a parallel plan using four worker threads.

*/

-- Get request details
-- request_dop : 1 to 8
-- The engine reduces the number of threads for a few queries (DOP)
SELECT
	se.session_id AS session_id
  , DB_NAME(re.database_id) AS request_database_name
  , re.status AS request_status
  , re.dop AS request_dop
  , re.parallel_worker_count AS request_parallel_worker_count
  , SUBSTRING(
				 t.text, (re.statement_start_offset / 2) + 1
			   , ((CASE re.statement_end_offset
					   WHEN -1
							THEN DATALENGTH(t.text)
					   ELSE re.statement_end_offset
				   END - re.statement_start_offset
				  ) / 2
				 ) + 1
			 ) AS request_statement_text
  , ta.task_address AS task_address
  , ta.task_state AS task_state
  , ta.context_switches_count AS task_context_switches_count
  , ta.exec_context_id AS task_exec_context_id
  , sch.scheduler_id AS scheduler_id
  , sch.cpu_id AS scheduler_cpu_id
  , sch.status AS scheduler_status
  , sch.is_idle AS scheduler_is_idle
  , sch.preemptive_switches_count AS scheduler_preemptive_switches_count
  , sch.context_switches_count AS scheduler_context_switches_count
  , sch.current_tasks_count AS scheduler_current_tasks_count
  , sch.runnable_tasks_count AS scheduler_runnable_tasks_count
  , sch.current_workers_count AS scheduler_current_workers_count
  , sch.active_workers_count AS scheduler_active_workers_count
  , sch.work_queue_count AS scheduler_work_queue_count
  , wo.worker_address AS worker_address
  , wo.is_preemptive AS worker_is_preemptive
  , wo.context_switch_count AS worker_context_switch_count
  , wo.state AS worker_state
  , wo.last_wait_type
  , thr.os_thread_id AS os_thread_id
FROM
	sys.dm_exec_sessions AS se WITH (NOLOCK)
LEFT JOIN
	sys.dm_exec_requests AS re WITH (NOLOCK)
ON
	re.session_id = se.session_id
LEFT JOIN
	sys.dm_resource_governor_resource_pools AS po WITH (NOLOCK)
ON
	re.group_id = po.pool_id
LEFT JOIN
	sys.dm_os_tasks AS ta WITH (NOLOCK)
ON
	ta.session_id = re.session_id
LEFT JOIN
	sys.dm_os_schedulers AS sch WITH (NOLOCK)
ON
	sch.scheduler_id = ta.scheduler_id
LEFT JOIN
	sys.dm_os_workers AS wo WITH (NOLOCK)
ON
	wo.worker_address = ta.worker_address
LEFT JOIN
	sys.dm_os_threads AS thr WITH (NOLOCK)
ON
	ta.worker_address = thr.worker_address
OUTER APPLY sys.dm_exec_sql_text(re.plan_handle) AS t
OUTER APPLY sys.dm_exec_query_plan(re.plan_handle) AS prd
WHERE
	is_user_process = 1;
GO

-- Threadpool starvation
-- work_queue_count > 0
-- Number of schedulers for user requests (VISIBLE) is equal to the number of
-- logical CPUs
-- Current_tasks_count :
--	Number of current tasks that are associated with this scheduler. 
-- This count includes the following: 
--	Tasks that are waiting for a worker to execute them. 
--	Tasks that are currently waiting or running (in SUSPENDED or RUNNABLE state).
-- Runnable_tasks_count :
--	Number of workers, with tasks assigned to them, that are waiting to be
--	scheduled on the runnable queue
-- Current_workers_count :
--	Number of workers that are associated with this scheduler. 
--	This count includes workers that are not assigned any task
-- Active_workers_count :
--	Number of workers that are active. 
--	An active worker is never preemptive, must have an associated task, 
--	and is either running, runnable, or suspended
-- Work_queue_count :
--	Number of tasks in the pending queue. 
--	These tasks are waiting for a worker to pick them up
SELECT
	scheduler_id
,	current_tasks_count
,	runnable_tasks_count
,	current_workers_count
,	active_workers_count
,	work_queue_count
FROM sys.dm_os_schedulers WITH (NOLOCK)
WHERE status = 'VISIBLE ONLINE';
GO

-- Wait_type : THREADPOOL
-- Wait_type : CXPACKET
-- Parallelism will cause CXPACKET and THREADPOOL starvation
SELECT *
FROM
	sys.dm_os_waiting_tasks WITH (NOLOCK)
WHERE
	wait_type IN (
					 'THREADPOOL', 'CXPACKET'
				 )
ORDER BY
	wait_type DESC;
GO

-- Get the wait statistics
-- Threadpool starvation
-- THREADPOOL : 480145
-- CXPACKET : 1957040
SELECT *
FROM
	sys.dm_os_wait_stats
WHERE
	wait_type IN (
					 'THREADPOOL', 'CXPACKET'
				 );
GO


-- The query uses more than one thread which will likely cause thread pool starvation
-- much faster.
-- Degree of Parallelism : 8
-- ThreadStat.Branches : 2
-- ThreadReservation.ReservedThreads : 16
SELECT *
FROM
	Sales.SalesOrderDetail AS sod
INNER JOIN
	Production.Product AS prd
ON
	sod.ProductID = prd.ProductID
WHERE
	SalesOrderDetailID > 10
ORDER BY
	Style
GO

-- Housekeeping
EXEC sp_configure 'max worker threads', 0;
RECONFIGURE;
EXEC sys.sp_configure N'cost threshold for parallelism', N'50';
RECONFIGURE;
GO
