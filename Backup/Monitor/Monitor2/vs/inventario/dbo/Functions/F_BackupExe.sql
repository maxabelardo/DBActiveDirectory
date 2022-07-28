
CREATE FUNCTION [dbo].[F_BackupExe] (@idSGBD int,@DATA DATETIME) RETURNS INT  AS
BEGIN

DECLARE @BKE INT

SELECT @BKE = CASE 
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 2 
				 AND B.[FreqMonday] = 1                  THEN 1
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 3 
				 AND B.[FreqTuesDay] = 1                 THEN 1
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 4 
				 AND B.[FreqWednesday] = 1               THEN 1
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 5 
				 AND B.[FreqTrursday] = 1                THEN 1
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 6 
				 AND B.[FreqFriday] = 1                  THEN 1
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 7 
				 AND B.[FreqSaturday] = 1                THEN 1
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 1 
				 AND B.[Sunday] = 1                      THEN 1
			   ELSE 0
			   END 
		  FROM [SGBD].[SGBDServidorProd] AS A
		  INNER JOIN [SGBD].[MnSQLBackupJanela] AS B ON A.idSGBD = B.idSGBD
		  WHERE A.idSGBD = @idSGBD

  RETURN @BKE
END
