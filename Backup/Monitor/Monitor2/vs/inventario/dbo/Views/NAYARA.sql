
CREATE VIEW [dbo].[NAYARA]
AS

SELECT [idDatabases]
      ,[Host] AS 'Host'
      ,MAX([DataTimer]) AS 'DataTimer'
  FROM [SGBD].[MtMySQLControlAccess]
  GROUP BY [idDatabases],[Host]
UNION ALL
SELECT [idDatabases]
      ,[client_addr] AS 'Host'
      ,MAX([query_start]) AS 'DataTimer'
  FROM [SGBD].[MtPgControlAccess]
  GROUP BY [idDatabases],[client_addr]
UNION ALL
SELECT [idDatabases]
      ,[hostname] AS 'Host'
      ,MAX([login_time]) AS 'DataTimer'
  FROM [SGBD].[MtSQLControlAccess] AS S
  GROUP BY [idDatabases],[hostname]
