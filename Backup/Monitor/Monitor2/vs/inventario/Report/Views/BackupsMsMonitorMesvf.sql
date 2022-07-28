




CREATE VIEW [Report].[BackupsMsMonitorMesvf]
AS
SELECT DISTINCT
        C.idSGBD
      , C.Servidor
	  , C.[BasedeDados]
      , [DataExecucao] 
	  , CASE 
	      WHEN CONVERT(datetime, RIGHT(A.[DataExecucao],4)+RIGHT(LEFT(A.[DataExecucao],5),2)+LEFT(A.[DataExecucao],2), 126)
		         < 
			   CONVERT(datetime, CONVERT(Nchar(10),GETDATE(),112), 126) 
			   AND D.[backup_start_date] IS NULL 
			   AND [Rotineira].[F_BackupWindows] (C.idSGBD,CONVERT(datetime, RIGHT(A.[DataExecucao],4)+RIGHT(LEFT(A.[DataExecucao],5),2)+LEFT(A.[DataExecucao],2), 126)) = 1
		  THEN 1 --- FALHOU ERRO 		  
		  WHEN CONVERT(datetime, RIGHT(A.[DataExecucao],4)+RIGHT(LEFT(A.[DataExecucao],5),2)+LEFT(A.[DataExecucao],2), 126)
		         > 
			   CONVERT(datetime, CONVERT(Nchar(10),GETDATE(),112), 126) 
			   AND D.[backup_start_date] IS NULL 
		  THEN 4 --- NÃO EXECUTOU
	      WHEN CONVERT(datetime, RIGHT(A.[DataExecucao],4)+RIGHT(LEFT(A.[DataExecucao],5),2)+LEFT(A.[DataExecucao],2), 126)
		         <= 
			   CONVERT(datetime, CONVERT(Nchar(10),GETDATE(),112), 126) 
			   AND D.[backup_start_date] IS NULL 
			   --AND [Rotineira].[F_BackupWindows] (C.idSGBD,CONVERT(datetime, RIGHT(A.[DataExecucao],4)+RIGHT(LEFT(A.[DataExecucao],5),2)+LEFT(A.[DataExecucao],2), 126)) = 0
		  THEN 4 --- NÃO EXECUTOU
	     ELSE 3 --- EXECUTADO COM SUCESSO 
	      END AS [BACKUP] 
  FROM [Rotineira].[F_RetornoDiaMesAtual]() AS A  
  INNER JOIN [SGBD].[SGBDDatabasesProd] AS C ON C.[dbid] > 4 --AND C.[BasedeDados] NOT LIKE 'ReportServ%'
  INNER JOIN [SGBD].[MnSQLBackupJanela] AS J ON J.idSGBD = C.idSGBD
  LEFT OUTER JOIN [SGBD].[MtSQLDbBackup] AS D ON D.idSGBD = C.idSGBD AND D.idDatabases = C.idDatabases  
	   AND DAY(D.[backup_start_date]) = DAY(convert(datetime,(RIGHT(A.[DataExecucao],4)+'/'+RIGHT(LEFT(A.[DataExecucao],5),2)+'/'+LEFT(A.[DataExecucao],2)) , 111))
	   AND MONTH(D.[backup_start_date]) = MONTH(convert(datetime,(RIGHT(A.[DataExecucao],4)+'/'+RIGHT(LEFT(A.[DataExecucao],5),2)+'/'+LEFT(A.[DataExecucao],2)) , 111)) 
	   AND YEAR(D.[backup_start_date]) = YEAR(convert(datetime,(RIGHT(A.[DataExecucao],4)+'/'+RIGHT(LEFT(A.[DataExecucao],5),2)+'/'+LEFT(A.[DataExecucao],2)) , 111))
  WHERE RIGHT(LEFT(A.[DataExecucao],5),2) = RIGHT(LEFT([dbo].[F_PrimeiroDiaMesCh] (GETDATE())  ,5),2)
    


