







CREATE PROCEDURE [Rotineira].[SP_AtlBackupPgQuadroDetalhado]
AS
DECLARE @Servidor    nchar(50)
DECLARE @BasedeDados  nchar(50)
DECLARE @Backup		 INT
DECLARE @DataExecucao nCHAR(2)
DECLARE @ScriptExec nchar(3000)
DECLARE @lError		 SMALLINT

DECLARE db_for CURSOR FOR

		SELECT Servidor
			  ,[BasedeDados]			  
			  ,[BACKUP]
			  ,LEFT([DataExecucao],2)
		  FROM [Report].[BackupsPgSQLMonitorMesvf]

OPEN db_for 
FETCH NEXT FROM db_for INTO @Servidor ,@BasedeDados, @Backup ,@DataExecucao 

WHILE @@FETCH_STATUS = 0
BEGIN

		IF (@Backup = 1) -- O backup falhou
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''1''
								FROM [Rotineira].[BackupPgSQLQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
								
		END
			ELSE
		IF (@Backup = 2) -- O backup executou com falha
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''2''
								FROM [Rotineira].[BackupPgSQLQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
		END
			ELSE		
		IF (@Backup = 3) -- O backup executou com sucesso.
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''3''
								FROM [Rotineira].[BackupPgSQLQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
		END	
			ELSE		
		IF (@Backup = 4) -- O backup nao executou ainda
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''4''
								FROM [Rotineira].[BackupPgSQLQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
		END	

	EXEC sp_executesql @ScriptExec

	--PRINT @ScriptExec

	FETCH NEXT FROM db_for INTO @Servidor ,@BasedeDados, @Backup ,@DataExecucao
END

CLOSE db_for
DEALLOCATE db_for








