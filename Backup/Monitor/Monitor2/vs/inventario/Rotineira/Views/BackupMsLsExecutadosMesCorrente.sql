CREATE VIEW [Rotineira].[BackupMsLsExecutadosMesCorrente]
as
SELECT [Servidor]      
	  , ROUND(SUM([Tamanho]) / 1024, 2) AS 'Total em GB.'
FROM [Rotineira].[BackupsMsMonitorMes]
WHERE [DataExecucao] >= CONVERT(CHAR(10), [dbo].[F_PrimeiroDiaMesDT] (GETDATE()),103)
  AND [DataExecucao] <= CONVERT(CHAR(10), [dbo].[F_UltimmoDiaMesDT]  (GETDATE()),103)
GROUP BY [Servidor]
