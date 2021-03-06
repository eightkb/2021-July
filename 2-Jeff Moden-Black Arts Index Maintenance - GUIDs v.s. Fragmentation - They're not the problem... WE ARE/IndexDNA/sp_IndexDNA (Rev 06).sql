USE [master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE OR ALTER PROCEDURE [dbo].[sp_IndexDNA] 
/**********************************************************************************************************************
 Purpose:
 Given an object_id (found in sys.objects) for a given table or other object that can have indexes applied to them and 
 the index_id (found in sys.indexes), return the enumerated sequence of pages and the percent of page fullness
 (PageDensity) for each page sampled.

 The output of this code is compatible with REV 05 of the IndexDNA(tm) spreadsheet.
-----------------------------------------------------------------------------------------------------------------------
 Usage:
--===== Syntax example
   EXEC dbo.sp_IndexDNA @pObjectID, @pIndexID
;
--===== Practical example
    USE somedatabase
;
DECLARE  @pObjectID INT
        ,@pIndexID  INT
;
 SELECT  @pObjectID = OBJECT_ID('someschemaname.sometablename')
        ,@pIndexID  = 1
;
   EXEC dbo.sp_IndexDNA @pObjectID, @pIndexID --Both parameters are required and must be correct.
;
-----------------------------------------------------------------------------------------------------------------------
 Programmer's Notes:
 1. This stored procedure current works only with "In Row Data" on Row-Store indexes.  It does not work on LOBs and
    had not been tested on Column-Store or In-Memory tables. It has also NOT been tested for partitioned tables and
    is not setup to support them.
 2. This code uses a filtered index for performance. If needed, you can manually change the code to work on 2005.
    Do a search for '(Mod for 2005)' in the code and read the comments on how to do so.
 3. Note that the sample size is automatically calculated so that no more than 100,000 plot points are ever returned 
    because of the amount of time it would take to 1) execute DBCC PAGE on more pages than that and 2) plot them on the
    related Excel spreadsheet.
 4. Note that the object name can be a one or two part name.
 5. After creating this stored procedure in the MASTER database, execute the following code to reclassify it as  a
    system stored procedure that can be called from any database.

    USE MASTER;  
--===== Reclassify the stored procedure as a system stored procedure.
   EXEC sp_ms_marksystemobject 'sp_IndexDNA'
;  
--===== If the following code returns a 1 for "is_ms_shipped", then it worked.
 SELECT name, is_ms_shipped   
   FROM sys.objects  
  WHERE name = 'sp_IndexDNA'  
;
-----------------------------------------------------------------------------------------------------------------------
 Trademark:
 The names "sp_IndexDNA" and "IndexDNA" are trademarks owned by Jeffrey B. Moden of Auburn Hills, Mi, USA.

 © Copyright:
 This code is copyrighted by Jeffrey B. Moden of Auburn Hills, Mi, USA as of 01 July 2018, with all rights reserved.
 While this code is free to use by those needing it to examine their own indexes, it may not be republished nor sold 
 nor included in any software package or other method of dissemination without express written permission by 
 Jeffrey B. Moden (aka Jeff Moden).  This code may be modified for personal use but the "flower box" header of this 
 code must be included in its entirety.

 Contact Email address:
 JBModen@GMail.com

 Usage:
 There is no warranty nor guarantee of purpose, safety, or operation, either expressed nor implied, in the use of this 
 code.  The suitability for use of this code is the sole reponsibility of the person(s) using this code regardless of
 reason or usage.  Jeffrey B. Moden (aka Jeff Moden) shall be held harmless for any and all uses of the code or any 
 damages incurred by such usage.
-----------------------------------------------------------------------------------------------------------------------
 Revision History:
 Rev 00 - 01 Jul 2018 - Jeff Moden
        - Proof of principle script.
 Rev 01 - 05 Aug 2018 - Jeff Moden
        - Convert to a stored procedure.
 Rev 02 - 01 Apr 2019 - Jeff Moden
        - Add code to prevent the DBCC commands from being blocked (Transaction Isolation Level).
 Rev 03 - 17 Dec 2019 - Jeff Moden
        - Add date to the 5 part index name output in the first output section.
        - This output is compatible with Rev 05 of the related IndexDNA(tm) spreadsheet.
 Rev 04 - 13 Sep 2020 - Jeff Moden
        - This change is based on a suggestion by Ed Wagner... good friend and fellow DBA.
        - Major change to replace the DBCC IND method previously used.  Reasons for change as follows:
        - 1. The code was fast on NCI's. Example 00:01:34 on a 4 column compressed NCI of 266.2 million rows with an 
             average width of 11 bytes (compressed). The single column CI on the table with an average compressed row
             size of 317 bytes and 266.2 million rows used to take 01:05:10.  Both now take 00:02:34 each.  The NCI 
             is worse than before but there's a huge trade off for large CIs. The tradeoff is well worth is 
             especially because...
        - 2. The previous method used to cause severe long term blocking because, contrary to popular belief, DBCC IND
             causes blocking. The new method causes no blocking.
        - 3. The new method is backwards compatible to 2008, which is when the %%physloc%% undocumented system 
             function first became available.
        - 4. The new method has a slightly larger footprint but for a much shorter time and only uses 2 temp table 
             instead of 3.
**********************************************************************************************************************/
--===== Declare the I/O for this stored procedure
         @pObjectID INT
        ,@pIndexID  INT
     AS
--=====================================================================================================================
--      Environmental Presets
--=====================================================================================================================
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; --Added by Rev 02

--=====================================================================================================================
--      Temp Tables and their indexes
--=====================================================================================================================
--===== Drop any existing Temp Tables that will be used.
     -- Comment this section out for production use. It's not needed in stored procedures.
     --IF OBJECT_ID('tempdb..#IND')               IS NOT NULL DROP TABLE #IND;
     IF OBJECT_ID('tempdb..#IndexPageSpace')    IS NOT NULL DROP TABLE #IndexPageSpace;
     IF OBJECT_ID('tempdb..#PageInfo')          IS NOT NULL DROP TABLE #PageInfo;

----===== Create the table that will hold all of the index information that we need to create an IndexDNA(tm) chart.
 CREATE TABLE #IndexPageSpace
        (
         PageSort    INT        NOT NULL
        ,FileID      SMALLINT   NOT NULL
        ,PageID      INT        NOT NULL
        ,PageDensity FLOAT
        )
;
--===== Create the table that will hold the info from the DBCC Page command for each page we process. 
 CREATE TABLE #PageInfo
        (
         ParentObject   VARCHAR(255)
        ,Object         VARCHAR(255)
        ,Field          VARCHAR(255)
        ,Value          VARCHAR(255)
        )
;
--=====================================================================================================================
--      Local variables and presets
--=====================================================================================================================
DECLARE  @Counter       INT
        ,@IndexColsCSV  NVARCHAR(4000) = NULL --Added by Rev 04
        ,@LeafPageCount INT
        ,@MaxPageSort   INT
        ,@Obj2PartName  NVARCHAR(261) = QUOTENAME(OBJECT_SCHEMA_NAME(@pObjectID)) + N'.' --Added by Rev 04
                                      + QUOTENAME(OBJECT_NAME(@pObjectID))
  ,@PageDensity   FLOAT
        ,@PageFreeBytes SMALLINT
        ,@PageRowCount  SMALLINT
        ,@PageUsedBytes SMALLINT
        ,@SampleSize    INT
        ,@SQL           NVARCHAR(MAX)
;
--===== Calculate how to "sample" the pages because anything over 100,000 pages takes a very long time to plot.
     -- This will sample every 1, 10, 100, 1000, etc depending on the number of pages in the index.
     -- No, having a previously calculated variable on the both sides of the "=" sign is NOT an error.
     -- It's immediate reuse of the variable.
 SELECT  @LeafPageCount = in_row_used_page_count
        ,@SampleSize    = POWER(10,CONVERT(INT,CEILING(LOG(@LeafPageCount)/LOG(10))-5))
        ,@SampleSize    = CASE WHEN @SampleSize > 0 THEN @SampleSize ELSE 1 END
   FROM sys.dm_db_partition_stats
  WHERE object_id       = @pObjectID 
    AND index_id        = @pIndexID
;
--===== Find the key columns and pivot them into a CSV to be used in the ORDER BY of the Dynamic SQL.
     -- (Entire snippet added by Rev 04).
WITH 
cteIndexParts AS
(
 SELECT  idxcol.key_ordinal
        ,KeyColName = INDEX_COL(@Obj2PartName, @pIndexID, key_ordinal)
        ,Direction  = CASE WHEN idxcol.is_descending_key = 0 THEN N'ASC' ELSE N'DESC' END
   FROM sys.indexes       idx
   JOIN sys.index_columns idxcol
         ON idx.object_id  = idxcol.object_id
        AND idx.index_id   = idxcol.index_id
  WHERE idx.object_id      = @pObjectID
    AND idx.index_id       = @pIndexID
    AND idxcol.key_ordinal > 0
)
 SELECT @IndexColsCSV = ISNULL(@IndexColsCSV+N', ','') + QUOTENAME(KeyColName)+' '+Direction
   FROM cteIndexParts
  ORDER BY key_ordinal
;
--=====================================================================================================================
--      Return the 5 part naming for the given index for documentation purposes as well as the sample date and time.
--=====================================================================================================================
 SELECT  ServerName = @@SERVERNAME
        ,DBName     = DB_NAME()
        ,SchemaName = OBJECT_SCHEMA_NAME(@pObjectID)
        ,ObjectName = OBJECT_NAME(@pObjectID)
        ,IndexName  = (SELECT name FROM sys.indexes WHERE object_id = @pObjectID AND index_id = @pIndexID)
        ,SampleDT   = CONVERT(CHAR(20),GETDATE(),113) --Rev 03
;
--=====================================================================================================================
--      Create the list of pages using %%physloc%% in the same order as whatever index we're sampling.
--      The output of the dynamic SQL is stored in the previously formed #IndexPageSpace temporary table.
--      (This section totally rewritten by Rev 04)
--=====================================================================================================================
 SELECT @SQL = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(N'
   WITH 
cteBaseSortOrder AS
(--==== Get the file and page information in the form of PhysLoc (first six bytes contain p1,p2,p3,p4,f1,f2)
 SELECT  PhysLoc   = SUBSTRING(%%physloc%%,1,6) --p1,p2,p3,p4,f1,f2 --We"ll split and convert these later. p = page, f = file
        ,SortOrder = ROW_NUMBER() OVER (ORDER BY <<@IndexColsCSV>>) --Sort by the index key to get the right order of pages.
   FROM <<@Obj2PartName>> WITH (INDEX(<<@pIndexID>>)) --Brute force the code to use the index we"re examining
)
,cteLogicalPageOrder AS
(--===== This reduces the row data down to single pages while still keeping the previously established order.
      -- This is MUCH faster than using ROW_NUMBER or DENSE_RANK to do the same thing with a search on "1".
 SELECT  Physloc
        ,PageSort = ROW_NUMBER() OVER (ORDER BY MIN(SortOrder))-1
   FROM cteBaseSortOrder
  GROUP BY PhysLoc
)--==== For 1 out of every @SampleSize rows, split out the FileID and PageID and save it in the final table.
 INSERT INTO #IndexPageSpace WITH (TABLOCK)
        (PageSort,FileID,PageID)
 SELECT  PageSort
        ,FileID = CONVERT(SMALLINT,SUBSTRING(Physloc,6,1)+SUBSTRING(Physloc,5,1))
        ,PageID = CONVERT(INT     ,SUBSTRING(Physloc,4,1)+SUBSTRING(Physloc,3,1)+SUBSTRING(Physloc,2,1)+SUBSTRING(Physloc,1,1))
   FROM cteLogicalPageOrder
  WHERE PageSort % <<@SampleSize>> = 0
;'      --===== The other end of the replacements
        ,N'"'                ,N'''')
        ,N'<<@IndexColsCSV>>',@IndexColsCSV)
        ,N'<<@Obj2PartName>>',@Obj2PartName)
        ,N'<<@pIndexID>>'    ,CONVERT(NVARCHAR(10),@pIndexID))
        ,N'<<@SampleSize>>'  ,CONVERT(NVARCHAR(10),@SampleSize))
;
--===== Execute the Dynamic SQL to populate the table.
   EXEC (@SQL)
;
--===== Add a clustered index to support the necessary RBAR in the next section.
  ALTER TABLE #IndexPageSpace ADD PRIMARY KEY CLUSTERED (PageSort)
;
--=====================================================================================================================
--      Read each page header using DBCC PAGE to capture the m_freeCnt value, which is used to calculate PageDensity.
--      Note that we do NOT need to set a Trace Flag for this because of the TABLERESULTS option.
--      And, yes, we're calculating some stuff we don't need right now. Those are for future enhancements.
--=====================================================================================================================
--===== Preset the loop control variables
 SELECT  @MaxPageSort   = MAX(PageSort) 
        ,@Counter       = 0 --Yeah... Necessary RBAR on Steroids comin' up!
  FROM #IndexPageSpace
;
--===== Run DBCC PAGE for each page we have stored in the #IndexTable and save the page density info
  WHILE @Counter <= @MaxPageSort
  BEGIN
        --===== Empty the page info table for each iteration. 
        TRUNCATE TABLE #PageInfo
        ;
        --===== Create the dynamic SQL to read the page header for this current page.
             -- Column names changed by Rev 04
         SELECT @SQL  = REPLACE(REPLACE(REPLACE(
                        N'DBCC PAGE (<<DB_Name>>,<<FileID>>,<<PageID>>,0) WITH NO_INFOMSGS, TABLERESULTS;'
                        ,N'<<DB_Name>>',DB_NAME())
                        ,N'<<FileID>>',CONVERT(NVARCHAR(10),FileID)) --File ID of the page
                        ,N'<<PageID>>',CONVERT(NVARCHAR(10),PageID)) --Page ID of the page
           FROM #IndexPageSpace
          WHERE PageSort = @Counter
        ;
        --===== Capture the current page info and save it so we can filter it for what we need.
         INSERT INTO #PageInfo
                (ParentObject,Object,Field,Value)
           EXEC (@SQL)
        ;
        --===== Get the page row count and freespace in bytes. Use the freespace value to calculate PageDensity. 
         SELECT  @PageRowCount  = MAX(CASE WHEN Field = N'm_slotCnt' THEN VALUE ELSE 0 END) --Not currently used
                ,@PageFreeBytes = MAX(CASE WHEN Field = N'm_freeCnt' THEN VALUE ELSE 0 END)
                ,@PageUsedBytes = 8096-@PageFreeBytes --No, 8060 is NOT the correct number here!!!
                ,@PageDensity   = @PageUsedBytes*100.0/8096.0 -- *100.0 is to make this a percentage.
           FROM #PageInfo
        ;
        --===== Update the page info in the pagespace table.
         UPDATE #IndexPageSpace
            SET PageDensity = @PageDensity
          WHERE PageSort    = @Counter
        ;
        --===== Bump the loop counter
         SELECT @Counter = @Counter + @SampleSize
        ;
    END
;
--=====================================================================================================================
--      Create the final output to copy to the IndexDNA(tm) spreadsheet.
--=====================================================================================================================
--===== Final rinse and filter to return the page densities in the correct order to we can see the pattern they form
     -- in the scatter chart in the IndexDNA(tm) spreadsheet.
 SELECT PageSort,PageDensity
   FROM #IndexPageSpace 
  ORDER BY PageSort
;
GO
--=====================================================================================================================
--      Turn the proc into a "system" stored procedure that can be executed from any database.
--=====================================================================================================================
    USE MASTER;  
--===== Reclassify the stored procedure as a system stored procedure.
   EXEC sp_ms_marksystemobject 'sp_IndexDNA'
;  
--===== If the following code returns a 1 for "is_ms_shipped", then it worked.
 SELECT name, is_ms_shipped   
   FROM sys.objects  
  WHERE name = 'sp_IndexDNA'  
;