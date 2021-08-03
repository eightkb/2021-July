--=====================================================================================================================
--      View the current status of a run and all previous runs.
--      A currently running test will always show up as the first entry.
--=====================================================================================================================
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 SELECT TestName,BatchDT,DayHour = MAX(DayHour)
   FROM dbo.IxPageStats
  GROUP BY TestName,BatchDT
  ORDER BY DayHour,TestName
;
--=====================================================================================================================
--      Different methods for looking at test results
--=====================================================================================================================
--===== Presets
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
;
--===== Variable to hold the test name we want results for.
DECLARE @TestName SYSNAME = 'dbo.BPWK_FF080'
;
--===== Overall Results from Hour Zero each day.
     -- This is where things like daily log file stats, etc, live.
 SELECT *
   FROM dbo.IxPageStats
  WHERE TestName   = PARSENAME(@TestName,1) --Removes the schema name just incase someone included it.
    AND HourNumber = 0
  ORDER BY DayHour --DESC
;
--===== What most people look at
 SELECT *
   FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID(@TestName),NULL,NULL,'DETAILED')
  ORDER BY index_level
;
--===== The short version of the above.
 SELECT * 
   FROM dbo.PhysStats(@TestName)
;

