

CREATE VIEW [Rotineira].[ReplicacaoPostgresqlListSrv]
as

	 SELECT DISTINCT 
       RTRIM(LTRIM([HostName])) AS 'Servidor'
	  ,[IP]
	  ,RTRIM(LTRIM([SGBD])) AS 'SGBD'
  FROM [SGBD].[SGBDServidorProd] AS A
  WHERE [Servidor] LIKE 'SR-DFLXBDP021%'
     OR [Servidor] LIKE 'SR-DFLXBDP022%'
	OR [Servidor] LIKE 'SR-DFLXBDP025%'
	OR [Servidor] LIKE 'SR-DFLXBDP068%'
	OR [Servidor] LIKE 'SR-DFLXBDP069%'


