USE [msdb]
GO

/****** Object:  Job [MSSQL - Monitoramento]    Script Date: 10/11/2021 18:37:43 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/11/2021 18:37:43 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'MSSQL - Monitoramento', 
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
/****** Object:  Step [Usuário conectado e seções abertas no servidor]    Script Date: 10/11/2021 18:37:43 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Usuário conectado e seções abertas no servidor', 
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
DECLARE @LinkedEstancia nchar(50)
DECLARE @ExeScript nchar(4000)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like ''LNK_SQL_%'' 
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
	
						INSERT [SGBD].[MtUserConnect]
								   ([idSGBD]
								   ,[Login]
								   ,[session_count])
						select [SGBD].[idSGBD],
							   loginame as ''''login_name'''',
							   count(*) AS ''''session_count'''' 
						from ''+ RTRIM(@LinkedServer) + ''.master.sys.sysprocesses
						INNER JOIN [SGBD].[SGBDEst] AS [SGBD] ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''
						GROUP BY [SGBD].[idSGBD], loginame
						
 ''
			

	BEGIN TRY
		exec sp_executesql @ExeScript
	END TRY	
	BEGIN CATCH
		PRINT ''Este insert foi ignorado!'';
	END CATCH	
/*
	print @ExeScript
*/	
	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia
END

CLOSE db_for
DEALLOCATE db_for

', 
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Monitoramento de acesso.]    Script Date: 10/11/2021 18:37:43 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Monitoramento de acesso.', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @LinkedServer nchar(50)
DECLARE @LinkedEstancia nchar(50)
DECLARE @ExeScript nchar(4000)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like ''LNK_SQL_%'' 
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
						INSERT INTO [SGBD].[MtSQLControlAccess]
								   ([idSGBD]
								   ,[idDatabases]
								   ,[loginame]
								   ,[cpu]
								   ,[hostname]
								   ,[program_name]
								   ,[status]
								   ,[blocked]
								   ,[spid]
								   ,[login_time]
								   ,[horasAtual]
								   ,[tempo])           
						select SGBD.[idSGBD],
							   b.[idDatabases],
							   loginame,
							   cpu,
							   P.hostname,
							   program_name,
							   p.status,
							   blocked,
							   spid ,
							   login_time,
							   GETDATE()as ''''horas Atual'''',
							   DATEDIFF (MI, login_time ,CONVERT(datetime, GETDATE(),121) ) as tempo
						from ''+ RTRIM(@LinkedServer) + ''.master.[dbo].[VW_DBACESSO]  as p
						INNER JOIN [SGBD].[SGBDEst] AS [SGBD] ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''
						inner join [SGBD].[SGBDEstDB] AS B on b.[idSGBD] = SGBD.[idSGBD] AND b.[BasedeDados] COLLATE DATABASE_DEFAULT = p.[namedb]
						where p.dbid > 4		 ''
			
	
	BEGIN TRY
		exec sp_executesql @ExeScript
	END TRY	
	BEGIN CATCH
		PRINT ''Este insert foi ignorado!'';
	END CATCH	
/*
	print @ExeScript
*/
	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia
END

CLOSE db_for
DEALLOCATE db_for

', 
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CPU]    Script Date: 10/11/2021 18:37:44 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CPU', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @LinkedServer nchar(50)
DECLARE @LinkedEstancia nchar(50)
DECLARE @ExeScript nchar(4000)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like ''LNK_SQL_%'' 
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''



					CREATE TABLE #Tabletemp(
						EventTime datetime null,
						SQLServerProcessCPUUtilization int null,
						SystemIdleProcess int null,
						OtherProcessCPUUtilization int null
						) 

					INSERT INTO #Tabletemp
							   ([SQLServerProcessCPUUtilization]
							   ,[SystemIdleProcess]
							   ,[OtherProcessCPUUtilization]
							   ,[EventTime]) 
					EXECUTE  ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_Monitor_ServidorCPU] 


					--SET XACT_ABORT ON

							INSERT INTO [SGBD].[MtSQLCPU]
									   (idSGBD
									   ,[EventTime]
									   ,[SQLServerProcessCPUUtilization]
									   ,[SystemIdleProcess]
									   ,[OtherProcessCPUUtilization]) 
									SELECT [SGBD].idSGBD
										   ,[EventTime]
										   ,[SQLServerProcessCPUUtilization]
										   ,[SystemIdleProcess]
										   ,[OtherProcessCPUUtilization]
									FROM #Tabletemp
									INNER JOIN [SGBD].[SGBDServidorProd] AS [SGBD] ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''


					--SET XACT_ABORT OFF


					DROP TABLE #Tabletemp

 ''
			

	BEGIN TRY
	print @LinkedEstancia
		exec sp_executesql @ExeScript
	END TRY	
	BEGIN CATCH
		PRINT ''Este insert foi ignorado!'';
	END CATCH	
/*	
	print @ExeScript
*/
	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia
END

CLOSE db_for
DEALLOCATE db_for

', 
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
		@active_start_date=20190122, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'7a7ae0f5-7034-4e04-91cc-776e92139bef'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


