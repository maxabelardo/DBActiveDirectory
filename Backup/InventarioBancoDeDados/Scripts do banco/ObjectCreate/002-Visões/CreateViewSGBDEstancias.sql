/*******************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 05/12/2021
Data de alteração: 

Descrição
  Está Visão é usada para fasilitar o acesso ao dados da maquina servidor e da instancia instala nele
	A visão unifica as informação e faz uma normatização no campo "HostName"
*******************************************************************************************************/

ALTER VIEW [SGBD].[Estancias]
as
SELECT S.[idDBServidor]
      ,SH.[idSHServidor]
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
  FROM [SGBD].[Servidor] AS S
  INNER JOIN [ServerHost].[Servidor] AS SH ON SH.[idSHServidor] = S.[idSHServidor]
   WHERE SH.ATIVO = 1 AND S.Ativo = 1 AND [EstanciaAtivo] = 1