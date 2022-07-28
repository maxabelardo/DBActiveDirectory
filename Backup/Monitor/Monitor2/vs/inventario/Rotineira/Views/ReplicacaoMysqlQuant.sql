
CREATE VIEW [Rotineira].[ReplicacaoMysqlQuant]
as
SELECT COUNT(DISTINCT [Servidor]) 'Total de servidores'
  FROM [SGBD].[SGBDServidorProd] AS A  
  WHERE [Servidor] LIKE 'SR-DFLXBDP024%'
     OR [Servidor] LIKE 'SR-DFLXBDP026%'
	 OR [Servidor] LIKE 'SR-DFLXBDP056%'
	 OR [Servidor] LIKE 'SR-DFLXBDP067%'
	 OR [Servidor] LIKE 'SR-SGLXBDP010%'
