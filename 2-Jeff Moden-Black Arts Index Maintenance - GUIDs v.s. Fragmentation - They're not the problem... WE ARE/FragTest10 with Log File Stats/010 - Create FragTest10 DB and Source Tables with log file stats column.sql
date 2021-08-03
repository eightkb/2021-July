/**********************************************************************************************************************
 Purpose:
 1. Create the "FragTest10" database.
 2. Create the unsorted 3.65 Million Row "GuidSource" table used for repeatable testing across multiple Fill Factors.
 3. Create the sorted 3.65 Million Row "GuidSourceSorted" table to be used for the "Append Only Baseline" testing.
 4. Create the "IxPageStats" table where all durations and page counts from every test will be stored.
 5. Create the "dbo.PhyStats" function (used only for demo display purposes).
 6. Create the "dbo.fnTally" function.
-----------------------------------------------------------------------------------------------------------------------
 Operator Notes:
 1. Every effort was made to keep this script compatible with all versions of the following Editions for 2005 thru 2017.
        Enterprise Edition
        Standard Edition
        Developers Edition
        Express Edition
            Will not work 100% on the Express Edition because of the final size of the MDF file. Individual tests 
            should work.  Change the ALTER DATABASE commands to fit the max size of the Express Edition.
 2. It takes this code approximately 6 seconds to execute on my laptop running SQL Server 2017 Developer's Edition.
    Here's what the laptop is so that you can do performance estimates based on the hardware in your machine.
        Alienware R17 Laptop with built in overclocking to 4 GHz
        8th Gen Intel i7 with 6 cores hyperthreaded to 12 (Single NUMA Node)
        32 GB RAM (28 Allocated to SQL Server)
        2 TB NVME SSD ("Disk")
 3. The final size of the database this code creates is 15GB.
        The MDF file is 12GB.
        The LDF file is  3GB.
        Both database files are created in the directories specified by the instance default file settings.
        If that's not satisfactory, review the code and make the appropriate changes before execution.
 4. The owner of the database will be whomever runs this code.
 5. The database is set to the BULK_LOGGED Recovery Model.
        It's first created in the FULL Recovery Model, backed up to the "NUL" device, and then changed to BULK_LOGGED.
 6. Again, the name of the database is "FragTest10"
 7. The data produced by this code occupies ~212.5 MB
----------------------------------------------------------------------------------------------------------------------- 
 Revision History:
 Rev 00 - 12 Nov 2017 - Jeff Moden
        - Initial creation and use.
 Rev 01 - 29 May 2018 - Jeff Moden
        - Modify the code for easy use by others.
        - Add more documentation to the code for easy use by others.
 Rev 02 - 31 Dec 2018 - Jeff Moden
        - Add Flower-Box header to augment understanding by others.
 Rev 03 - 03 Nov 2020 - Jeff Moden
        - Modifications to support Log File rowcount measurements including backups to "NUL"
        - Change to BULK_LOGGED Recovery Model to support the log file measurements.
 Rev 04 - 20 Dec 2020 - Jeff Moden
        - Add the dbo.PhysStats and dbo.fnTally functions to the database.
 Rev 05 - 6 May 2020 - Jeff Moden
        - Move the code that preps the database for backups to NULL to the very end so that it's all in one place.
          The final state in this code is still backup-enabled and in the BULK_LOGGED.
 Rev 06 - 30 Jun 2021- Jeff Moden
        - Add the column to hold the log file "usage" size at the end of each day.
**********************************************************************************************************************/
--===== Notify the operator of where they can monitor progress of the code.
    SET NOCOUNT ON;
 SELECT Information = 'See messages tab for progress';
    SET NOCOUNT OFF
;
RAISERROR('
--=====================================================================================================================
--      Drop and create the "FragTest10" Database
--=====================================================================================================================
',0,0) WITH NOWAIT
;
--===== Change to a safe place everyone has so we don't have to be concerned with our own connection.
    USE tempdb
;
--===== If the database exists, drop it.
     -- Commented out for safety purposes. Uncomment if you need to do this (destroys ALL collected data, too!)
     IF DB_ID('FragTest10') IS NOT NULL
  BEGIN 
        RAISERROR('Dropping existing database...',0,0) WITH NOWAIT
        ;
        --===== Kick everyone and everything out of the database.
          ALTER DATABASE FragTest10 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
        ;
        --===== Drop the database
           DROP DATABASE FragTest10
        ;
    END
   ELSE RAISERROR('Database did not exist.',0,0) WITH NOWAIT
;
--===== Create the database using only the defaults and set to the SIMPLE Recovery Model.
RAISERROR('Creating the database...',0,0) WITH NOWAIT
;
 CREATE DATABASE FragTest10;
  ALTER DATABASE FragTest10 SET RECOVERY SIMPLE WITH NO_WAIT
;
--===== PreSize the database so we don't have to wait for file growths.
     -- This is only large enough to accomodate the test data that we'll generate in other scripts.
RAISERROR('Presizing the database...',0,0) WITH NOWAIT
;
  ALTER DATABASE FragTest10 MODIFY FILE (NAME = N'FragTest10'    , SIZE = 8800MB, FILEGROWTH = 100MB);
  ALTER DATABASE FragTest10 MODIFY FILE (NAME = N'FragTest10_log', SIZE = 1600MB, FILEGROWTH = 100MB)
;
GO
RAISERROR('
--=====================================================================================================================
--      Create the two source tables (3,650,000 GUIDs each)
--=====================================================================================================================
',0,0) WITH NOWAIT
;
--===== Identify the database to do this in.
    USE FragTest10
;
-----------------------------------------------------------------------------------------------------------------------
RAISERROR('Creating the GuidSource table...',0,0) WITH NOWAIT
;
--===== If the test table exists, drop it to make reruns in SSMS easier
     IF OBJECT_ID('dbo.GuidSource','U') IS NOT NULL
   DROP TABLE dbo.GuidSource
;
--===== Create the table with a row number for easy access to each GUID and to preserve the sort order for
     -- repeatable testing.
 CREATE TABLE dbo.GuidSource
        (
         RowNum INT IDENTITY(1,1) PRIMARY KEY CLUSTERED
        ,Guid UNIQUEIDENTIFIER
        )
;
--===== Populate the table with 3.65 Million GUIDs. 
     -- THESE WILL BE IN RANDOM ORDER and are used for all tests except BASELINEs.
RAISERROR('Populating the GuidSource table...',0,0) WITH NOWAIT;
RAISERROR('(Contains randomized GUIDs)',0,0) WITH NOWAIT
;
 INSERT INTO dbo.GuidSource WITH(TABLOCK)
        (Guid)
 SELECT TOP 3650000
        Guid = NEWID()
   FROM      sys.all_columns ac1
  CROSS JOIN sys.all_columns ac2
;
-----------------------------------------------------------------------------------------------------------------------
    PRINT REPLICATE('-',119);
RAISERROR('Creating the GuidSourceSorted table...',0,0) WITH NOWAIT
;
--===== If the test table exists, drop it to make reruns in SSMS easier
     IF OBJECT_ID('dbo.GuidSourceSorted','U') IS NOT NULL
   DROP TABLE dbo.GuidSourceSorted
;
--===== Create the table with a row number for easy access to each GUID and to preserve the sort order for
     -- repeatable testing.
 CREATE TABLE dbo.GuidSourceSorted
        (
         RowNum INT IDENTITY(1,1) PRIMARY KEY CLUSTERED
        ,Guid UNIQUEIDENTIFIER
        )
;
--===== Populate the table with millions of Guids. 
     -- THESE WILL BE IN SORTED ORDER and are used only for BASELINEs.
RAISERROR('Populating the GuidSourceSorted table...',0,0) WITH NOWAIT;
RAISERROR('(Contains same GUIDs but sorted)',0,0) WITH NOWAIT
;
 INSERT INTO dbo.GuidSourceSorted WITH(TABLOCK)
        (Guid)
 SELECT Guid
   FROM GuidSource
  ORDER BY Guid
;
GO
CHECKPOINT
GO
RAISERROR('
--=====================================================================================================================
--      Create the Test Support Table where we accumulate hourly index information and durations.
--=====================================================================================================================
',0,0) WITH NOWAIT
;
--===== Create the table that will contain the output of sys.dm_db_index_physical_stats
RAISERROR('Creating the IxPageStats table...',0,0) WITH NOWAIT
;
     IF OBJECT_ID('dbo.IxPageStats','U') IS NULL 
 CREATE TABLE dbo.IxPageStats  
        (
         IxPageStatsID      INT             IDENTITY(1,1)
        ,TestName           VARCHAR(50)     NOT NULL
        ,BatchDT            DATETIME        NOT NULL
        ,DayNumber          SMALLINT        NOT NULL
        ,HourNumber         TINYINT         NOT NULL
        ,HourRunDur         INT             NOT NULL DEFAULT 0
        ,IndexID            TINYINT         NOT NULL
        ,IndexLevel         TINYINT         NOT NULL
        ,AvgFragPct         FLOAT           NOT NULL
        ,DayHour AS ((('D'+RIGHT(DayNumber+(1000),(3)))+' H')+RIGHT(HourNumber+(100),(2))) PERSISTED
        ,PageCount          BIGINT          NOT NULL
        ,AvgSpaceUsedPct    FLOAT           NOT NULL
        ,Rows               BIGINT          NOT NULL
        ,AvgRowSize         FLOAT           NOT NULL
        ,DefragType         CHAR(7)         NOT NULL DEFAULT ''
        ,DefragDur          INT             NULL
        ,TLogBackupDur      INT             NULL   
        ,LSNLineCntDiff     INT             NULL
        ,LogFileSizeMB      DECIMAL(9,3)    NULL --Rev 06
        )
;
GO
RAISERROR('
--=====================================================================================================================
--      Setup the log file chain so we can measure its size later.
--      We leave the final state of the database in the BULK-LOGGED Recovery Model.
--      The individual test runs will change the Recovery Model for demonstrations as needed.
--=====================================================================================================================
',0,0) WITH NOWAIT
;
        CHECKPOINT;
  ALTER DATABASE FragTest10 SET RECOVERY BULK_LOGGED WITH NO_WAIT;
 BACKUP DATABASE FragTest10 TO DISK = 'NUL';
 BACKUP LOG      FragTest10 TO DISK = 'NUL';
  ALTER DATABASE FragTest10 SET RECOVERY BULK_LOGGED WITH NO_WAIT;
GO
RAISERROR('
--=====================================================================================================================
--      Adding the dbo.PhysStats iTVF.
--=====================================================================================================================
',0,0) WITH NOWAIT
;
GO
 CREATE OR ALTER FUNCTION [dbo].[PhysStats]
/**********************************************************************************************************************
 Purpose:
 Given a 2 part user table name in the form of 'SchemaName.TableName', return a summary of what is available from the 
 systemfunction of sys.dm_db_index_physical_stats using the "DETAILED" option for all IN_ROW_DATA, LOB_DATA, and
 ROW_OVERFLOW_DATA page types.

 Note that the output is sorted by page type, index ID, and the level of the pages in the B-Tree.

 Usage Example:
 SELECT * FROM dbo.PhysStats('SchemaName.TableName')
;
 Programmer notes:
 1. This function must exist in the same database as the given table name.
 2. This function is a high performance iTVF (Inline Table Valued Function).
 3. This code will return an error if used against system views such as sys.objects.
 4. No reference to the table name or object_id is returned. Because the function requires the table name, it's 
    assumed that information is already available to the user.
 5. The generally accepted maximum number of bytes per page is 8,060.  While that is sort of true for user information,
    it's not true when it comes to total page size/row size. The number 8,096 is correct when it comes to actual page
    size for total page content associated with user information, which includes such things as the individual row 
    headers, etc.  For example, a table with a single INT column will actually have a row size of 11... 4 bytes for the
    INT and 7 bytes for the row header (which varies in size for other things), which is included for EVERY row in the
    table or index.

 Revision History:
 Rev 00 - 03 Mar 2019 - Jeff Moden
        - Initial creation and unit test
**********************************************************************************************************************/
--===== Define the I/0 for this function
        (@pTableName SYSNAME)
RETURNS TABLE AS --Cannot use WITH SCHEMABINDING against a system table
 RETURN
--===== Return the summarized physical stats information in table format for the given table.
 SELECT TOP 2147483647 --TOP is necessary for a sort within a function.
         SizeMB         = CONVERT(DECIMAL(9,1),page_count/128.0)
        ,IdxID          = index_id
        ,PageType       = alloc_unit_type_desc
        ,IdxLvl         = index_level
        ,FragPct        = CONVERT(DECIMAL(9,4),avg_fragmentation_in_percent)
        ,PageCnt        = page_count
        ,PageDensity    = CONVERT(DECIMAL(9,4),avg_page_space_used_in_percent)
        ,MinRecSize     = min_record_size_in_bytes
        ,AvgRecSize     = avg_record_size_in_bytes
        ,MaxRecSize     = max_record_size_in_bytes
        ,AvgRowsPerPage = ISNULL(8096/NULLIF(CONVERT(INT,avg_record_size_in_bytes),0),0) --See Programmer Note #5
        ,RecCnt         = record_count
   FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID(@pTableName),NULL,NULL,'DETAILED')
  ORDER BY PageType, IdxID, IdxLvl --ORDER BY not normally done in a function but is real handy for demo purposes.
;
GO
RAISERROR('
--=====================================================================================================================
--      Adding the dbo.fnTally iTVF.
--=====================================================================================================================
',0,0) WITH NOWAIT
;
GO
 CREATE OR ALTER FUNCTION [dbo].[fnTally]
/**********************************************************************************************************************
 Purpose:
 Return a column of BIGINTs from @ZeroOrOne up to and including @MaxN with a max value of 10 Quadrillion.

 Usage:
--===== Syntax example
 SELECT t.N
   FROM dbo.fnTally(@ZeroOrOne,@MaxN) t
;
 @ZeroOrOne will internally conver to a 1 for any number other than 0 and a 0 for a 0.
 @MaxN has an operational domain from 0 to 4,294,967,296. Silent truncation occurs for larger numbers.

 Please see the following notes for other important information

 Notes:
 1. This code works for SQL Server 2008 and up.
 2. Based on Itzik Ben-Gan's cascading CTE (cCTE) method for creating a "readless" Tally Table source of BIGINTs.
    Refer to the following URL for how it works.
    https://www.itprotoday.com/sql-server/virtual-auxiliary-table-numbers
 3. To start a sequence at 0, @ZeroOrOne must be 0. Any other value that's convertable to the BIT data-type
    will cause the sequence to start at 1.
 4. If @ZeroOrOne = 1 and @MaxN = 0, no rows will be returned.
 5. If @MaxN is negative or 1, a "TOP" error will be returned.
 6. @MaxN must be a positive number from >= the value of @ZeroOrOne up to and including 4,294,967,296. If a larger
    number is used, the function will silently truncate after that max. If you actually need a sequence with that many
    or more values, you should consider using a different tool. ;-)
 7. There will be a substantial reduction in performance if "N" is sorted in descending order.  If a descending sort is
    required, use code similar to the following. Performance will decrease by about 27% but it's still very fast 
    especially compared with just doing a simple descending sort on "N", which is about 20 times slower.
    If @ZeroOrOne is a 0, in this case, remove the "+1" from the code.

    DECLARE @MaxN BIGINT; 
     SELECT @MaxN = 1000;
     SELECT DescendingN = @MaxN-N+1 
       FROM dbo.fnTally(1,@MaxN);

 8. There is no performance penalty for sorting "N" in ascending order because the output is implicity sorted by
    ROW_NUMBER() OVER (ORDER BY (SELECT 1))
 9. This will return 1-10,000,000 to a bit-bucket variable in about 986ms.
    This will return 0-10,000,000 to a bit-bucket variable in about 1091ms.
    This will return 1-4,294,967,296 to a bit-bucket variable in about 9:12( mi:ss).

 Revision History:
 Rev 00 - Unknown     - Jeff Moden 
        - Initial creation with error handling for @MaxN.
 Rev 01 - 09 Feb 2013 - Jeff Moden 
        - Modified to start at 0 or 1.
 Rev 02 - 16 May 2013 - Jeff Moden 
        - Removed error handling for @MaxN because of exceptional cases.
 Rev 03 - 07 Sep 2013 - Jeff Moden 
        - Change the max for @MaxN from 10 Billion to 10 Quadrillion to support an experiment. 
          This will also make it much more difficult for someone to actually get silent truncation in the future.
 Rev 04 - 04 Aug 2019 - Jeff Moden
        - Enhance performance by making the first CTE provide 256 values instead of 10, which limits the number of
          CrossJoins to just 2. Notice that this changes the maximum range of values to "just" 4,294,967,296, which
          is the entire range for INT and just happens to be an even power of 256. Because of the use of the VALUES
          clause, this code is "only" compatible with SQLServer 2008 and above.
        - Update old link from "SQLMag" to "ITPro". Same famous original article, just a different link because they
          changed the name of the company (twice, actually).
        - Update the flower box notes with the other changes.
 Rev 05 - 05 Sep 2020 - Jeff Moden
        - As of SQL Server 2017, the TOP in the final SELECT no longer sets the correct "Row Goal" all the time and 
          SQL Server will now sometimes produce the more than 4 billion rows internally before spitting out the row
          numbers, which takes a huge amount of unnecessary time. The only way to fix this was to set a row goal really
          early by limiting the output of the B1 CTE to the 4th root +1 of the @MaxN parameter.
        - Be advised that, as before, it actually does help reduce both duration and CPU usge if you use 
          OPTION (MAXDOP 1) in the calling query to prevent the function from going parallel.
**********************************************************************************************************************/
         (@ZeroOrOne BIT, @MaxN BIGINT)
 RETURNS TABLE WITH SCHEMABINDING AS 
  RETURN WITH
   B1(N) AS (SELECT TOP(POWER(@MaxN,.25)+1) 1 --(4th root of @MaxN)+1
               FROM (VALUES
                     (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    ,(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)
                    )V(N)) --256^0 or 256 max rows
 SELECT N = 0 WHERE @ZeroOrOne = 0 UNION ALL
 SELECT TOP (@MaxN) 
        N = ROW_NUMBER() OVER (ORDER BY (SELECT 1))
   FROM B1 a, B1 b, B1 c, B1 d --256^4 or 4,294,967,296 max rows
;
GO
--===== Inform the operator in the messages tab and the grid tab that the run has completed.
RAISERROR('
--=====================================================================================================================
--      Run complete.
--=====================================================================================================================
',0,0) WITH NOWAIT
;
 SELECT Information = 'Run Complete'
GO