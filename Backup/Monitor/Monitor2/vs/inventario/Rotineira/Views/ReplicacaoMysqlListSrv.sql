

CREATE VIEW [Rotineira].[ReplicacaoMysqlListSrv]
as

	 SELECT DISTINCT 
       RTRIM(LTRIM(REPLACE([Servidor],'\MySQL',''))) AS 'Servidor'
	  ,[IP]
	  ,RTRIM(LTRIM([SGBD])) AS 'SGBD'
  FROM [SGBD].[SGBDServidorProd] AS A
  WHERE [Servidor] LIKE 'SR-DFLXBDP023%'
     OR [Servidor] LIKE 'SR-DFLXBDP024%'
	 OR [Servidor] LIKE 'SR-DFLXBDP026%'
	 OR [Servidor] LIKE 'SR-DFLXBDP055%'
	 OR [Servidor] LIKE 'SR-DFLXBDP056%'
	 OR [Servidor] LIKE 'SR-DFLXBDP066%'
	 OR [Servidor] LIKE 'SR-DFLXBDP067%'
	 OR [Servidor] LIKE 'SR-SGLXBDP010%'


