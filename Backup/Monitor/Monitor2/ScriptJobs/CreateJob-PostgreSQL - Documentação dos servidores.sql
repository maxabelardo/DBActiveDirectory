USE [msdb]
GO

/****** Object:  Job [PostgreSQL - Documenta��o dos servidores]    Script Date: 21/06/2021 11:28:33 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 21/06/2021 11:28:34 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'PostgreSQL - Documentaçãoo dos servidores', 
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
/****** Object:  Step [Database (Backups executados)]    Script Date: 21/06/2021 11:28:35 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database (Backups executados)', 
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
			INSERT INTO [SGBD].[MtPgDbBackup]
					   ([idDatabases]
					   ,[idSGBD]
					   ,[no_encoding_collate]
					   ,[backup_start_date]
					   ,[backup_end_date]
					   ,[ds_dir]
					   ,[st_type]
					   ,[st_size])
						select LK.idDatabases 
						     , LK.[idSGBD]
							 , P.[no_encoding_collate]
							 , P.[dt_date_hour_start]
							 , P.[dt_date_hour_end]
							 , P.[ds_dir]
							 , P.[st_type]
							 , CASE
								WHEN P.[st_size] = 0 THEN 1
							    ELSE P.[st_size]
							   END ''st_size''							 
						from openquery(LNK_Postgres_Backup, ''SELECT no_hostname
																		, no_database
																		, no_encoding_collate
																		, dt_date_hour_start
																		, dt_date_hour_end
																		, no_archive, ds_dir
																		, st_type
																		, st_size
																		, ds_unit
																		, no_organ
																	FROM bdadministrative.backup.tb_control'') P
						inner join [SGBD].[SGBDDatabasesProd] AS LK ON LK.[Servidor] LIKE '''' + CASE
								WHEN CHARINDEX(''.'',P.[no_hostname]) <> 0 THEN REPLACE(LEFT(P.[no_hostname], CHARINDEX(''.'',P.[no_hostname])),''.'','''')
								ELSE P.[no_hostname]
							   END +''%'' +''''
							   AND LK.BasedeDados = P.[no_database]
						WHERE NOT EXISTS(select * from [SGBD].[MtPgDbBackup] AS D
										 where D.[idSGBD]    = LK.[idSGBD] 
										   and D.idDatabases = LK.idDatabases 
										   and D.[backup_start_date]= P.[dt_date_hour_start] )
', 
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database (Inserir novas bases)]    Script Date: 21/06/2021 11:28:35 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database (Inserir novas bases)', 
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
					WHERE a.name like ''%PGSQL%'' and a.name not like ''%LNK_PGSQL_Backup%''--AND [idServidor] = 11   AND [nameLinkedServer] <> ''LNK_MYSQL_DFLX204''
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServerName, @LinkedServerProduct

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
	
				INSERT INTO [SGBD].[SGBDDatabases]
						([idSGBD]
						,[Basededados]
						,[owner] )
						select LK.[idSGBD]
						     , P.[datname]
						     , P.[Owner]
						from openquery(''+ RTRIM(@LinkedServerName) + '', ''''SELECT datname
																	       , pg_catalog.pg_get_userbyid(d.datdba) as "Owner"
																	   FROM pg_catalog.pg_database d
																	   WHERE datname NOT LIKE (''''''''%template%'''''''')'''') P
						INNER JOIN [SGBD].[SGBDServidorProd] AS LK ON LK.[HostName] like ''''%''+ RTRIM(@LinkedServerProduct)+ ''%'''' 
						WHERE NOT EXISTS(select * from [SGBD].[SGBDDatabases] AS D
										 where D.[idSGBD] = LK.[idSGBD] and D.Basededados COLLATE DATABASE_DEFAULT = P.datname COLLATE DATABASE_DEFAULT)
										 
			
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
/****** Object:  Step [Database (Desativa��o)]    Script Date: 21/06/2021 11:28:35 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database (Desativação)', 
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
					WHERE a.name like ''%PGSQL%'' and a.name not like ''%LNK_PGSQL_Backup%''--AND [idServidor] = 11   AND [nameLinkedServer] <> ''LNK_MYSQL_DFLX204''
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
									from openquery(''+ RTRIM(@LinkedServerName) + '', ''''SELECT datname
																	       , pg_catalog.pg_get_userbyid(d.datdba) as "Owner"
																	   FROM pg_catalog.pg_database d
																	   WHERE datname NOT LIKE (''''''''%template%'''''''')'''') P
									where VW.idSGBD = LK.idSGBD
									  and VW.Basededados COLLATE DATABASE_DEFAULT = P.datname COLLATE DATABASE_DEFAULT)
					AND VW.idSGBD = LK.idSGBD
					AND VW.[ativo] <> 0	  		
		
			''
	
	BEGIN TRY
		exec sp_executesql @ExeScript
	END TRY	
	BEGIN CATCH
		PRINT ''Este update apresentou erro no servidor: '' + @LinkedServerName +''\''+@LinkedServerProduct;
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
/****** Object:  Step [Database Size (Insert size)]    Script Date: 21/06/2021 11:28:35 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database Size (Insert size)', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
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
					WHERE a.name like ''%PGSQL%'' and a.name not like ''%LNK_PGSQL_Backup%''--AND [idServidor] = 11   AND [nameLinkedServer] <> ''LNK_MYSQL_DFLX204''
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
										 , DB.idDatabases
										 , CASE RIGHT(P.SIZE,2)
												  WHEN ''''MB'''' THEN RTRIM(REPLACE(P.SIZE,RIGHT(P.SIZE,2),''''''''))
												  WHEN ''''kB'''' THEN (RTRIM(REPLACE(P.SIZE,RIGHT(P.SIZE,2),'''''''')) / 1024)
												  WHEN ''''GB'''' THEN (RTRIM(REPLACE(P.SIZE,RIGHT(P.SIZE,2),'''''''')) * 1024)
											   END AS ''''Size''''
									from openquery(''+ RTRIM(@LinkedServerName) + '', ''''SELECT d.datname AS DBName
																				 , CASE WHEN pg_catalog.has_database_privilege(d.datname, ''''''''CONNECT'''''''')
																				 THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
																				   ELSE ''''''''No Access''''''''
																				 END AS SIZE
																			FROM pg_catalog.pg_database d
																				ORDER BY
																				CASE WHEN pg_catalog.has_database_privilege(d.datname, ''''''''CONNECT'''''''')
																				THEN pg_catalog.pg_database_size(d.datname)
																				ELSE NULL
																				END DESC; '''') as P			
									INNER JOIN [SGBD].[SGBDServidorProd] AS LK ON LK.[HostName] like ''''%''+ RTRIM(@LinkedServerProduct)+ ''%''''
									INNER JOIN [SGBD].[SGBDDatabases] as DB ON DB.[idSGBD] = LK.[idSGBD] AND DB.BasedeDados COLLATE DATABASE_DEFAULT = P.DBName COLLATE DATABASE_DEFAULT
		
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
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Execução diária', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180604, 
		@active_end_date=99991231, 
		@active_start_time=82000, 
		@active_end_time=235959, 
		@schedule_uid=N'76c9042a-1c10-4b68-8153-3bc2dcf45551'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


