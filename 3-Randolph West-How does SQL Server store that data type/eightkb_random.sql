SELECT CAST (0x3F003F003F00 AS NCHAR(3))
SELECT CAST (0x3ED826DD0D20 AS NVARCHAR(3))

SELECT CAST(CAST(-0.02 AS DECIMAL(5,2)) AS varbinary(MAX)) UNION ALL
SELECT CAST(CAST(-0.01 AS DECIMAL(5,2)) AS varbinary(MAX)) UNION ALL
SELECT CAST(CAST(0.00 AS DECIMAL(5,2)) AS varbinary(MAX)) UNION ALL
SELECT CAST(CAST(0.01 AS DECIMAL(5,2)) AS varbinary(MAX)) UNION ALL
SELECT CAST(CAST(0.02 AS DECIMAL(5,2)) AS varbinary(MAX)) --UNION ALL

SELECT CAST(CAST(4513.19 AS DECIMAL(19,4)) AS varbinary(MAX)) UNION ALL
SELECT CAST(CAST(4513.19 AS DECIMAL(15,2)) AS varbinary(MAX)) UNION ALL
SELECT CAST(CAST(4513.19 AS DECIMAL(10,4)) AS varbinary(MAX)) UNION ALL
SELECT CAST(CAST(4513.19 AS DECIMAL(17,6)) AS varbinary(MAX)) --UNION ALL