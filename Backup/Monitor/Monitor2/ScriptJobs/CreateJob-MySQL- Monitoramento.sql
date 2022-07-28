USE [msdb]
GO

/****** Object:  Job [MySQL - Monitoramento]    Script Date: 18/06/2021 11:36:25 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 18/06/2021 11:36:26 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'MySQL - Monitoramento', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database acessos]    Script Date: 18/06/2021 11:36:26 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database acessos', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @LinkedServer nchar(50)
DECLARE @LinkedServidor nchar(50)
DECLARE @ExeScript nchar(3000)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like ''%MySQL%'' --AND [idServidor] = 11   AND [nameLinkedServer] <> ''LNK_MYSQL_DFLX204''
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedServidor

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
       	
			INSERT INTO [SGBD].[MtMySQLControlAccess]
					   ([idSGBD]
					   ,idDatabases
					   ,[Id]
					   ,[MyUser]
					   ,[Host]
					   ,[Command]
					   ,[Time]
					   ,[State]
					   ,[Info])
						select LK.[idSGBD]
						     , b.[idDatabases]
							 , Mysql.Id
							 , Mysql.[User]
							 , Mysql.Host 
							 , Mysql.Command
							 , Mysql.Time
							 , Mysql.State
							 , Mysql.Info
						from openquery(''+ RTRIM(@LinkedServer) + '', ''''SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST;'''') as Mysql
						inner join [SGBD].[SGBDServidorProd] AS LK ON LK.[conectstring] like ''''%''+ RTRIM(REPLACE(@LinkedServidor,''LNK_MYSQL_'',''''))+ ''%'''' AND LK.Servidor like ''''%MySQL'''' 
						inner join [SGBD].[SGBDDatabasesProd] as b on b.[idSGBD] = lk.[idSGBD] and b.[BasedeDados] = Mysql.db
			''
		
	BEGIN TRY
		exec sp_executesql @ExeScript
	END TRY	
	BEGIN CATCH
		PRINT ''Este insert foi ignorado no servidor ''+ @LinkedServidor ;
	END CATCH	
/*
	print @ExeScript
*/
	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedServidor
END

CLOSE db_for
DEALLOCATE db_for', 
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Replica��o]    Script Date: 18/06/2021 11:36:26 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Replicação', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @LinkedServerName nchar(50) 
DECLARE @LinkedServerProduct nchar(50)
DECLARE @ExeScript nchar(4000)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like ''%MySQL%'' --AND [idServidor] = 11   AND [nameLinkedServer] <> ''LNK_MYSQL_DFLX204''
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
	/**/
			INSERT INTO [SGBD].[MtMySQLReplication]
					   ([idSGBD]
					   ,[Master_Host]
					   ,[Master_User]
					   ,[Master_Port]
					   ,[Connect_Retry]
					   ,[Master_Log_File]
					   ,[Slave_IO_Running]
					   ,[Slave_SQL_Running]
					   ,[Read_Master_Log_Pos]
					   ,[Relay_Log_Pos]
					   ,[Exec_Master_Log_Pos]
					   ,[Relay_Log_Space])
						select LK.[idSGBD]
							 , MySQL.Master_Host
							 , MySQL.Master_User
							 , MySQL.Master_Port
							 , MySQL.Connect_Retry
							 , RTRIM(LEFT(MySQL.Master_Log_File,199)) 
							 , MySQL.Slave_IO_Running
							 , MySQL.Slave_SQL_Running
							 , RTRIM(LEFT(MySQL.Read_Master_Log_Pos,199)) 
							 , MySQL.Relay_Log_Pos
							 , MySQL.Exec_Master_Log_Pos
							 , MySQL.Relay_Log_Space
						from openquery(''+ RTRIM(@LinkedServerName) + '', ''''SHOW SLAVE STATUS;  '''') as Mysql
						INNER JOIN [SGBD].[SGBDServidorProd] AS LK ON LK.[HostName] like ''''%''+ RTRIM(@LinkedServerProduct)+ ''%''''	''
		
	BEGIN TRY
		exec sp_executesql @ExeScript
	END TRY	
	BEGIN CATCH
		PRINT ''Este insert foi ignorado!'';
	END CATCH	
/*
	print @ExeScript
*/
	FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct
END

CLOSE db_for
DEALLOCATE db_for', 
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'A cada 30 minutos', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180605, 
		@active_end_date=99991231, 
		@active_start_time=3000, 
		@active_end_time=235959, 
		@schedule_uid=N'ff6a4113-5618-4b59-9375-0b1e4b983b78'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


