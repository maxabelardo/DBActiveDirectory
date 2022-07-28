USE [msdb]
GO

/****** Object:  Job [00 - MSSQL - Slow Query [Semanal]]    Script Date: 19/03/2020 16:51:11 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 19/03/2020 16:51:11 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'00 - MSSQL - Slow Query [Semanal]', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'D_SEDE\admin-abelardo', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Slow Time]    Script Date: 19/03/2020 16:51:11 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Slow Time', 
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
DECLARE @ExeScript nchar(3000)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like ''LNK_SQL_%'' --AND a.product LIKE ''%HML%''
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
					CREATE TABLE #TB(
					SERVIDOR VARCHAR(20) NULL,
					DATABASENAME VARCHAR(20) NULL,
					MTQ TIME NULL,
					STQ TIME NULL,
					TQ INT NULL,
					SQL_TXT VARCHAR(MAX) NULL,
					QPLAN VARCHAR(MAX) NULL
					)

						INSERT INTO #TB
						EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_SlowQueryTime]

					INSERT INTO [SGBD].[MtDbSlowTime]
							   ([idDatabases]
							   ,[AvgTimeExec]
							   ,[SumTimeExec]
							   ,[TotalExecQuery]
							   ,[QueryText]
							   ,[QueryPlan])
					SELECT BD.[idDatabases]
						 , MTQ
						 , STQ
						 , TQ
						 , SQL_TXT
						 , CAST(QPLAN AS XML)
					FROM #TB
					INNER JOIN [SGBD].[SGBDDatabasesProd] AS BD ON BD.[Servidor] LIKE ''''''+ RTRIM(@LinkedEstancia)+'''''' AND BD.[BasedeDados] COLLATE DATABASE_DEFAULT = #TB.[DATABASENAME]

					drop table #TB	 ''
			

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
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Slow IO Read]    Script Date: 19/03/2020 16:51:11 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Slow IO Read', 
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
DECLARE @ExeScript nchar(3000)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like ''LNK_SQL_%'' --AND a.product LIKE ''%HML%''
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
					CREATE TABLE #TB(
					SERVIDOR VARCHAR(20) NULL,
					DATABASENAME VARCHAR(20) NULL,
					TT INT NULL,
					TL INT NULL,
					TE INT NULL,
					TQ INT NULL,
					AV FLOAT NULL,
					SQL_TXT VARCHAR(MAX) NULL,
					QPLAN VARCHAR(MAX) NULL
					)

						INSERT INTO #TB
						EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_SlowQueryIOR]

					INSERT INTO [SGBD].[MtDbSlowIOR]
							   ([idDatabases]
							   ,[TotaLIORead]
							   ,[TotalIOWrite]
							   ,[TotalIO]
							   ,[AvgIO]
							   ,[TotalExecQuery]
							   ,[QueryText]
							   ,[QueryPlan])	
					SELECT BD.[idDatabases]
						 , TT
						 , TL
						 , TE
						 , TQ
						 , AV
						 , SQL_TXT
						 , CAST(QPLAN AS XML)
					FROM #TB
					INNER JOIN [SGBD].[SGBDDatabasesProd] AS BD ON BD.[Servidor] LIKE ''''''+ RTRIM(@LinkedEstancia)+'''''' AND BD.[BasedeDados] COLLATE DATABASE_DEFAULT = #TB.[DATABASENAME]

					drop table #TB	 ''
			

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
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Slow IO Write]    Script Date: 19/03/2020 16:51:11 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Slow IO Write', 
		@step_id=3, 
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
DECLARE @ExeScript nchar(3000)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like ''LNK_SQL_%'' --AND a.product LIKE ''%HML%''
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
					CREATE TABLE #TB(
					SERVIDOR VARCHAR(20) NULL,
					DATABASENAME VARCHAR(20) NULL,
					TT INT NULL,
					TL INT NULL,
					TE INT NULL,
					TQ INT NULL,
					AV FLOAT NULL,
					SQL_TXT VARCHAR(MAX) NULL,
					QPLAN VARCHAR(MAX) NULL
					)

						INSERT INTO #TB
						EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_SlowQueryIOW]

					INSERT INTO [SGBD].[MtDbSlowIOW]
							   ([idDatabases]
							   ,[TotaLIORead]
							   ,[TotalIOWrite]
							   ,[TotalIO]
							   ,[AvgIO]
							   ,[TotalExecQuery]
							   ,[QueryText]
							   ,[QueryPlan])	
					SELECT BD.[idDatabases]
						 , TT
						 , TL
						 , TE
						 , TQ
						 , AV
						 , SQL_TXT
						 , CAST(QPLAN AS XML)
					FROM #TB
					INNER JOIN [SGBD].[SGBDDatabasesProd] AS BD ON BD.[Servidor] LIKE ''''''+ RTRIM(@LinkedEstancia)+'''''' AND BD.[BasedeDados] COLLATE DATABASE_DEFAULT = #TB.[DATABASENAME]

					drop table #TB	 ''
			

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
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Slow CPU]    Script Date: 19/03/2020 16:51:12 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Slow CPU', 
		@step_id=4, 
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
DECLARE @ExeScript nchar(3000)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like ''LNK_SQL_%'' --AND a.product LIKE ''%HML%''
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
					CREATE TABLE #TB(
					SERVIDOR VARCHAR(20) NULL,
					DATABASENAME VARCHAR(20) NULL,
					ST time NULL,
					AV time NULL,
					TQ INT NULL,
					SQL_TXT VARCHAR(MAX) NULL,
					QPLAN VARCHAR(MAX) NULL
					)

						INSERT INTO #TB
						EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_SlowQueryCPU]
					
					INSERT INTO [SGBD].[MtDbSlowCPU]
							   ([idDatabases]
							   ,[MedioTempoExecCPU]
							   ,[SomaTempo2ExecCPU]
							   ,[TotalExecQuery]
							   ,[QueryText]
							   ,[QueryPlan])
					SELECT BD.[idDatabases]
						 , ST
						 , AV
						 , TQ
						 , SQL_TXT
						 , CAST(QPLAN AS XML)
					FROM #TB
					INNER JOIN [SGBD].[SGBDDatabasesProd] AS BD ON BD.[Servidor] LIKE ''''''+ RTRIM(@LinkedEstancia)+'''''' AND BD.[BasedeDados] COLLATE DATABASE_DEFAULT = #TB.[DATABASENAME]

					drop table #TB	 ''
			

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
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Semanal', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20200318, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959, 
		@schedule_uid=N'cc945f37-3976-4ade-a171-89a32147b4f5'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


