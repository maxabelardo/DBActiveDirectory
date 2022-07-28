




CREATE VIEW [SGBD].[DatabaseAccessMes]
AS

SELECT DISTINCT * FROM(
SELECT A.[idSGBD]
      ,A.[idDatabases]
	  ,COUNT(A.[idDatabases]) AS 'Acesso'
      ,MONTH([login_time]) AS 'Data'
  FROM [SGBD].[MtSQLControlAccess] AS A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases
  GROUP BY A.[idSGBD],A.[idDatabases], MONTH([login_time]) 

UNION ALL

SELECT A.[idSGBD]
      ,A.[idDatabases]
	  ,COUNT(A.[idDatabases]) AS 'Acesso'
      ,MONTH(A.[DataTimer]) AS 'Data'
  FROM [SGBD].[MtMySQLControlAccess] A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases
  GROUP BY A.[idSGBD],A.[idDatabases], MONTH(A.[DataTimer])

UNION ALL

SELECT A.[idSGBD]
      ,A.[idDatabases]
	  ,COUNT(A.[idDatabases]) AS 'Acesso'
      ,MONTH([query_start]) AS 'Data'
  FROM [SGBD].[MtPgControlAccess]A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases
  GROUP BY A.[idSGBD],A.[idDatabases],MONTH([query_start])
  ) F
  WHERE DATA IS NOT NULL
  --ORDER BY DATA
