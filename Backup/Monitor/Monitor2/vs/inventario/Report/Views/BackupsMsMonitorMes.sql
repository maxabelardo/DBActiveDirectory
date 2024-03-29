﻿


CREATE VIEW [Report].[BackupsMsMonitorMes]
as

SELECT DB.[Servidor]
     , DB.[BasedeDados]
	 , Tamanho
	 , Dia
  FROM [SGBD].[SGBDDatabasesProd] AS DB
  LEFT JOIN (SELECT B.[Servidor]
				  , B.[BasedeDados]
				  , ROUND([backup_size],2) AS 'Tamanho'
				  , DAY((A.[backup_start_date])) AS 'Dia'
				FROM [SGBD].[MtSQLDbBackup] AS A 
				INNER JOIN [SGBD].[SGBDDatabasesProd] AS B ON B.[idSGBD] = A.[idSGBD] AND B.[idDatabases] = A.[idDatabases]
				WHERE A.[backup_start_date] >= [dbo].[F_PrimeiroDiaMesDT] (GETDATE())
				AND A.[backup_start_date] <= [dbo].[F_UltimmoDiaMesDT] (GETDATE())
				AND B.[dbid] NOT IN(1,2,3,4) ) AS BK ON BK.[Servidor] = DB.[Servidor] AND BK.[BasedeDados] = DB.[BasedeDados]
  WHERE DB.[dbid] NOT IN(1,2,3,4) 

/*	SELECT B.[Servidor]
	     , LEFT(B.[BasedeDados],15) AS BasedeDados
         , ROUND([backup_size],2) AS 'Tamanho'
         , DAY((A.[backup_start_date])) AS 'Dia'
    FROM [SGBD].[MtSQLDbBackup] AS A 
    INNER JOIN [SGBD].[SGBDDatabasesProd] AS B ON B.[idSGBD] = A.[idSGBD] AND B.[idDatabases] = A.[idDatabases]
    WHERE A.[backup_start_date] >= [dbo].[F_PrimeiroDiaMesDT] (GETDATE())
    AND A.[backup_start_date] <= [dbo].[F_UltimmoDiaMesDT] (GETDATE())
	AND [dbid] NOT IN(1,2,3,4) AND B.[BasedeDados] NOT LIKE 'ReportServer%' 
	ORDER BY B.[Servidor], LEFT(B.[BasedeDados],15), DAY((A.[backup_start_date]))*/

