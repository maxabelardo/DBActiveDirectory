


CREATE function [Rotineira].[F_BackupWindows](@idSGBD INT, @DATA DATETIME) RETURNS INT  AS
BEGIN
	declare @Dia       datetime
	declare @Convert   char(19)
	declare @return    INT

	--SET @Dia =  DateAdd(day, -0 ,@DATA)

		IF [dbo].[FDIA_SEMANA] (@DATA) = 2 
		BEGIN 
			SELECT @return = [FreqMonday]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
		   ELSE
		IF [dbo].[FDIA_SEMANA] (@DATA) = 3 
		BEGIN 
			SELECT @return = [FreqTuesDay]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
		   ELSE
		IF [dbo].[FDIA_SEMANA] (@DATA) = 4 
		BEGIN 
			SELECT @return = [FreqWednesday]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
		   ELSE
		IF [dbo].[FDIA_SEMANA] (@DATA) = 5 
		BEGIN 
			SELECT @return = [FreqTrursday]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
		   ELSE
		IF [dbo].[FDIA_SEMANA] (@DATA) = 6 
		BEGIN 
			SELECT @return = [FreqFriday]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
		   ELSE		   
		IF [dbo].[FDIA_SEMANA] (@DATA) = 7
		BEGIN 
			SELECT @return = [FreqSaturday]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
		   ELSE
		IF [dbo].[FDIA_SEMANA] (@DATA) = 1 
		BEGIN 
			SELECT @return = [Sunday]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
           
-- SET @return = [dbo].[FDIA_SEMANA] (@Dia)
--             [dbo].[FDIA_SEMANA] (GETDATE())
 
RETURN @return    

END



