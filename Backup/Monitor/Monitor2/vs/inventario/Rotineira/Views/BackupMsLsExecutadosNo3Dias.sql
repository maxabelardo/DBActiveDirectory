
CREATE VIEW [Rotineira].[BackupMsLsExecutadosNo3Dias]
as
SELECT [Servidor]      
	  , ROUND(SUM([Tamanho]) / 1024, 2) AS 'Total em GB.'
FROM [Rotineira].[BackupsMsMonitorMes]
WHERE [DataExecucao] >= CONVERT(CHAR(10), DATEADD(DAY, - 3, GETDATE()),103) 
  AND [DataExecucao] <= CONVERT(CHAR(10), GETDATE(),103) 
GROUP BY [Servidor]
