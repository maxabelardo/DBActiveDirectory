
CREATE VIEW [SGBD].[DatabaseAccessIP]
AS
SELECT DISTINCT
       B.Servidor
      ,B.BasedeDados
      ,[MyUser]	AS 'Login'
	  ,RTRIM(LTRIM(REPLACE(LEFT([Host],(CHARINDEX(':',[Host]))),':','') )) AS 'IP'
  FROM [SGBD].[MtMySQLControlAccess] AS A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases

UNION ALL

SELECT DISTINCT
       B.Servidor
      ,B.BasedeDados
      ,[loginame] AS 'Login'
      ,RTRIM(LTRIM([hostname])) AS 'IP'	  
  FROM [SGBD].[MtSQLControlAccess]AS A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases

UNION ALL

SELECT DISTINCT
       B.Servidor
      ,B.BasedeDados
      ,[usename] AS 'Login'
      ,RTRIM(LTRIM([client_addr])) AS 'IP'	 
  FROM [SGBD].[MtPgControlAccess]AS A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases

