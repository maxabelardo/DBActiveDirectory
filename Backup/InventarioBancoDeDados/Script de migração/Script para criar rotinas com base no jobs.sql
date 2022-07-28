USE [InventarioBancoDeDados]
GO

INSERT INTO [SGBD].[BDBackupJanela]
           ([idDBServidor]
           ,[idBDBackupTools]
           ,[idBDBackupTpOcorrencia]
           ,[idBDBackupTipo]
           ,[BkIndividualTotal]
           ,[Recurrence]
           ,[Frequency]
           ,[startJanela]
		   ,[endJanela]
		   ,[dateStat])
SELECT B.[idDBServidor]      
      ,'3' AS 'idBDBackupTools'
      ,'1' AS 'idBDBackupTpOcorrencia'
      ,'2' AS 'idBDBackupTipo'
	  ,B.[idBaseDeDados] AS 'BkIndividualTotal'
	  ,V.[Recurrence]
      ,V.[Frequency]
	  ,REPLACE(REPLACE(V.[Frequency],'Occurs every 1 Hour(s) between ',''),'& 23:59:59','') AS 'startJanela' 
	  ,RIGHT(V.[Frequency],8) AS 'endJanela' 
	  ,[ScheduleUsageStartDate]
  FROM [SGBD].[VW_BaseDeDados] AS B
  INNER JOIN (SELECT REPLACE(REPLACE([ScheduleName],'DBA - ',''),' - Backup Log.Backup Log','') AS 'BasedeDados'
			  ,[Recurrence]
			  ,[Frequency]
			  ,[ScheduleUsageStartDate]
			  ,[ScheduleUsageEndDate]
		  FROM [dbo].[VW_JOB]) AS V ON V.BasedeDados COLLATE DATABASE_DEFAULT = B.BasedeDados
  WHERE [dbid] > 4
ORDER BY B.[BasedeDados]


GO


