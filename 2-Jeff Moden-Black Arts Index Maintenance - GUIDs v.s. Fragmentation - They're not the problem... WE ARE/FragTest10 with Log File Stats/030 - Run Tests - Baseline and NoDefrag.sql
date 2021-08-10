--===== Identify the database to use
    USE FragTest10
;
/**********************************************************************************************************************
 Purpose:
 Fragmentation test run for the following tests:
    BASELINE - Inherently uses the dbo.GuidSourceSorted table and does fragmentation checks.
    NODEFRAG - Inherently uses the dbo.GuidSource (random GUIDs) table and does NO fragmentation checks.

 This code does RBAR inserts to get the most accurate hourly measurements possible.  The RBAR does take a substantial
 amount of time to execute and so it's recommended that this only be executed in the FragTest10 database, which has
 "only" 3.65 Million rows for the 365 day/10 hours per day/1000 RBAR row inserts per hour.

 This test produces no test results output to the screen as the results from this run will be used in the output of
 all other tests.
-----------------------------------------------------------------------------------------------------------------------
 Operator Notes:
 1. It takes this code ~00:19 (hh:mm) to execute on my laptop running SQL Server 2017 Developer's Edition.
 2. Note that after each run is completed, the "GuidTest" table is renamed to match the test. This prevents the need 
    for a lot of Dynamic SQL.  If the rename target already exists, it will be dropped with great predjudice.
 3. The run results are stored in the dbo.IxPageStats created in script 010.
 ----------------------------------------------------------------------------------------------------------------------- 
 Revision History:
 Rev 00 - 12 Nov 2017 - Jeff Moden
        - Initial creation and use.
 Rev 01 - 29 May 2018 - Jeff Moden
        - Modify the code for easy use by others.
        - Add more documentation to the code for easy use by others.
 Rev 02 - 31 Dec 2018 - Jeff Moden
        - Modify the Flower-Box header to augment understanding by others.
 Rev 03 - 06 Mar 2021 - Jeff Moden
        - Create this separate proc from previously existing code to isolate the BASELINE and NODEFRAG tests so they
          can be executed separately to support other testing in any order.
        - Update callouts to use the new proc that records logfile stats.
**********************************************************************************************************************/
--=====================================================================================================================
--      Presets
--=====================================================================================================================
--===== Ensure that the database is in the BULK_LOGGED Recovery Model
  ALTER DATABASE [FragTest10] SET RECOVERY BULK_LOGGED WITH NO_WAIT
;
--===== Local Variables
DECLARE  @TestDays           INT
        ,@HoursPerDay        INT
        ,@RowsPerHour        INT
        ,@TestType           CHAR(10)     
        ,@FluffSize          INT
        ,@DF_StartPageCount  INT
        ,@DF_ReorgPercent    INT  
        ,@DF_RebuildPercent  INT 
        ,@DF_Days            INT
;
--===== Constants: These settings normally affect ALL tests the same way. There is an exception for the NoDefrag rum.
 SELECT  @TestDays          = 365
        ,@HoursPerDay       = 10
        ,@RowsPerHour       = 1000
        ,@FluffSize         = 100  --Fixed number of bytes to simulates extra columns
        ,@DF_StartPageCount = 1000 --Supposed "Best Practice"
        ,@DF_ReorgPercent   = 5    --Supposed "Best Practice" - This will change for the NoDefrag Test
        ,@DF_RebuildPercent = 30   --Supposed "Best Practice" - This will change for the NoDefrag Test
        ,@DF_Days           = 1    --Number of days to skip between defrags (1 is "Daily", 7 is "Weekly")
;
--=====================================================================================================================
--      BASELINE: Inputs in sorted "ever increasing" order so NO FRAGMENTATION.  Only "Good" page splits.
--                Uses the dbo.GuidSourceSorted table.
--=====================================================================================================================
        CHECKPOINT;
   DBCC FREEPROCCACHE;
   EXEC dbo.PopulateGuidTestAdaptive_FragTest10
         @pTestName         = 'BaseLine'
        ,@pTestDays         = @TestDays     
        ,@pHoursPerDay      = @HoursPerDay  
        ,@pRowsPerHour      = @RowsPerHour  
        ,@pFillFactor       = 100  
        ,@pFluffSize        = @FluffSize  
        ,@pDF_StartPageCount= @DF_StartPageCount
        ,@pDF_ReorgPercent  = @DF_ReorgPercent   
        ,@pDF_RebuildPercent= @DF_RebuildPercent   
        ,@pDF_Days          = @DF_Days
;
--===== Rename the table to keep it for later experiments
     IF OBJECT_ID('dbo.BaseLine','U') IS NOT NULL
        DROP TABLE dbo.BaseLine
;
   EXEC sp_rename 'dbo.GuidTest','BaseLine'
;
--=====================================================================================================================
--      NoDefrag: Brent's method for index maintenance. Low page splits but massive logical fragmentation.
--                All tests from here-on use the dbo.GuidSource table, which contains random GUIDs.
--=====================================================================================================================    
        CHECKPOINT;
   DBCC FREEPROCCACHE;
   EXEC dbo.PopulateGuidTestAdaptive_FragTest10
         @pTestName         = 'NoDefrag'
        ,@pTestDays         = @TestDays     
        ,@pHoursPerDay      = @HoursPerDay  
        ,@pRowsPerHour      = @RowsPerHour  
        ,@pFillFactor       = 100  
        ,@pFluffSize        = @FluffSize  
        ,@pDF_StartPageCount= @DF_StartPageCount
        ,@pDF_ReorgPercent  = 0  --Don't ever do a reorg
        ,@pDF_RebuildPercent= 0  --Don't ever do a rebuild
        ,@pDF_Days          = @DF_Days
;
--===== Rename the table to keep it for later experiments
     IF OBJECT_ID('dbo.NoDefrag','U') IS NOT NULL
        DROP TABLE dbo.NoDefrag
;
   EXEC sp_rename 'dbo.GuidTest','NoDefrag'
;
--=====================================================================================================================
--      Run Complete
--=====================================================================================================================    
        CHECKPOINT;
  PRINT '***** Run Complete (No Output in Grid Expected) *****'
;
GO