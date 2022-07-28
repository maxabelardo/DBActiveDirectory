USE [msdb]
GO

/****** Object:  Job [Monitor Power BI --- Alerta --- V]    Script Date: 05/07/2021 11:25:32 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 05/07/2021 11:25:32 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Monitor Power BI --- Alerta --- V', 
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
/****** Object:  Step [Novos ou alterados (Painel)]    Script Date: 05/07/2021 11:25:32 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Novos ou alterados (Painel)', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @HTML VARCHAR(MAX)
DECLARE @Count INT

SELECT @Count = COUNT(*)
FROM [dbo].[Painel] AS P
WHERE (P.[DataDaCriacao]     >= [dbo].[F_HoraDiaNowZero] (DATEADD(DAY, -1, GETDATE()) ) AND P.[DataDaCriacao]     <= [dbo].[F_HoraDiaNow24] (DATEADD(DAY, -1, GETDATE()))  )
   OR (P.[DataDaModificacao] >= [dbo].[F_HoraDiaNowZero] (DATEADD(DAY, -1, GETDATE()) ) AND P.[DataDaModificacao] <= [dbo].[F_HoraDiaNow24] (DATEADD(DAY, -1, GETDATE()))  )


-- Transforma o conteúdo da query em HTML


IF @Count > 0 
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

	<h1>Alerta</h1>
	<h2>Lista dos painéis novo ou modificados</h2>
	<table>
		<thead>
			<tr>
				<th>Site</th>
				<th>Painel</th>
				<th>Localização</th>
				<th>Data da criação</th>
				<th>Autor</th>
				<th>Data da modificação</th>
				<th>Usuário que modificou</th>
				<th>Tamanho</th>
			</tr>
		</thead>
    
		<tbody>'' +  
		CAST ( 
		(
	SELECT td = E.Servidor, ''''
		 , td = P.[Objeto], '''' 
		 , td = P.[Localizacao], ''''
		 , td = CONVERT(CHAR(10), P.[DataDaCriacao], 3) +'' ''+CONVERT(CHAR(8), P.[DataDaCriacao], 114)  , '''' 
		 , td = P.[CreatedByUserName] , '''' 
		 , td = CONVERT(CHAR(10), P.[DataDaModificacao], 3) +'' ''+CONVERT(CHAR(8), P.[DataDaModificacao], 114)  , '''' 
		 , td = P.[ModifiedByUserName]  , '''' 
		 , td = CAST(ROUND(P.[Tamanho],2) AS CHAR(10)) , '''' 
	FROM [dbo].[Painel] AS P
	  INNER JOIN [dbo].[Pasta] AS PS ON PS.idPasta = P.idPasta
	  INNER JOIN [dbo].Estancia AS E ON E.idEstancia = PS.idEstancia
		WHERE (P.[DataDaCriacao]     >= [dbo].[F_HoraDiaNowZero] (DATEADD(DAY, -1, GETDATE()) ) AND P.[DataDaCriacao]     <= [dbo].[F_HoraDiaNow24] (DATEADD(DAY, -1, GETDATE()))  )
		   OR (P.[DataDaModificacao] >= [dbo].[F_HoraDiaNowZero] (DATEADD(DAY, -1, GETDATE()) ) AND P.[DataDaModificacao] <= [dbo].[F_HoraDiaNow24] (DATEADD(DAY, -1, GETDATE()))  )
	FOR XML PATH(''tr''), TYPE) AS NVARCHAR(MAX) ) + ''
		</tbody>
	</table>
	<br/><br/> '';



	-- Envia o e-mail
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = ''Power BI RS'', -- sysname
		@recipients = ''aberlardo.vicente@infraero.gov.br;jaymefilho@infraero.gov.br'', -- varchar(max)
		@subject = N''Alerta Power BI monitor'', -- nvarchar(255)
		@body = @HTML, -- nvarchar(max)
		@body_format = ''html''

		--jaelalmeida@infraero.gov.br
END
ELSE
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = ''Power BI RS'', -- sysname
		@recipients = ''aberlardo.vicente@infraero.gov.br'', -- varchar(max)
		@subject = N''Não foram detectados alterações nos painéis'', -- nvarchar(255)
		@body = ''Não foram detectados alterações nos painéis'', -- nvarchar(max)
		@body_format = ''html''', 
		@database_name=N'MonitorPowerBI', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Uma vez por dia', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200810, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'47d9e642-50d5-4ad1-9165-b71c6fa74098'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


