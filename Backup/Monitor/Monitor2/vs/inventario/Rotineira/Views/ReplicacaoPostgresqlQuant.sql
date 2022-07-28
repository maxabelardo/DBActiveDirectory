
CREATE VIEW [Rotineira].[ReplicacaoPostgresqlQuant]
as
SELECT COUNT(DISTINCT [Servidor]) 'Total de servidores'
  FROM [SGBD].[SGBDServidorProd] AS A  
  WHERE [Servidor] LIKE 'SR-DFLXBDP022%'
     OR [Servidor] LIKE 'SR-DFLXBDP025%'
	 OR [Servidor] LIKE 'SR-DFLXBDP069%'

