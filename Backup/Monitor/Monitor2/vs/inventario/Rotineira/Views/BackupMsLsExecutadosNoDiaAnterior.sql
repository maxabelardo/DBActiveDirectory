CREATE VIEW [Rotineira].[BackupMsLsExecutadosNoDiaAnterior]
as
SELECT DISTINCT
       RTRIM(LTRIM(A.[Servidor])) AS 'Servidor'
	 , CASE 
	    WHEN CT.Total IS NULL THEN 0
	    ELSE CT.Total
		END AS 'Total em GB.'
	, CT.[Data]
  FROM [Rotineira].[BackupsMsMonitorMes] AS A
  LEFT JOIN (SELECT [Servidor]      
				   ,[DataExecucao] AS 'Data'
				  , ROUND(SUM([Tamanho]) / 1024, 2) AS 'Total'
			  FROM [Rotineira].[BackupsMsMonitorMes]
			   WHERE (dbo.FDIA_SEMANA(GETDATE()) = 2  AND [DataExecucao] = CONVERT(CHAR(10), DATEADD(DAY, - 2, GETDATE()),103) ) 
				  OR (dbo.FDIA_SEMANA(GETDATE()) <> 2 AND [DataExecucao] = CONVERT(CHAR(10), DATEADD(DAY, - 1, GETDATE()),103) )
			   GROUP BY [idSGBD],[Servidor],[DataExecucao]) AS CT ON CT.[Servidor] = A.[Servidor] 
