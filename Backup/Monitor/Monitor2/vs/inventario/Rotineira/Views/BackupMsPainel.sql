
CREATE VIEW [Rotineira].[BackupMsPainel]
as
SELECT 'VOLUME DE BACKUP DO DIA:' AS 'TEXTO', Total as 'MEGABYTES', ROUND(Total/1024,2) AS 'GIGABYTES',ROUND(Total/1024/1024,2) AS 'TERABYTES'
FROM (SELECT ROUND(SUM(Tamanho),2) AS 'Total'
      ,CASE WHEN [dbo].[FDIA_SEMANA] (getdate()) = 2 THEN CONVERT(CHAR(10),DATEADD("DAY", -2 , GETDATE()), 103)
	    ELSE CONVERT(CHAR(10),DATEADD("DAY", -1 , GETDATE()), 103) END AS 'Data'
  FROM [Rotineira].[BackupsMsMonitorMes] AS A
  WHERE ([dbo].[FDIA_SEMANA] (getdate())  = 2 and A.[DataExecucao] = CONVERT(char(10),DATEADD("DAY", -2 , GETDATE()),103) )
	 OR ([dbo].[FDIA_SEMANA] (getdate()) <> 2 and A.[DataExecucao] = CONVERT(char(10),DATEADD("DAY", -1 , GETDATE()),103) ) ) D3
UNION ALL
SELECT 'VOLUME DE BACKUP ACUMULADO ÚLTIMOS 3 DIAS:' AS 'TEXTO', Total as 'MEGABYTES', ROUND(Total/1024,2) AS 'GIGABYTES',ROUND(Total/1024/1024,2) AS 'TERABYTES'
FROM (SELECT ROUND(SUM(Tamanho),2) AS 'Total'
      ,CASE WHEN [dbo].[FDIA_SEMANA] (getdate()) = 2 THEN CONVERT(CHAR(10),DATEADD("DAY", -2 , GETDATE()), 103)
	    ELSE CONVERT(CHAR(10),DATEADD("DAY", -1 , GETDATE()), 103) END AS 'Data'
  FROM [Rotineira].[BackupsMsMonitorMes] AS A
   WHERE A.[DataExecucao] >= CONVERT(char(10),DATEADD("DAY", -3 , GETDATE()),103)
     AND A.[DataExecucao] <= CONVERT(char(10),GETDATE(),103)) D3
UNION ALL
SELECT 'VOLUME DE BACKUP ACUMULADO NO MÊS:' AS 'TEXTO', Total as 'MEGABYTES', ROUND(Total/1024,2) AS 'GIGABYTES',ROUND(Total/1024/1024,2) AS 'TERABYTES'
FROM (SELECT ROUND(SUM(Tamanho),2) AS 'Total'
      ,CASE WHEN [dbo].[FDIA_SEMANA] (getdate()) = 2 THEN CONVERT(CHAR(10),DATEADD("DAY", -2 , GETDATE()), 103)
	    ELSE CONVERT(CHAR(10),DATEADD("DAY", -1 , GETDATE()), 103) END AS 'Data'
  FROM [Rotineira].[BackupsMsMonitorMes] AS A
   WHERE A.[DataExecucao] >= CONVERT(char(10),[dbo].[F_PrimeiroDiaMesDT](GETDATE()),103)
     AND A.[DataExecucao] <= CONVERT(char(10),[dbo].[F_UltimmoDiaMesDT] (GETDATE()),103)) D3
