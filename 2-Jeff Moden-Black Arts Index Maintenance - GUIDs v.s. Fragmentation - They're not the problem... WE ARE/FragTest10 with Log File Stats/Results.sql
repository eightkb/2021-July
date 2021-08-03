
 SELECT  DayNumber
        ,BASELINE   = SUM(CASE WHEN TestName = 'BASELINE'   THEN HourRunDur ELSE 0 END)
        ,NODEFRAG   = SUM(CASE WHEN TestName = 'NODEFRAG'   THEN HourRunDur ELSE 0 END)
        ,BPDD_FF070 = SUM(CASE WHEN TestName = 'BPDD_FF070' THEN HourRunDur ELSE 0 END)
        ,LTDD_FF070 = SUM(CASE WHEN TestName = 'LTDD_FF070' THEN HourRunDur ELSE 0 END)
        ,BPDD_FF080 = SUM(CASE WHEN TestName = 'BPDD_FF080' THEN HourRunDur ELSE 0 END)
        ,LTDD_FF080 = SUM(CASE WHEN TestName = 'LTDD_FF080' THEN HourRunDur ELSE 0 END)
   FROM dbo.IxPageStats
  WHERE TestName IN ('BASELINE','NODEFRAG','BPDD_FF070','LTDD_FF070','BPDD_FF080','LTDD_FF080')
    AND HourNumber > 0
  GROUP BY DayNumber WITH ROLLUP
  ORDER BY DayNumber
;

 SELECT  DayNumber
        ,BASELINE   = SUM(CASE WHEN TestName = 'BASELINE'   THEN DefragDur ELSE 0 END)
        ,NODEFRAG   = SUM(CASE WHEN TestName = 'NODEFRAG'   THEN DefragDur ELSE 0 END)
        ,BPDD_FF070 = SUM(CASE WHEN TestName = 'BPDD_FF070' THEN DefragDur ELSE 0 END)
        ,LTDD_FF070 = SUM(CASE WHEN TestName = 'LTDD_FF070' THEN DefragDur ELSE 0 END)
        ,BPDD_FF080 = SUM(CASE WHEN TestName = 'BPDD_FF080' THEN DefragDur ELSE 0 END)
        ,LTDD_FF080 = SUM(CASE WHEN TestName = 'LTDD_FF080' THEN DefragDur ELSE 0 END)
   FROM dbo.IxPageStats
  WHERE TestName IN ('BASELINE','NODEFRAG','BPDD_FF070','LTDD_FF070','BPDD_FF080','LTDD_FF080')
    AND HourNumber = 0
  GROUP BY DayNumber WITH ROLLUP
  ORDER BY DayNumber
;
 SELECT  DayNumber
        ,BASELINE       = SUM(CASE WHEN TestName = 'BASELINE'       THEN DefragDur ELSE 0 END)
        ,NODEFRAG       = SUM(CASE WHEN TestName = 'NODEFRAG'       THEN DefragDur ELSE 0 END)
        ,BPDD_FF070     = SUM(CASE WHEN TestName = 'BPDD_FF070'     THEN DefragDur ELSE 0 END)
        ,LTDDFull_FF070 = SUM(CASE WHEN TestName = 'LTDDFull_FF070' THEN DefragDur ELSE 0 END)
        ,BPDD_FF080     = SUM(CASE WHEN TestName = 'BPDD_FF080'     THEN DefragDur ELSE 0 END)
        ,LTDDFull_FF080 = SUM(CASE WHEN TestName = 'LTDDFull_FF080' THEN DefragDur ELSE 0 END)
        ,BPDD_FF090     = SUM(CASE WHEN TestName = 'BPDD_FF090'     THEN DefragDur ELSE 0 END)
        ,LTDDFull_FF090 = SUM(CASE WHEN TestName = 'LTDDFull_FF090' THEN DefragDur ELSE 0 END)
   FROM dbo.IxPageStats
  WHERE TestName IN ('BASELINE','NODEFRAG','BPDD_FF070','LTDDFull_FF070','BPDD_FF080','LTDDFull_FF080','BPDD_FF090','LTDDFull_FF090')
    AND HourNumber = 0
  GROUP BY DayNumber WITH ROLLUP
  ORDER BY DayNumber
;

 SELECT  DayNumber
        ,BASELINE   = SUM(CASE WHEN TestName = 'BASELINE'   THEN TLogBackupDur ELSE 0 END)
        ,NODEFRAG   = SUM(CASE WHEN TestName = 'NODEFRAG'   THEN TLogBackupDur ELSE 0 END)
        ,BPDD_FF070 = SUM(CASE WHEN TestName = 'BPDD_FF070' THEN TLogBackupDur ELSE 0 END)
        ,LTDD_FF070 = SUM(CASE WHEN TestName = 'LTDD_FF070' THEN TLogBackupDur ELSE 0 END)
        ,BPDD_FF080 = SUM(CASE WHEN TestName = 'BPDD_FF080' THEN TLogBackupDur ELSE 0 END)
        ,LTDD_FF080 = SUM(CASE WHEN TestName = 'LTDD_FF080' THEN TLogBackupDur ELSE 0 END)
   FROM dbo.IxPageStats
  WHERE TestName IN ('BASELINE','NODEFRAG','BPDD_FF070','LTDD_FF070','BPDD_FF080','LTDD_FF080')
    AND HourNumber = 0
  GROUP BY DayNumber WITH ROLLUP
  ORDER BY DayNumber
;

 SELECT  DayNumber
        ,BASELINE       = SUM(CASE WHEN TestName = 'BASELINE'       THEN TLogBackupDur ELSE 0 END)
        ,NODEFRAG       = SUM(CASE WHEN TestName = 'NODEFRAG'       THEN TLogBackupDur ELSE 0 END)
        ,BPDD_FF070     = SUM(CASE WHEN TestName = 'BPDD_FF070'     THEN TLogBackupDur ELSE 0 END)
        ,LTDDFull_FF070 = SUM(CASE WHEN TestName = 'LTDDFull_FF070' THEN TLogBackupDur ELSE 0 END)
        ,BPDD_FF080     = SUM(CASE WHEN TestName = 'BPDD_FF080'     THEN TLogBackupDur ELSE 0 END)
        ,LTDDFull_FF080 = SUM(CASE WHEN TestName = 'LTDDFull_FF080' THEN TLogBackupDur ELSE 0 END)
        ,BPDD_FF090     = SUM(CASE WHEN TestName = 'BPDD_FF090'     THEN TLogBackupDur ELSE 0 END)
        ,LTDDFull_FF090 = SUM(CASE WHEN TestName = 'LTDDFull_FF090' THEN TLogBackupDur ELSE 0 END)
   FROM dbo.IxPageStats
  WHERE TestName IN ('BASELINE','NODEFRAG','BPDD_FF070','LTDDFull_FF070','BPDD_FF080','LTDDFull_FF080','BPDD_FF090','LTDDFull_FF090')
    AND HourNumber = 0
  GROUP BY DayNumber WITH ROLLUP
  ORDER BY DayNumber
;

 SELECT  DayNumber
        ,BASELINE   = SUM(CASE WHEN TestName = 'BASELINE'   THEN LogFileSizeMB ELSE 0 END)
        ,NODEFRAG   = SUM(CASE WHEN TestName = 'NODEFRAG'   THEN LogFileSizeMB ELSE 0 END)
        ,BPDD_FF070 = SUM(CASE WHEN TestName = 'BPDD_FF070' THEN LogFileSizeMB ELSE 0 END)
        ,LTDD_FF070 = SUM(CASE WHEN TestName = 'LTDD_FF070' THEN LogFileSizeMB ELSE 0 END)
        ,BPDD_FF080 = SUM(CASE WHEN TestName = 'BPDD_FF080' THEN LogFileSizeMB ELSE 0 END)
        ,LTDD_FF080 = SUM(CASE WHEN TestName = 'LTDD_FF080' THEN LogFileSizeMB ELSE 0 END)
        ,BPDD_FF090 = SUM(CASE WHEN TestName = 'BPDD_FF090' THEN LogFileSizeMB ELSE 0 END)
        ,LTDD_FF090 = SUM(CASE WHEN TestName = 'LTDD_FF090' THEN LogFileSizeMB ELSE 0 END)
   FROM dbo.IxPageStats
  WHERE TestName IN ('BASELINE','NODEFRAG','BPDD_FF070','LTDD_FF070','BPDD_FF080','LTDD_FF080','BPDD_FF090','LTDD_FF090')
    AND HourNumber = 0
  GROUP BY DayNumber WITH ROLLUP
  ORDER BY DayNumber
;

 SELECT  DayNumber
        ,BASELINE       = SUM(CASE WHEN TestName = 'BASELINE'       THEN LogFileSizeMB ELSE 0 END)
        ,NODEFRAG       = SUM(CASE WHEN TestName = 'NODEFRAG'       THEN LogFileSizeMB ELSE 0 END)
        ,BPDD_FF070     = SUM(CASE WHEN TestName = 'BPDD_FF070'     THEN LogFileSizeMB ELSE 0 END)
        ,LTDDFull_FF070 = SUM(CASE WHEN TestName = 'LTDDFull_FF070' THEN LogFileSizeMB ELSE 0 END)
        ,BPDD_FF080     = SUM(CASE WHEN TestName = 'BPDD_FF080'     THEN LogFileSizeMB ELSE 0 END)
        ,LTDDFull_FF080 = SUM(CASE WHEN TestName = 'LTDDFull_FF080' THEN LogFileSizeMB ELSE 0 END)
        ,BPDD_FF090     = SUM(CASE WHEN TestName = 'BPDD_FF090'     THEN LogFileSizeMB ELSE 0 END)
        ,LTDDFull_FF090 = SUM(CASE WHEN TestName = 'LTDDFull_FF090' THEN LogFileSizeMB ELSE 0 END)
   FROM dbo.IxPageStats
  WHERE TestName IN ('BASELINE','NODEFRAG','BPDD_FF070','LTDDFull_FF070','BPDD_FF080','LTDDFull_FF080','BPDD_FF090','LTDDFull_FF090')
    AND HourNumber = 0
  GROUP BY DayNumber WITH ROLLUP
  ORDER BY DayNumber
;


 SELECT  DayNumber
        ,BASELINE   = SUM(CASE WHEN TestName = 'BASELINE'   THEN LSNLineCntDiff ELSE 0 END)
        ,NODEFRAG   = SUM(CASE WHEN TestName = 'NODEFRAG'   THEN LSNLineCntDiff ELSE 0 END)
        ,BPDD_FF070 = SUM(CASE WHEN TestName = 'BPDD_FF070' THEN LSNLineCntDiff ELSE 0 END)
        ,LTDD_FF070 = SUM(CASE WHEN TestName = 'LTDD_FF070' THEN LSNLineCntDiff ELSE 0 END)
        ,BPDD_FF080 = SUM(CASE WHEN TestName = 'BPDD_FF080' THEN LSNLineCntDiff ELSE 0 END)
        ,LTDD_FF080 = SUM(CASE WHEN TestName = 'LTDD_FF080' THEN LSNLineCntDiff ELSE 0 END)
        ,BPDD_FF090 = SUM(CASE WHEN TestName = 'BPDD_FF090' THEN LSNLineCntDiff ELSE 0 END)
        ,LTDD_FF090 = SUM(CASE WHEN TestName = 'LTDD_FF090' THEN LSNLineCntDiff ELSE 0 END)
   FROM dbo.IxPageStats
  WHERE TestName IN ('BASELINE','NODEFRAG','BPDD_FF070','LTDD_FF070','BPDD_FF080','LTDD_FF080','BPDD_FF090','LTDD_FF090')
    AND HourNumber = 0
  GROUP BY DayNumber WITH ROLLUP
  ORDER BY DayNumber
;

 SELECT *
   FROM dbo.IxPageStats 
  WHERE TestName IN ('LTDD_FF080')
  ORDER BY DayHour

WITH cteNewPageCount AS
(
 SELECT  TestName
        ,DayNumber
        ,NewPageCount = PageCount-LAG(PageCount,1,0) OVER (PARTITION BY TestName ORDER BY DayHour)
   FROM dbo.IxPageStats 
  WHERE TestName IN ('BASELINE','NODEFRAG','BPDD_FF070','LTDD_FF070','BPDD_FF080','LTDD_FF080','BPDD_FF090','LTDD_FF090')
    AND HourNumber > 0
)
 SELECT  DayNumber
        ,BASELINE   = SUM(CASE WHEN TestName = 'BASELINE'   THEN NewPageCount ELSE 0 END)
        ,NODEFRAG   = SUM(CASE WHEN TestName = 'NODEFRAG'   THEN NewPageCount ELSE 0 END)
        ,BPDD_FF070 = SUM(CASE WHEN TestName = 'BPDD_FF070' THEN NewPageCount ELSE 0 END)
        ,LTDD_FF070 = SUM(CASE WHEN TestName = 'LTDD_FF070' THEN NewPageCount ELSE 0 END)
        ,BPDD_FF080 = SUM(CASE WHEN TestName = 'BPDD_FF080' THEN NewPageCount ELSE 0 END)
        ,LTDD_FF080 = SUM(CASE WHEN TestName = 'LTDD_FF080' THEN NewPageCount ELSE 0 END)
        ,BPDD_FF090 = SUM(CASE WHEN TestName = 'BPDD_FF090' THEN NewPageCount ELSE 0 END)
        ,LTDD_FF090 = SUM(CASE WHEN TestName = 'LTDD_FF090' THEN NewPageCount ELSE 0 END)
   FROM cteNewPageCount
  WHERE TestName IN ('BASELINE','NODEFRAG','BPDD_FF070','LTDD_FF070','BPDD_FF080','LTDD_FF080','BPDD_FF090','LTDD_FF090')
    AND NewPageCount >= 0
  GROUP BY DayNumber WITH ROLLUP
  ORDER BY DayNumber
;

WITH cteNewPageCount AS
(
 SELECT  TestName
        ,DayNumber
        ,NewPageCount = PageCount-LAG(PageCount,1,0) OVER (PARTITION BY TestName ORDER BY DayHour)
   FROM dbo.IxPageStats 
  WHERE TestName IN ('BASELINE','NODEFRAG','BPDD_FF070','LTDDFull_FF070','BPDD_FF080','LTDDFull_FF080','BPDD_FF090','LTDDFull_FF090')
    AND HourNumber > 0
)
 SELECT  DayNumber
        ,BASELINE       = SUM(CASE WHEN TestName = 'BASELINE'       THEN NewPageCount ELSE 0 END)
        ,NODEFRAG       = SUM(CASE WHEN TestName = 'NODEFRAG'       THEN NewPageCount ELSE 0 END)
        ,BPDD_FF070     = SUM(CASE WHEN TestName = 'BPDD_FF070'     THEN NewPageCount ELSE 0 END)
        ,LTDDFull_FF070 = SUM(CASE WHEN TestName = 'LTDDFull_FF070' THEN NewPageCount ELSE 0 END)
        ,BPDD_FF080     = SUM(CASE WHEN TestName = 'BPDD_FF080'     THEN NewPageCount ELSE 0 END)
        ,LTDDFull_FF080 = SUM(CASE WHEN TestName = 'LTDDFull_FF080' THEN NewPageCount ELSE 0 END)
        ,BPDD_FF090     = SUM(CASE WHEN TestName = 'BPDD_FF090'     THEN NewPageCount ELSE 0 END)
        ,LTDDFull_FF090 = SUM(CASE WHEN TestName = 'LTDDFull_FF090' THEN NewPageCount ELSE 0 END)
   FROM cteNewPageCount
  WHERE TestName IN ('BASELINE','NODEFRAG','BPDD_FF070','LTDDFull_FF070','BPDD_FF080','LTDDFull_FF080','BPDD_FF090','LTDDFull_FF090')
    AND NewPageCount >= 0
  GROUP BY DayNumber WITH ROLLUP
  ORDER BY DayNumber
;
