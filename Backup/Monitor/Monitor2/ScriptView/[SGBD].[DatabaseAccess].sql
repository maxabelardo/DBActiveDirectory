USE [inventario]
GO

/****** Object:  View [SGBD].[DatabaseAccess]    Script Date: 03/07/2021 20:21:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [SGBD].[DatabaseAccess]
AS

SELECT * FROM(
SELECT A.[idSGBD]
      ,A.[idDatabases]
	  ,COUNT(A.[idDatabases]) AS 'Acesso'
      ,CONVERT(DATE,[login_time],11) AS 'Data'
  FROM [SGBD].[MtSQLControlAccess] AS A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases
  GROUP BY A.[idSGBD],A.[idDatabases],CONVERT(DATE,[login_time],11)

UNION ALL

SELECT A.[idSGBD]
      ,A.[idDatabases]
	  ,COUNT(A.[idDatabases]) AS 'Acesso'
      ,CONVERT(date, A.[DataTimer], 111) AS 'Data'
  FROM [SGBD].[MtMySQLControlAccess] A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases
  GROUP BY A.[idSGBD],A.[idDatabases], CONVERT(date, A.[DataTimer], 111)

UNION ALL

SELECT A.[idSGBD]
      ,A.[idDatabases]
	  ,COUNT(A.[idDatabases]) AS 'Acesso'
      ,CONVERT(DATE,[query_start],11) AS 'Data'
  FROM [SGBD].[MtPgControlAccess]A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases
  GROUP BY A.[idSGBD],A.[idDatabases],CONVERT(DATE,[query_start],11)
  ) F

GO


