/**********************************************************************************************************************
 Purpose:
 This is a test script.
 Defrag Daily per "Best Practice": Test for whether to defrag or not is executed daily.
    "Best Practice" runs based on Reorg at 10% fragmentation and Rebuild at 30%.
    Covers Fill Factors of 100, 90, 80, and 70
    Baseline and NoDefrag runs were previously done by the "Defrag Weekly" code.
-----------------------------------------------------------------------------------------------------------------------
 Operator Notes:
 1. It takes this code approximately 00:50:48 (hh:mm:ss) to execute on my laptop running SQL Server 2017 
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
        ,@FluffSize         = 1 --Simulates extra columns
        ,@DF_StartPageCount = 1025
        ,@DF_ReorgPercent   = 10   
        ,@DF_RebuildPercent = 30  
        ,@DF_Days           = 1    --Number of days to skip between defrags
;
--===== Note that the Baseline and NoDefrag runs were done in the "Defrag Weekly" code.
--=====================================================================================================================
--      "Best Practice" runs based on Reorg at 10% fragmentation and Rebuild at 30%.
--      Covers Fill Factors of 100, 90, 80, and 70
--=====================================================================================================================    
--===== Best Practice w/Fill Factor = 100
        CHECKPOINT;
   DBCC FREEPROCCACHE;
   EXEC dbo.PopulateGuidTestAdaptive_FragTest10
         @pTestName         = 'NBPDD_FF100'
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
     IF OBJECT_ID('dbo.NBPDD_FF100','U') IS NOT NULL
        DROP TABLE dbo.NBPDD_FF100
;
   EXEC sp_rename 'dbo.GuidTest','NBPDD_FF100'
;
-----------------------------------------------------------------------------------------------------------------------
--===== Best Practice w/Fill Factor = 90
        CHECKPOINT;
   DBCC FREEPROCCACHE;
   EXEC dbo.PopulateGuidTestAdaptive_FragTest10
         @pTestName         = 'NBPDD_FF090'
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
     IF OBJECT_ID('dbo.NBPDD_FF090','U') IS NOT NULL
        DROP TABLE dbo.NBPDD_FF090
;
   EXEC sp_rename 'dbo.GuidTest','NBPDD_FF090'
;
-----------------------------------------------------------------------------------------------------------------------
--===== Best Practice w/Fill Factor = 80
        CHECKPOINT;
   DBCC FREEPROCCACHE;
   EXEC dbo.PopulateGuidTestAdaptive_FragTest10
         @pTestName         = 'NBPDD_FF080'
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
     IF OBJECT_ID('dbo.NBPDD_FF080','U') IS NOT NULL
        DROP TABLE dbo.NBPDD_FF080
;
   EXEC sp_rename 'dbo.GuidTest','NBPDD_FF080'
;
-----------------------------------------------------------------------------------------------------------------------
--===== Best Practice w/Fill Factor = 70
        CHECKPOINT;
   DBCC FREEPROCCACHE;
   EXEC dbo.PopulateGuidTestAdaptive_FragTest10
         @pTestName         = 'NBPDD_FF070'
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
     IF OBJECT_ID('dbo.NBPDD_FF070','U') IS NOT NULL
        DROP TABLE dbo.NBPDD_FF070
;
   EXEC sp_rename 'dbo.GuidTest','NBPDD_FF070'
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
        ,[FF=100]   = MAX(CASE WHEN TestName LIKE '%100'  THEN PageCount ELSE 0 END)
        ,[100]      = ''
        ,[FF=90]    = MAX(CASE WHEN TestName LIKE '%090'  THEN PageCount ELSE 0 END)
        ,[90]       = ''
        ,[FF=80]    = MAX(CASE WHEN TestName LIKE '%080'  THEN PageCount ELSE 0 END)
        ,[80]       = ''
        ,[FF=70]    = MAX(CASE WHEN TestName LIKE '%070'  THEN PageCount ELSE 0 END)
        ,[70]       = ''
   FROM dbo.IxPageStats
  WHERE TestName LIKE 'NBPDD%'
     OR TestName IN  ('Baseline','NoDefrag')
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