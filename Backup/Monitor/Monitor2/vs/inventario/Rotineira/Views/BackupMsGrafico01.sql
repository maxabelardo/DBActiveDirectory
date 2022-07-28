/**/
CREATE VIEW [Rotineira].[BackupMsGrafico01]
as
SELECT [Servidor]      
	  , ROUND(SUM([Tamanho]) / 1024, 2) AS 'Total em GB.'
	  , [DataExecucao] AS 'Data'
FROM [Rotineira].[BackupsMsMonitorMes]
WHERE [DataExecucao] >= CONVERT(CHAR(10), [dbo].[F_PrimeiroDiaMesDT] (GETDATE()),103)
  AND [DataExecucao] <= CONVERT(CHAR(10), [dbo].[F_UltimmoDiaMesDT]  (GETDATE()),103)  
GROUP BY [Servidor], [DataExecucao]
HAVING ROUND(SUM([Tamanho]) / 1024, 2) IS NOT NULL

