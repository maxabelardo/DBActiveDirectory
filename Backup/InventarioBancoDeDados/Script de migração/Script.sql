/****************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 05/12/2021
Data de alteração: 

Objetivo:
   Migra os dados do banco antigo para a nova estrutura.

****************************************************************************************************/



USE [inventario]
GO

INSERT INTO [InventarioBancoDeDados].[SGBD].[Servidor]
           ([idSHServidor]
           ,[IdTrilha]
           ,[Estancia]
           ,[SGBD]
           ,[IP]
           ,[Local]
           ,[conectstring]
           ,[Porta]
           ,[Cluster]
           ,[Versao]
           ,[Descricao]
           ,[FuncaoServer]
           ,[SobreAdministracao]
           ,[Ativo]
           ,[MemoryConfig]
           ,[EstanciaAtivo])
SELECT H.idSHServidor
      ,T.[IdTrilha]
      ,[Estancia]
      ,[SGBD]
      ,[IP]
      ,[Local]
      ,[conectstring]
      ,[Porta]
      ,[Cluster]
      ,A.[Versao]
      ,''
      ,[FuncaoServer]
      ,[SobreAdministracao]
      ,A.[Ativo]
      ,[MemoryConfig]
      ,[EstanciaAtivo]
  FROM [SGBD].[SGBD] AS A
  INNER JOIN [InventarioBancoDeDados].[dbo].[Trilha] AS T ON T.Trilha = A.[Descricao]
  INNER JOIN [ServerHost].[ServerHost] AS G ON G.idServerHost = A.idServerHost
  INNER JOIN [InventarioBancoDeDados].[ServerHost].[Servidor] AS H ON H.HostName = G.HostName