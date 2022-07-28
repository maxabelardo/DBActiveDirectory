USE [msdb]
GO

/****** Object:  Job [MySQL - Documenta��o dos servidores]    Script Date: 18/06/2021 11:36:17 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 18/06/2021 11:36:17 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'MySQL - Documentação dos servidores', 
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
/****** Object:  Step [Database (Inserir novas bases)]    Script Date: 18/06/2021 11:36:18 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database (Inserir novas bases)', 
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
					WHERE a.name like ''%MySQL%'' 
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''/**/
				INSERT INTO [SGBD].[SGBDDatabases]
						(idSGBD
						,[Basededados]
						,[created]
						,[collation]
						,[owner] )
						select LK.idSGBD
							 , Mysql.SCHEMA_NAME
							 , ''''''''
							 , DEFAULT_COLLATION_NAME AS ''''Status''''
							 , ''''SA''''
						from openquery(''+ RTRIM(@LinkedServerName) + '', ''''SELECT SCHEMA_NAME
														       , DEFAULT_CHARACTER_SET_NAME 
														       , DEFAULT_COLLATION_NAME
														  FROM information_schema.SCHEMATA'''') as Mysql
						INNER JOIN [SGBD].[SGBDServidorProd] AS LK ON LK.[HostName] like ''''%''+ RTRIM(@LinkedServerProduct)+ ''%''''
						WHERE NOT EXISTS (select * from [SGBD].[SGBDDatabases] AS D
										where D.[idSGBD] = LK.[idSGBD] and D.Basededados COLLATE DATABASE_DEFAULT = Mysql.SCHEMA_NAME COLLATE DATABASE_DEFAULT)						
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
/****** Object:  Step [Database (desativar bases que foram deletadas)]    Script Date: 18/06/2021 11:36:18 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database (desativar bases que foram deletadas)', 
		@step_id=2, 
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
					WHERE a.name like ''%MySQL%'' --AND [idServidor] = 11   AND [nameLinkedServer] <> ''LNK_MYSQL_DFLX204''
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
					UPDATE VW
						SET VW.[Ativo] = 0	
					FROM [SGBD].[SGBDDatabases] AS VW
					INNER JOIN [SGBD].[SGBDServidorProd] AS LK ON LK.[HostName] like ''''%''+ RTRIM(@LinkedServerProduct)+ ''%''''
					WHERE NOT EXISTS( select * 
						                from openquery(''+ RTRIM(@LinkedServerName) + '', ''''SELECT SCHEMA_NAME
												                                , DEFAULT_CHARACTER_SET_NAME 
												                                , DEFAULT_COLLATION_NAME
												                           FROM information_schema.SCHEMATA'''') as Mysql
										where VW.idSGBD = LK.idSGBD
									      and VW.Basededados COLLATE DATABASE_DEFAULT = Mysql.SCHEMA_NAME COLLATE DATABASE_DEFAULT)
							AND VW.idSGBD = LK.idSGBD
                            AND VW.[ativo] <> 0	  
                          	
			''
	
	BEGIN TRY
		exec sp_executesql @ExeScript
	END TRY	
	BEGIN CATCH
		PRINT ''Este insert foi ignorado!''+ @LinkedServerName;
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
/****** Object:  Step [Database Size (Insert size)]    Script Date: 18/06/2021 11:36:18 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database Size (Insert size)', 
		@step_id=3, 
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
					WHERE a.name like ''%MySQL%'' --AND [idServidor] = 11   AND [nameLinkedServer] <> ''LNK_MYSQL_DFLX204''
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
						INSERT INTO [SGBD].[MtDbSize]
								   ([idSGBD]
								   ,[idDatabases]
								   ,[db_size])
									select LK.[idSGBD]
										 , DB.[idDatabases]
										 , Mysql.Size
									from openquery(''+ RTRIM(@LinkedServerName) + '', ''''SELECT table_schema 
																					  ,  CAST( (SUM( data_length + index_length ) / 1024 /1024) AS DECIMAL(10,2) ) AS ''''''''Size''''''''
																				  FROM information_schema.TABLES
																				  GROUP BY table_schema;'''') as Mysql
									INNER JOIN [SGBD].[SGBDServidorProd] AS LK ON LK.[HostName] like ''''%''+ RTRIM(@LinkedServerProduct)+ ''%''''
									inner join [SGBD].[SGBDDatabases] as DB ON DB.[idSGBD] = LK.[idSGBD] AND DB.BasedeDados COLLATE DATABASE_DEFAULT = Mysql.table_schema COLLATE DATABASE_DEFAULT
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
/****** Object:  Step [Database (Backups executados)]    Script Date: 18/06/2021 11:36:18 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database (Backups executados)', 
		@step_id=4, 
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
					WHERE a.name like ''%MySQL%'' 
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''/**/
	INSERT INTO [SGBD].[MtMyDbBackup]
						([idDatabases]
						,[idSGBD]
						,[backup_size]
						,[backup_start_date]
						,[backup_end_date])
						select DISTINCT
						       DB.[idDatabases]
						     , LK.idSGBD
							 , Mysql.db_tamanho
							 , Mysql.bkdtinicio
							 , Mysql.bkdtfim
						from openquery(''+ RTRIM(@LinkedServerName) + '', ''''SELECT bkdtinicio
																		       , bkdtfim
																		       , db_name
																		       , servidor
																		       , db_tamanho
																		    FROM logbackup.backupexec
																			WHERE `status` = ''''''''SUCESSO'''''''';'''') as Mysql
						INNER JOIN [SGBD].[SGBDServidorProd] AS LK ON LK.[HostName] like ''''%''+ RTRIM(@LinkedServerProduct)+ ''%''''
						inner join [SGBD].[SGBDDatabasesProd] AS DB ON DB.idSGBD = LK.idSGBD AND DB.BasedeDados = Mysql.db_name 
						WHERE NOT EXISTS (select * from [SGBD].[MtMyDbBackup] AS D
										   where D.[idSGBD] = LK.[idSGBD] 
										     and D.[idDatabases] = DB.[idDatabases]
											 and D.[backup_start_date] = Mysql.bkdtinicio )''

		
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Execu��o di�ria', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180604, 
		@active_end_date=99991231, 
		@active_start_time=81000, 
		@active_end_time=235959, 
		@schedule_uid=N'ef2a58f9-dc40-402c-911b-6f4f990d08c7'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


