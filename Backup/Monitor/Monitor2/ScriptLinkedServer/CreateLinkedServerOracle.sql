USE [msdb]
GO

/****** Object:  Job [ORACLE - Documentação dos Servidores]    Script Date: 28/06/2021 17:18:43 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 28/06/2021 17:18:44 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ORACLE - Documentação dos Servidores', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'IBAMA\81800851120', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database (insert de novas databases, no caso do oracle será schemas no lugar das databases)]    Script Date: 28/06/2021 17:18:45 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database (insert de novas databases, no caso do oracle será schemas no lugar das databases)', 
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

	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like ''%ORACLE%'' 
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''/**/
				INSERT INTO [SGBD].[SGBDDatabases]
						(idSGBD
						,[Basededados]
						,[owner] )
						select LK.idSGBD
							 , ORCL.[OWNER]
							 , ORCL.[OWNER]
						from openquery(''+ RTRIM(@LinkedServerName) + '', ''''SELECT DISTINCT OWNER FROM dba_segments'''') as ORCL
						INNER JOIN [SGBD].[SGBDServidorProd] AS LK ON LK.[HostName] like ''''%''+ RTRIM(@LinkedServerProduct)+ ''%'''' AND LK.SGBD = ''''ORACLE''''
						WHERE NOT EXISTS (select * from [SGBD].[SGBDDatabases] AS D
										where D.[idSGBD] = LK.[idSGBD] and D.Basededados COLLATE DATABASE_DEFAULT = ORCL.OWNER COLLATE DATABASE_DEFAULT)						
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
	FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct
END

CLOSE db_for
DEALLOCATE db_for

', 
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database Size (Insert size)]    Script Date: 28/06/2021 17:18:45 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database Size (Insert size)', 
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

	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like ''%ORACLE%'' 
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''/**/
					INSERT INTO [SGBD].[MtDbSize]
								   ([idSGBD]
								   ,[idDatabases]
								   ,[db_size])
									select LK.[idSGBD]
										 , DB.[idDatabases]
										 , ORCL.tbs_size
									from openquery(''+ RTRIM(@LinkedServerName) + '', ''''select OWNER,round(sum(bytes)/1024/1024 ,2 ) tbs_size from dba_segments group by OWNER'''') as ORCL
									INNER JOIN [SGBD].[SGBDServidorProd] AS LK ON LK.[HostName] like ''''%''+ RTRIM(@LinkedServerProduct)+ ''%''''
									inner join [SGBD].[SGBDDatabases] as DB ON DB.[idSGBD] = LK.[idSGBD] AND DB.BasedeDados COLLATE DATABASE_DEFAULT = ORCL.OWNER COLLATE DATABASE_DEFAULT
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


