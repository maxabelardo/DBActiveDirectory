CREATE VIEW [Rotineira].[BackupMsValidacao]
as
SELECT RTRIM(LTRIM(A.Servidor)) AS 'Servidor'
	 , CASE 
	     WHEN  A.Tdb = C.BK                  THEN 'Backup executado com sucesso em todas as bases'
	     WHEN (A.Tdb <> C.BK) AND (B.BK = 1) THEN 'Backup executado com ERRO pelo menos em 1 bases'
		 WHEN (A.Tdb <> C.BK) AND (B.BK > 1) THEN 'Mais de 2 bases apresentaram erro na execução do backup'
		 WHEN  A.Tdb = B.BK                  THEN 'Backup de todas as databases apresentaram ERRO.'
	   END AS 'Execução do Backup.'
	 , CASE 
	     WHEN  A.Tdb = C.BK                  THEN 1
	     WHEN (A.Tdb <> C.BK) AND (B.BK = 1) THEN 2
		 WHEN (A.Tdb <> C.BK) AND (B.BK > 1) THEN 3
		 WHEN  A.Tdb = B.BK                  THEN 4
	   END AS 'Indicador'

FROM (SELECT SERVIDOR, COUNT([BasedeDados]) 'Tdb'
	   FROM [Rotineira].[BackupsMsMonitorMes]
		WHERE ([dbo].[FDIA_SEMANA] (getdate()) = 2 and [DataExecucao] = convert(char(10),DATEADD("DAY", -2 , GETDATE()),103))
	       OR ([dbo].[FDIA_SEMANA] (getdate()) <> 2 and [DataExecucao] = convert(char(10),DATEADD("DAY", -1 , GETDATE()),103)) 
		 GROUP BY SERVIDOR) AS A
LEFT JOIN (SELECT [Servidor], COUNT([BasedeDados]) AS 'BK'
			FROM [Rotineira].[BackupsMsMonitorMes]
			 WHERE (([dbo].[FDIA_SEMANA] (getdate()) = 2 and [DataExecucao] = convert(char(10),DATEADD("DAY", -2 , GETDATE()),103))
	            OR ([dbo].[FDIA_SEMANA] (getdate()) <> 2 and [DataExecucao] = convert(char(10),DATEADD("DAY", -1 , GETDATE()),103)))
				AND [BACKUP] = 1 
			  GROUP BY SERVIDOR) AS B ON B.SERVIDOR = A.SERVIDOR
LEFT JOIN (SELECT [Servidor], COUNT([BasedeDados]) AS 'BK'
			FROM [Rotineira].[BackupsMsMonitorMes]
			 WHERE (([dbo].[FDIA_SEMANA] (getdate()) = 2 and [DataExecucao] = convert(char(10),DATEADD("DAY", -2 , GETDATE()),103))
				OR ([dbo].[FDIA_SEMANA] (getdate()) <> 2 and [DataExecucao] = convert(char(10),DATEADD("DAY", -1 , GETDATE()),103)))
				AND [BACKUP] = 3
			  GROUP BY SERVIDOR) AS C ON C.SERVIDOR = A.SERVIDOR
