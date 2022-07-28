USE [inventario]
GO

/****** Object:  View [SGBD].[SGBDEstDBTable]    Script Date: 03/07/2021 20:22:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [SGBD].[SGBDEstDBTable]
as
SELECT DB.[idDatabases] 
	  ,TB.idSGBDTable
	  ,CASE 
		WHEN ([Estancia] <> '' ) AND ([Cluster]  = 0 ) THEN ([HostName]+'\'+[Estancia])
		WHEN ([Cluster]  = 1 ) AND ([Estancia] IS NOT NULL ) THEN UPPER(REPLACE([conectstring],',1433',''))
		WHEN ([Cluster]  = 0 ) AND [Estancia] = '' AND [SGBD] <> 'SQL Server' THEN ([HostName] +'\'+ [SGBD]) 
		WHEN ([Cluster]  = 0 ) AND ([SGBD] = 'SQL Server') THEN ([HostName])			
		END AS 'Servidor'
      ,[BasedeDados]
	  ,TB.schema_name
	  ,TB.table_name
	  ,ID.Index_name
  FROM [SGBD].[SGBDDatabases]        AS DB
  INNER JOIN [SGBD].[SGBDEst]        AS SG ON SG.[idSGBD] = DB.idSGBD
  INNER JOIN [SGBD].[SGBDTable]      AS TB ON TB.idDatabases = DB.idDatabases
  INNER JOIN [SGBD].[SGBDTableIndex] AS ID ON ID.idSGBDTable = TB.idSGBDTable
  WHERE DB.ativo = 1
    AND (CASE 
		WHEN ([Estancia] <> '' ) AND ([Cluster]  = 0 ) THEN ([HostName]+'\'+[Estancia])
		WHEN ([Cluster]  = 1 ) AND ([Estancia] IS NOT NULL ) THEN UPPER(REPLACE([conectstring],',1433',''))
		WHEN ([Cluster]  = 0 ) AND [Estancia] = '' AND [SGBD] <> 'SQL Server' THEN ([HostName] +'\'+ [SGBD]) 
		WHEN ([Cluster]  = 0 ) AND ([SGBD] = 'SQL Server') THEN ([HostName])			
		END) LIKE 'MCSRV191'
--  ORDER BY [BasedeDados]
--    AND DB.OnlineOffline = 'ONLINE'

GO


