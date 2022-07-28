
CREATE VIEW [Rotineira].[BackupJanela]
AS
SELECT A.[idSGBD]
     , B.Servidor
	 , CASE [dbo].[FDIA_SEMANA] (GETDATE())
	    WHEN 1 THEN [SundayTpBk]
	    WHEN 2 THEN [FreqMondayTpBK]
	    WHEN 3 THEN [FreqTuesDayTpBk]
	    WHEN 4 THEN [FreqWednesdayTpBk]
	    WHEN 5 THEN [FredTrursdayTpBk]
	    WHEN 6 THEN [FreqFridayTpBk]
	    WHEN 7 THEN [FreqSaturdayTpBk]
	   END AS 'TipoBackup'
	 , CASE [dbo].[FDIA_SEMANA] (GETDATE())
	    WHEN 1 THEN [Sunday]
	    WHEN 2 THEN [FreqMonday]
	    WHEN 3 THEN [FreqTuesDay]
	    WHEN 4 THEN [FreqWednesday]
	    WHEN 5 THEN [FreqTrursday]
	    WHEN 6 THEN [FreqFriday]
	    WHEN 7 THEN [FreqSaturday]
	   END AS 'Backup'	   
  FROM [SGBD].[MnSQLBackupJanela] AS A
  INNER JOIN [SGBD].[SGBDServidorProd] AS B ON B.idSGBD = A.idSGBD 
  WHERE [dateEnd] = '2022-12-31 00:00:00.000'

