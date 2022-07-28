USE [msdb]
GO

/****** Object:  Job [PostgreSQL - Montoramento]    Script Date: 21/06/2021 11:28:43 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 21/06/2021 11:28:43 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'PostgreSQL - Montoramento', 
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
/****** Object:  Step [Replicação Delay]    Script Date: 21/06/2021 11:28:44 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Replicação Delay', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @LinkedServerName nchar(50) 
DECLARE @LinkedServerProduct nchar(50)
DECLARE @ExeScript nchar(3000)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT a.name, rtrim(ltrim(a.product)) as ''product''
			FROM sys.Servers a
				LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
					LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
						WHERE a.name like ''%PGSQL%'' --AND [idServidor] = 11   	
							ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
	/**/
		INSERT INTO [SGBD].[MtPgReplicationDelayTime]
									   ([idSGBD]
									   ,[replication_delay]
									   ,[EventTime]
									   )
										select LK.[idSGBD]										 
											 ,P.replication_delay
											 , getdate() as ''''DataHora''''
										from openquery(''+ RTRIM(@LinkedServerName) + '',''''SELECT    EXTRACT (milliseconds FROM cast((now() - pg_last_xact_replay_timestamp()) AS TIME)) AS replication_delay;'''') as P			
										INNER JOIN [SGBD].[SGBDServidorProd] AS LK ON LK.[HostName] like ''''%''+ RTRIM(@LinkedServerProduct)+ ''%''''

			''
		
	BEGIN TRY
		exec sp_executesql @ExeScript
	END TRY	
	BEGIN CATCH
		PRINT ''Este insert foi ignorado! '';
	END CATCH	
/*
	print @ExeScript
*/
	FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct
END

CLOSE db_for
DEALLOCATE db_for

', 
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Base que estão sendo utilizadas.]    Script Date: 21/06/2021 11:28:44 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Base que estão sendo utilizadas.', 
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
DECLARE @ExeScript nchar(3000)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT a.name, rtrim(ltrim(a.product)) as ''product''
			FROM sys.Servers a
				LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
					LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
						WHERE a.name like ''%PGSQL%'' --AND [idServidor] = 11   	
							ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
	/**/
		INSERT INTO [SGBD].[MtPgControlAccess]
									   ([idSGBD]
									   ,[idDatabases]
									   ,[usename]
									   ,[client_addr]
									   ,[query_start])
										select LK.[idSGBD]
											 , DB.idDatabases 
											 , P.usename
											 , P.client_addr
											 , P.query_start
										from openquery(''+ RTRIM(@LinkedServerName) + '',''''SELECT datname, usename, client_addr, query_start FROM pg_catalog.pg_stat_activity WHERE client_addr IS NOT NULL;'''') as P			
									INNER JOIN [SGBD].[SGBDServidorProd] AS LK ON LK.[HostName] like ''''%''+ RTRIM(@LinkedServerProduct)+ ''%''''
									INNER JOIN [SGBD].[SGBDDatabases] as DB ON DB.[idSGBD] = LK.[idSGBD] AND DB.BasedeDados COLLATE DATABASE_DEFAULT = P.datname COLLATE DATABASE_DEFAULT

			''
		
	BEGIN TRY
		exec sp_executesql @ExeScript
	END TRY	
	BEGIN CATCH
		PRINT ''Este insert foi ignorado! '';
	END CATCH	
/*
	print @ExeScript
*/
	FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct
END

CLOSE db_for
DEALLOCATE db_for

', 
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'A cada 10 minutos', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180605, 
		@active_end_date=99991231, 
		@active_start_time=3000, 
		@active_end_time=235959, 
		@schedule_uid=N'4eb1fcdc-d281-4b25-8beb-648a3b294556'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


