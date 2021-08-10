/**********************************************************************************************************************
 Purpose:
 This is a test script.
 Defrag Daily with Low Threshold Rebuilds (1%): Test for whether to defrag or not is executed daily.
 This is a demo of a much more narrow index (Fluff  = 1)
    Only Rebuilds will be done and 
    Covers Fill Factors of 90, 80, and 70
    Baseline and NoDefrag runs are also done for this change in size.
-----------------------------------------------------------------------------------------------------------------------
 Operator Notes:
 1. It takes this code approximately 00:36:46 (hh:mm:ss) to execute on my laptop running SQL Server 2017 
    Developer's Edition.
 2. Note that after each run is completed, the "GuidTest" table is renamed to match the test. This prevents the need 
    for a lot of Dynamic SQL.  If the rename target already exists, it will be dropped with great predjudice.
 3. The run results are stored in the dbo.IxPageStats created in script 010.
 4. The run results are displayed and the end of the run and are suitable for copy'n'paste to a spreadsheet from the
    grid mode of SSMS.
----------------------------------------------------------------------------------------------------------------------- 
 Revision History:
 Rev 00 - 12 Nov 2017 - Jeff Moden
        - Initial creation and use.
 Rev 01 - 29 May 2018 - Jeff Moden
        - Modify the code for easy use by others.
        - Add more documentation to the code for easy use by others.
 Rev 02 - 31 Dec 2018 - Jeff Moden
        - Modify the Flower-Box header to augment understanding by others.
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
--===== Constants: These settings affect ALL tests the same way
 SELECT  @TestDays          = 365
        ,@HoursPerDay       = 10
        ,@RowsPerHour       = 1000
        ,@FluffSize         = 1  --Simulates extra columns but only 1 byte extra to simulate a non-clustered index.
        ,@DF_StartPageCount = 1025
        ,@DF_ReorgPercent   = 0    --No Reorg
        ,@DF_RebuildPercent = 1    --Rebuild at 1% average logical fragmentation
        ,@DF_Days           = 1    --Number of days to skip between defrags
;
--=====================================================================================================================
--      BASELINE: Inputs in sorted "ever increasing" order so NO FRAGMENTATION.  Only "Good" page splits.
--=====================================================================================================================
        CHECKPOINT;
   DBCC FREEPROCCACHE;
   EXEC dbo.PopulateGuidTestAdaptive_FragTest10
         @pTestName         = 'NBaseLine'
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
     IF OBJECT_ID('dbo.NBaseLine','U') IS NOT NULL
        DROP TABLE dbo.NBaseLine
;
   EXEC sp_rename 'dbo.GuidTest','NBaseLine'
;
--=====================================================================================================================
--      NoDefrag: Brent's method for index maintenance. Low page splits but massive logical fragmentation.
--=====================================================================================================================    
        CHECKPOINT;
   DBCC FREEPROCCACHE;
   EXEC dbo.PopulateGuidTestAdaptive_FragTest10
         @pTestName         = 'NNoDefrag'
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
     IF OBJECT_ID('dbo.NNoDefrag','U') IS NOT NULL
        DROP TABLE dbo.NNoDefrag
;
   EXEC sp_rename 'dbo.GuidTest','NNoDefrag'
;
--=====================================================================================================================
--      "Low Threshold" daily runs with only Rebuilds
--      Covers Fill Factors of 90, 80, and 70
--=====================================================================================================================    
--===== Low Threshold w/Fill Factor = 90
        CHECKPOINT;
   DBCC FREEPROCCACHE;
   EXEC dbo.PopulateGuidTestAdaptive_FragTest10
         @pTestName         = 'NLTDD_FF090'
        ,@pTestDays         = @TestDays     
        ,@pHoursPerDay      = @HoursPerDay  
        ,@pRowsPerHour      = @RowsPerHour  
        ,@pFillFactor       = 90   
        ,@pFluffSize        = @FluffSize  
        ,@pDF_StartPageCount= @DF_StartPageCount
        ,@pDF_ReorgPercent  = @DF_ReorgPercent   
        ,@pDF_RebuildPercent= @DF_RebuildPercent   
        ,@pDF_Days          = @DF_Days
;
--===== Rename the table to keep it for later experiments
     IF OBJECT_ID('dbo.NLTDD_FF090','U') IS NOT NULL
        DROP TABLE dbo.NLTDD_FF090
;
   EXEC sp_rename 'dbo.GuidTest','NLTDD_FF090'
;
-----------------------------------------------------------------------------------------------------------------------
--===== Low Threshold w/Fill Factor = 80
        CHECKPOINT;
   DBCC FREEPROCCACHE;
   EXEC dbo.PopulateGuidTestAdaptive_FragTest10
         @pTestName         = 'NLTDD_FF080'
        ,@pTestDays         = @TestDays     
        ,@pHoursPerDay      = @HoursPerDay  
        ,@pRowsPerHour      = @RowsPerHour  
        ,@pFillFactor       = 80   
        ,@pFluffSize        = @FluffSize  
        ,@pDF_StartPageCount= @DF_StartPageCount
        ,@pDF_ReorgPercent  = @DF_ReorgPercent   
        ,@pDF_RebuildPercent= @DF_RebuildPercent   
        ,@pDF_Days          = @DF_Days
;
--===== Rename the table to keep it for later experiments
     IF OBJECT_ID('dbo.NLTDD_FF080','U') IS NOT NULL
        DROP TABLE dbo.NLTDD_FF080
;
   EXEC sp_rename 'dbo.GuidTest','NLTDD_FF080'
;
-----------------------------------------------------------------------------------------------------------------------
--===== Low Threshold w/Fill Factor = 70
        CHECKPOINT;
   DBCC FREEPROCCACHE;
   EXEC dbo.PopulateGuidTestAdaptive_FragTest10
         @pTestName         = 'NLTDD_FF070'
        ,@pTestDays         = @TestDays     
        ,@pHoursPerDay      = @HoursPerDay  
        ,@pRowsPerHour      = @RowsPerHour  
        ,@pFillFactor       = 70   
        ,@pFluffSize        = @FluffSize  
        ,@pDF_StartPageCount= @DF_StartPageCount
        ,@pDF_ReorgPercent  = @DF_ReorgPercent   
        ,@pDF_RebuildPercent= @DF_RebuildPercent   
        ,@pDF_Days          = @DF_Days
;
--===== Rename the table to keep it for later experiments
     IF OBJECT_ID('dbo.NLTDD_FF070','U') IS NOT NULL
        DROP TABLE dbo.NLTDD_FF070
;
   EXEC sp_rename 'dbo.GuidTest','NLTDD_FF070'
;
-----------------------------------------------------------------------------------------------------------------------

--=====================================================================================================================
--      Create the chart-set output
--===================================================================================================================== 
 SELECT  [DayHour]
        ,[Baseline] = MAX(CASE WHEN TestName = 'NBaseline' THEN PageCount ELSE 0 END)
        ,[B]        = ''
        ,[NoDefrag] = MAX(CASE WHEN TestName = 'NNoDefrag' THEN PageCount ELSE 0 END)
        ,[N]        = ''
        ,[FF=100]   = MAX(CASE WHEN TestName LIKE '%100'  THEN PageCount ELSE 0 END) --Produces all zeros for this run
        ,[100]      = ''                                                             --as a placeholder for charting.
        ,[FF=90]    = MAX(CASE WHEN TestName LIKE '%090'  THEN PageCount ELSE 0 END)
        ,[90]       = ''
        ,[FF=80]    = MAX(CASE WHEN TestName LIKE '%080'  THEN PageCount ELSE 0 END)
        ,[80]       = ''
        ,[FF=70]    = MAX(CASE WHEN TestName LIKE '%070'  THEN PageCount ELSE 0 END)
        ,[70]       = ''
   FROM dbo.IxPageStats
  WHERE TestName LIKE 'NLTDD%'
     OR TestName IN  ('NBaseline','NNoDefrag')  
  GROUP BY DayHour
  ORDER BY DayHour
;
--=====================================================================================================================
--      Run Complete
--=====================================================================================================================    
        CHECKPOINT;
  PRINT '***** Run Complete *****'
;
GO