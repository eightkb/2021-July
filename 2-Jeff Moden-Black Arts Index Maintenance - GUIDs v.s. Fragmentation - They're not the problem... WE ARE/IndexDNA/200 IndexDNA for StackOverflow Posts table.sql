--===== This is the code that was used for the demo on how to use sp_IndexDNA(tm).
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    USE StackOverflow2013;
DECLARE @pObjectID INT = OBJECT_ID('dbo.Posts');
   EXEC sp_IndexDNA @pObjectID,1
;
 SELECT * FROM dbo.PhysStats('dbo.Posts');
 SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),@pObjectID,NULL,NULL,'SAMPLED')
;
