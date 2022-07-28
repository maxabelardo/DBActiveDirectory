USE [msdb]
GO

/****** Object:  Job [Monitor Power BI --- Alerta --- Job]    Script Date: 05/07/2021 11:25:06 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 05/07/2021 11:25:06 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Monitor Power BI --- Alerta --- Job', 
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
/****** Object:  Step [Job]    Script Date: 05/07/2021 11:25:06 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Job', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @HTML VARCHAR(MAX)

IF (SELECT COUNT(*) FROM [dbo].[VW_ErrorSchedule]) > 0 
BEGIN
	SET @HTML = ''
	<html>
	<head>
		<title>Titulo</title>
		<style type="text/css">
			table { padding:0; border-spacing: 0; border-collapse: collapse; }
			thead { background: #00B050; border: 1px solid #ddd; }
			th { padding: 10px; font-weight: bold; border: 1px solid #000; color: #fff; }
			tr { padding: 0; }
			td { padding: 5px; border: 1px solid #cacaca; margin:0; text-align: left; }
		</style>
	</head>

	<h1 style="color:Red;">Alerta de ERRO.</h1>
	<h2>Os Painéis listados estão apresentando erro na atualização dos dados durante á última hora.</h2>
	<table>
		<thead>
			<tr>
				<th>Site</th>
				<th>Painel</th>
				<th>Localização</th>
				<th>Data Da Execução</th>
				<th>Status Da Execução</th>
				<th>Duração</th>
				<th>Autor</th>
				<th>Modificador</th>
				<th>Data Da Modificação</th>
				<th>Última Visualização</th>
			</tr>
		</thead>    
			<tbody>'' +  
					CAST ( 
					(
				SELECT td = [Servidor], ''''
						, td = [Objeto], ''''
						, td = [Localizacao], ''''
						, td = [DataDaExecucao], ''''
						, td = [StatusDaExecucao], ''''
						, td = [Duracao], ''''
						, td = [CreatedByUserName], ''''
						, td = [ModifiedByUserName], ''''
						, td = [DataDaModificacao], ''''
						, td = [UltimaVisualizacao], ''''
					FROM [dbo].[VW_ErrorSchedule]
				FOR XML PATH(''tr''), TYPE) AS NVARCHAR(MAX) ) + ''
					</tbody>				</table>
		<br/><br/> '';

	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = ''Power BI RS'', -- sysname
		@recipients = ''aberlardo.vicente@infraero.gov.br'', --;jaymefilho@infraero.gov.br'', -- varchar(max)
		@subject = N''Alerta Power BI Report Server'', -- nvarchar(255)
		@body = @HTML, -- nvarchar(max)
		@body_format = ''html''
END', 
		@database_name=N'MonitorPowerBI', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'de hora em hora', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200819, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'53738588-4223-4a42-ab85-afa34cd78ff7'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


