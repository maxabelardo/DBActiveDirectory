





CREATE VIEW [SGBD].[SGBDEstDB]
AS
SELECT DB.[idDatabases]
      ,DB.[idSGBD]
	  ,CASE 
		WHEN ([Estancia] <> '' ) AND ([Cluster]  = 0 ) THEN ([HostName]+'\'+[Estancia])
		WHEN ([Cluster]  = 1 ) AND ([Estancia] IS NOT NULL ) THEN UPPER(REPLACE([conectstring],',1433',''))
		WHEN ([Cluster]  = 0 ) AND [Estancia] = '' AND [SGBD] <> 'SQL Server' THEN ([HostName] +'\'+ [SGBD]) 
		WHEN ([Cluster]  = 0 ) AND ([SGBD] = 'SQL Server') THEN ([HostName])			
		END AS 'Servidor'
      ,[BasedeDados]
      ,ROUND(SZ.db_size, 2) AS 'SizeMB'
	  ,CONVERT(nCHAR(10),SZ.DataTimer,103) AS 'DataTimer'
      ,SG.[Descricao]
      ,SG.SGBD
	  ,sg.conectstring
      ,[owner]
      ,[dbid]
      ,[created]
      ,[OnlineOffline]
      ,[RestrictAccess]
      ,[recovery_model]
      ,[collation]
      ,[compatibility_level]
      ,[ativo]
  FROM [SGBD].[SGBDDatabases] AS DB
  INNER JOIN [SGBD].[SGBDEst] AS SG ON SG.[idSGBD] = DB.idSGBD
  LEFT JOIN (SELECT [idSGBD],[idDatabases],MAX([DataTimer]) AS 'DataTimer' 
               FROM [SGBD].[MtDbSize]
				GROUP BY [idSGBD] ,[idDatabases]) AS ST ON ST.idSGBD = DB.idSGBD AND ST.idDatabases = DB.idDatabases
  LEFT JOIN [SGBD].[MtDbSize] AS SZ ON SZ.idSGBD = DB.idSGBD AND SZ.idDatabases = DB.idDatabases AND SZ.DataTimer = ST.DataTimer
  WHERE DB.ativo = 1
--  ORDER BY [BasedeDados]
--    AND DB.OnlineOffline = 'ONLINE'

