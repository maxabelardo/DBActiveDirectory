USE [inventario]
GO

/****** Object:  View [SGBD].[DatabaseAccessIP]    Script Date: 03/07/2021 20:22:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [SGBD].[DatabaseAccessIP]
AS
SELECT DISTINCT
       B.Servidor
      ,B.BasedeDados
      ,[MyUser]	AS 'Login'
	  ,REPLACE(LEFT([Host],(CHARINDEX(':',[Host]))),':','')  AS 'IP'
  FROM [SGBD].[MtMySQLControlAccess] AS A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases

UNION ALL

SELECT DISTINCT
       B.Servidor
      ,B.BasedeDados
      ,[loginame] AS 'Login'
      ,[hostname] AS 'IP'	  
  FROM [SGBD].[MtSQLControlAccess]AS A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases

UNION ALL

SELECT DISTINCT
       B.Servidor
      ,B.BasedeDados
      ,[usename] AS 'Login'
      ,[client_addr] AS 'IP'	 
  FROM [SGBD].[MtPgControlAccess]AS A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases

GO


