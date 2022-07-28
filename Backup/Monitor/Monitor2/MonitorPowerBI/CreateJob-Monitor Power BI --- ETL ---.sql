USE [msdb]
GO

/****** Object:  Job [Monitor Power BI --- ETL ---]    Script Date: 05/07/2021 11:25:55 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 05/07/2021 11:25:55 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Monitor Power BI --- ETL ---', 
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
/****** Object:  Step [Executar powershell]    Script Date: 05/07/2021 11:25:55 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Executar powershell', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @script nvarchar(300)
DECLARE @IdPainel sysname
DECLARE @Site sysname 

	DECLARE DCUR CURSOR LOCAL FAST_FORWARD FOR 

		SELECT DISTINCT 
		       D.[ItemId]
			 , PS.idEstancia
		  FROM [dbo].[DataSource] AS D
		  INNER JOIN [dbo].[Painel] AS PN ON PN.[idObjeto] = D.[idObjeto]
		  INNER JOIN [dbo].[Pasta] AS PS ON PS.[idPasta] = PN.[idPasta]
		WHERE D.DS IS NULL 

	OPEN DCUR

	FETCH NEXT FROM dcur INTO @IdPainel, @Site

	WHILE @@FETCH_STATUS=0
	BEGIN

		SET @script = ''powershell.exe "\\fs3\powerbi$\fontes-de-dados\PowerBIMonitor\idpainel.ps1 -IdPainel '' + ''"''+ @IdPainel + ''" -Site ''+ @Site +''''
		exec xp_cmdshell @script;
		--PRINT @script
        
	   FETCH NEXT FROM DCUR INTO @IdPainel, @Site

	END

CLOSE DCUR
DEALLOCATE DCUR', 
		@database_name=N'MonitorPowerBI', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ETL]    Script Date: 05/07/2021 11:25:55 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ETL', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\PowerBI\MonitorPowerBI\MtPowerBI.dtsx\"" /SERVER "\"S-SEBP19\"" /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [User ad]    Script Date: 05/07/2021 11:25:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'User ad', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @RC int


EXECUTE @RC = [dbo].[SP_ActiveDirectoryUser] ', 
		@database_name=N'MonitorPowerBI', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ad outros]    Script Date: 05/07/2021 11:25:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ad outros', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int


EXECUTE @RC = [dbo].[SP_ActiveDirectoryVisual]', 
		@database_name=N'MonitorPowerBI', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DS]    Script Date: 05/07/2021 11:25:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DS', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @script nvarchar(300)
DECLARE @IdPainel sysname
DECLARE @Site sysname 

TRUNCATE TABLE [dbo].[RespDataSource]

	DECLARE DCUR CURSOR LOCAL FAST_FORWARD FOR 

		SELECT DISTINCT 
		       PN.[ItemId]
			 , PS.idEstancia
		  FROM [dbo].[Painel] AS PN 
		  INNER JOIN [dbo].[Pasta] AS PS ON PS.[idPasta] = PN.[idPasta]
		  WHERE PN.[Tipo] = ''Power BI Report''

	OPEN DCUR

	FETCH NEXT FROM dcur INTO @IdPainel, @Site

	WHILE @@FETCH_STATUS=0
	BEGIN

		SET @script = ''powershell.exe "\\fs3\powerbi$\fontes-de-dados\PowerBIMonitor\idpainel.ps1 -IdPainel '' + ''"''+ @IdPainel + ''" -Site ''+ @Site +''''
		exec xp_cmdshell @script;

		--PRINT @script
        
	   FETCH NEXT FROM DCUR INTO @IdPainel, @Site

	END

CLOSE DCUR
DEALLOCATE DCUR', 
		@database_name=N'MonitorPowerBI', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'A cada 1 hora', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200721, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'45cd1b8e-2942-41a7-9369-215cc21bb780'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


