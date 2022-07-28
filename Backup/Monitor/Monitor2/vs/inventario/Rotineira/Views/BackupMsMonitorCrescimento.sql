CREATE VIEW [Rotineira].[BackupMsMonitorCrescimento]
as
SELECT [Servidor]
     , [BasedeDados]
	 , [DataExecucao]
	 , CASE 
	    WHEN [Tamanho] IS NULL THEN 0
		ELSE [Tamanho] END AS 'Tamanho'
     , CASE 
	    WHEN LAG([Tamanho], 1, null)OVER(ORDER BY [Servidor], [BasedeDados], [DataExecucao]) IS NULL THEN 0
		ELSE LAG([Tamanho], 1, null)OVER(ORDER BY [Servidor], [BasedeDados], [DataExecucao]) 
		END AS ValorAnterior
	 , CASE 
	    WHEN ROUND([Tamanho] - LAG([Tamanho], 1)OVER(ORDER BY [Servidor], [BasedeDados], [DataExecucao]),2) IS NULL THEN 0
		ELSE ROUND([Tamanho] - LAG([Tamanho], 1)OVER(ORDER BY [Servidor], [BasedeDados], [DataExecucao]),2) 
		END AS 'ValorDiferencia'
  FROM [Rotineira].[BackupsMsMonitorMes]
