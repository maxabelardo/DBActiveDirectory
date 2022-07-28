





CREATE VIEW [SGBD].[SGBDEst]
as
SELECT S.idSGBD
      ,SH.idServerHost
	  ,UPPER(CASE 
		WHEN ([Estancia] <> '' ) AND ([Cluster]  = 0 ) THEN ([HostName]+'\'+[Estancia])
		WHEN ([Cluster]  = 1 ) AND ([Estancia] IS NOT NULL ) THEN UPPER(REPLACE([conectstring],',1433',''))
		WHEN ([Cluster]  = 0 ) AND [Estancia] = '' AND [SGBD] <> 'SQL Server' THEN ([HostName] +'\'+ [SGBD]) 
		WHEN ([Cluster]  = 0 ) AND ([SGBD] = 'SQL Server') THEN ([HostName])				
		END )AS 'Servidor'
      ,UPPER(SH.HostName) as 'HostName'
      ,[Estancia]
      ,[SGBD]
      ,S.IP AS IP
      ,[Local]
      ,[conectstring]
      ,[Porta]
      ,SH.[PortConect]
      ,S.[Cluster]
      ,S.[Versao]
      ,S.[Descricao]
      ,[FuncaoServer]
	  ,[MemoryConfig]
      ,[SobreAdministracao]
  FROM [SGBD].[SGBD] AS S
  INNER JOIN [ServerHost].[ServerHost] AS SH ON SH.idServerHost = S.idServerHost
   WHERE SH.ATIVO = 1 AND S.Ativo = 1 AND [EstanciaAtivo] = 1
--ORDER BY [SGBD]


