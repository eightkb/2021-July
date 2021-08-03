CREATE DATABASE EightKB;
GO

USE EightKB;
GO

SELECT * FROM decimal_test WHERE col15_2 IN (NULL)

DROP TABLE IF EXISTS decimal_test;
GO

CREATE TABLE decimal_test (
ID INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
col19_4 DECIMAL(19,4),
col15_2 DECIMAL(15,2),
col10_4 DECIMAL(10,4),
col17_6 DECIMAL(17,6)
);
GO
INSERT INTO decimal_test (col19_4, col15_2, col10_4, col17_6) VALUES (4513.19, 4513.19, 4513.19, 4513.19);
GO

DBCC TRACEON(3604);
GO
DBCC IND ('EightKB', 'decimal_test', -1);
GO
DBCC PAGE ('EightKB', 1, 320, 3);


SELECT NEWID()

DROP TABLE IF EXISTS datetime2_test;
GO

CREATE TABLE datetime2_test (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    coltime7 TIME(7),
    coltime6 TIME(6),
    coltime5 TIME(5),
    coltime4 TIME(4),
    coltime3 TIME(3),
    coltime2 TIME(2),
    coltime1 TIME(1),
    coltime0 TIME(0),
    coldt7 DATETIME2(7),
    coldt6 DATETIME2(6),
    coldt5 DATETIME2(5),
    coldt4 DATETIME2(4),
    coldt3 DATETIME2(3),
    coldt2 DATETIME2(2),
    coldt1 DATETIME2(1),
    coldt0 DATETIME2(0),
    colvb7 VARBINARY(40),
    colvb6 VARBINARY(40),
    colvb5 VARBINARY(40),
    colvb4 VARBINARY(40),
    colvb3 VARBINARY(40),
    colvb2 VARBINARY(40),
    colvb1 VARBINARY(40),
    colvb0 VARBINARY(40)
)

DECLARE @dt DATETIME2(7) = SYSDATETIME();
DECLARE @t TIME(7) = CAST(@dt AS TIME);

INSERT INTO datetime2_test (
    coltime7, coltime6, coltime5, coltime4, coltime3, coltime2, coltime1, coltime0,
    coldt7, coldt6, coldt5, coldt4, coldt3, coldt2, coldt1, coldt0,
    colvb7, colvb6, colvb5, colvb4, colvb3, colvb2, colvb1, colvb0
)
VALUES (
    @t, @t, @t, @t, @t, @t, @t, @t,
    @dt, @dt, @dt, @dt, @dt, @dt, @dt, @dt,
    CAST(CAST(@dt AS DATETIME2(7)) AS varbinary(40)),
    CAST(CAST(@dt AS DATETIME2(6)) AS varbinary(40)),
    CAST(CAST(@dt AS DATETIME2(5)) AS varbinary(40)),
    CAST(CAST(@dt AS DATETIME2(4)) AS varbinary(40)),
    CAST(CAST(@dt AS DATETIME2(3)) AS varbinary(40)),
    CAST(CAST(@dt AS DATETIME2(2)) AS varbinary(40)),
    CAST(CAST(@dt AS DATETIME2(1)) AS varbinary(40)),
    CAST(CAST(@dt AS DATETIME2(0)) AS varbinary(40))
)

SELECT * FROM datetime2_test

DBCC TRACEON(3604);
GO
DBCC IND ('EightKB', 'datetime2_test', -1);
GO
DBCC PAGE ('EightKB', 1, 360, 3);

SELECT
    CAST(colvb7 AS DATETIME2(7)),
    CAST(colvb6 AS DATETIME2(6)),
    CAST(colvb5 AS DATETIME2(5)),
    CAST(colvb4 AS DATETIME2(4)),
    CAST(colvb3 AS DATETIME2(3)),
    CAST(colvb2 AS DATETIME2(2)),
    CAST(colvb1 AS DATETIME2(1)),
    CAST(colvb0 AS DATETIME2(0))
FROM datetime2_test

DROP TABLE IF EXISTS smalldatetime_test;
GO

CREATE TABLE smalldatetime_test  (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    col1 SMALLDATETIME,
    col2 SMALLDATETIME,
    col3 SMALLDATETIME
)

insert into smalldatetime_test (col1, col2, col3) VALUES ('2021-07-28 23:59:59.999', '1900-01-01 23:59', '1900-01-01')

SELECT CAST(CAST('1900-01-01 23:59' AS smalldatetime) AS varbinary(40))

SELECT * from smalldatetime_test

DBCC TRACEON(3604)
DBCC IND ('EightKB', 'smalldatetime_test', -1)
DBCC PAGE ('EightKB', 1, 368, 3)

-------

--SELECT CAST(CAST('1899-12-31 11:59' AS smalldatetime) AS varbinary(40)) UNION ALL
SELECT CAST(CAST('1900-01-01 00:00' AS smalldatetime) AS varbinary(40)) UNION ALL
SELECT CAST(CAST('1900-01-01 00:01' AS smalldatetime) AS varbinary(40)) UNION ALL
SELECT CAST(CAST('1900-01-01 00:02' AS smalldatetime) AS varbinary(40)) UNION ALL
SELECT CAST(CAST('1900-01-01 00:03' AS smalldatetime) AS varbinary(40)) UNION ALL
SELECT CAST(CAST('1900-01-01 00:04' AS smalldatetime) AS varbinary(40)) UNION ALL
SELECT CAST(CAST('1900-01-01 23:59' AS smalldatetime) AS varbinary(40)) UNION ALL
SELECT CAST(CAST('1900-01-02 00:00' AS smalldatetime) AS varbinary(40)) UNION ALL
SELECT CAST(CAST('1900-01-03 00:00' AS smalldatetime) AS varbinary(40)) UNION ALL
SELECT CAST(CAST('1900-01-04 00:00' AS smalldatetime) AS varbinary(40)) UNION ALL
SELECT CAST(CAST('1900-01-05 00:00' AS smalldatetime) AS varbinary(40)) UNION ALL
SELECT CAST(CAST('1900-01-06 00:00' AS smalldatetime) AS varbinary(40))

SELECT CAST(0x059F059F AS SMALLDATETIME) UNION ALL
SELECT CAST(0xF95F059F AS SMALLDATETIME) UNION ALL
SELECT CAST(0xFFFF059F AS SMALLDATETIME) UNION ALL
SELECT CAST(0xFFFE059F AS SMALLDATETIME)

SELECT '1899-12-31 11:59',     CAST(CAST('1899-12-31 11:59' AS DATETIME) AS varbinary(40)) UNION ALL
SELECT '1899-12-31 11:59.990', CAST(CAST('1899-12-31 11:59.990' AS DATETIME) AS varbinary(40)) UNION ALL
SELECT '1899-12-31 11:59.993', CAST(CAST('1899-12-31 11:59.993' AS DATETIME) AS varbinary(40)) UNION ALL
SELECT '1899-12-31 11:59.997', CAST(CAST('1899-12-31 11:59.997' AS DATETIME) AS varbinary(40)) UNION ALL
SELECT '1900-01-01 00:00.000', CAST(CAST('1900-01-01 00:00.000' AS DATETIME) AS varbinary(40)) UNION ALL
SELECT '1900-01-01 00:00.003', CAST(CAST('1900-01-01 00:00.003' AS DATETIME) AS varbinary(40)) UNION ALL
SELECT '1900-01-01 00:00.007', CAST(CAST('1900-01-01 00:00.007' AS DATETIME) AS varbinary(40)) UNION ALL
SELECT '1900-01-01 00:00.010', CAST(CAST('1900-01-01 00:00.010' AS DATETIME) AS varbinary(40)) UNION ALL
SELECT '1900-01-01 00:00.013', CAST(CAST('1900-01-01 00:00.013' AS DATETIME) AS varbinary(40))
