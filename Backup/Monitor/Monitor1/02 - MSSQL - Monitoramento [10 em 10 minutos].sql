USE [msdb]
GO

/****** Object:  Job [02 - MSSQL - Monitoramento [10 em 10 minutos]]    Script Date: 19/03/2020 16:51:20 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 19/03/2020 16:51:20 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'02 - MSSQL - Monitoramento [10 em 10 minutos]', 
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
/****** Object:  Step [Monitoramento de acesso.]    Script Date: 19/03/2020 16:51:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Monitoramento de acesso.', 
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

	INSERT INTO [SGBD].[MtSQLControlAccess]
					   ([idDatabases]
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
						select SGBD.[idDatabases]
						     , loginame
							 , cpu
							 , P.hostname
							 , program_name
							 , p.status
							 , blocked
							 , spid 
							 , login_time
							 , GETDATE() as ''''horas Atual''''
							 , DATEDIFF (MI, login_time ,CONVERT(datetime, GETDATE(),121) ) as tempo
						from ''+ RTRIM(@LinkedServer) + ''.master.[dbo].[VW_DBACESSO]  as p
						INNER JOIN [SGBD].[SGBDDatabasesProd] AS [SGBD] ON SGBD.SERVIDOR = ''''''+ RTRIM(@LinkedEstancia)+''''''
						       AND [SGBD].[BasedeDados] COLLATE DATABASE_DEFAULT = p.[namedb]
					    where p.status <> ''''background''''
						
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
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CPU]    Script Date: 19/03/2020 16:51:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CPU', 
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
									   ,[idServerHost]
									   ,[EventTime]
									   ,[cpucount] 
									   ,[SQLServerProcessCPUUtilization]
									   ,[SystemIdleProcess]
									   ,[OtherProcessCPUUtilization]) 
									SELECT [SGBD].idSGBD
									       ,[SGBD].[idServerHost]
										   ,[EventTime]
										   ,[SQLServerProcessCPUUtilization] + [OtherProcessCPUUtilization] ''''cpucount''''
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
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [RAM]    Script Date: 19/03/2020 16:51:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'RAM', 
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

	/**/
			INSERT INTO [SGBD].[MtSQLRam]
					   ([idSGBD]
					   ,[idServerHost] 
					   ,[physicalmemory]
					   ,[sqlmemory]
					   ,[memoryused]
					   ,[totaluserconect]
					   ,[connectionmemory])
					select [SGBD].[idSGBD]
					     , [SGBD].[idServerHost]
					     , i.physical_memory_kb /1024 as ''''physicalmemory''''
						 , case 
						    when cast(c.value as int) = ''''2147483647'''' then i.physical_memory_kb /1024
						     else cast(c.value as int)
						   end ''''sqlmemory''''
						 , (M1.cntr_value / 1024) AS ''''memoryused''''
						 , M3.cntr_value AS ''''totaluserconect''''
						 , (M4.cntr_value / 1024) AS ''''connectionmemory''''
					from ''+ RTRIM(@LinkedServer) + ''.master.sys.dm_os_sys_info as i
					inner join ''+ RTRIM(@LinkedServer) + ''.master.sys.configurations c on c.[name] = ''''max server memory (MB)''''
					inner join ''+ RTRIM(@LinkedServer) + ''.master.sys.dm_os_performance_counters as M1 on M1.counter_name = ''''Total Server Memory (KB)''''
					inner join ''+ RTRIM(@LinkedServer) + ''.master.sys.dm_os_performance_counters as M3 on M3.[counter_name] = ''''User Connections''''
					inner join ''+ RTRIM(@LinkedServer) + ''.master.sys.dm_os_performance_counters as M4 on M4.[counter_name] = ''''Connection Memory (KB)''''
					INNER JOIN [SGBD].[SGBDServidorProd] AS [SGBD] ON SGBD.SERVIDOR = ''''''+ RTRIM(@LinkedEstancia)+''''''

				
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
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Page life expectancy ( Insert PLE )]    Script Date: 19/03/2020 16:51:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Page life expectancy ( Insert PLE )', 
		@step_id=4, 
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
				INSERT INTO [SGBD].[MtSQLPageLifeExp]
					   ([idSGBD]
					   ,[ple_seconds])
						SELECT [SGBD].[idSGBD]
					         , plf.[cntr_value] 
						FROM ''+ RTRIM(@LinkedServer) + ''.master.sys.dm_os_performance_counters as plf 
						INNER JOIN [SGBD].[SGBDServidorProd] AS [SGBD] ON SGBD.SERVIDOR = ''''''+ RTRIM(@LinkedEstancia)+''''''
						WHERE plf.[object_name] LIKE ''''%Manager%''''
						AND plf.[counter_name] = ''''Page life expectancy''''

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
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database file IO (insert data file IO)]    Script Date: 19/03/2020 16:51:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database file IO (insert data file IO)', 
		@step_id=5, 
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
					WHERE a.name like ''LNK_SQL_%'' 
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
	
				INSERT INTO [SGBD].[MtDbFileOI]
 					      ([idMtDbFile]
						  ,[Driver]
						  ,[ReadLatency]
						  ,[WriteLatency]
						  ,[Latency]
						  ,[AvgBPerRead]
						  ,[AvgBPerWrite]
						  ,[AvgBPerTransfer]
						  ,[DataTimer])
						SELECT FS.[idMtDbFile]
							  ,[vfs].[Drive]
							  ,[vfs].[ReadLatency]
							  ,[vfs].[WriteLatency]
							  ,[vfs].[Latency]
							  ,[vfs].[AvgBPerRead]
							  ,[vfs].[AvgBPerWrite]
							  ,[vfs].[AvgBPerTransfer]
							  , GETDATE() 
						FROM ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[VW_DISK_IO] AS [vfs]
						INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.[Servidor] LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''  
						INNER JOIN [SGBD].[SGBDDatabases] AS D on D.[idSGBD] = SGBD.[idSGBD] AND D.BasedeDados COLLATE DATABASE_DEFAULT = [vfs].[DB]
						INNER JOIN [SGBD].[MtDbFile] AS FS ON FS.[idDatabases] = D.[idDatabases] AND FS.[NameFiles] COLLATE DATABASE_DEFAULT = [vfs].namefile
		
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



--- Database file IO (insert data file IO)', 
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Buffe Database]    Script Date: 19/03/2020 16:51:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Buffe Database', 
		@step_id=6, 
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
					WHERE a.name like ''LNK_SQL_%'' 
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
	
			INSERT INTO [SGBD].[MtDbBuffeDB]
					   ([idDatabases]
					   ,[CachedSizeMB])
						SELECT D.[idDatabases]
							 , bf.CachedSizeMB
						FROM (SELECT database_id,	COUNT(*) * 8/1024.0 AS [CachedSizeMB]
							   FROM ''+ RTRIM(@LinkedServer) + ''.[master].sys.dm_os_buffer_descriptors GROUP BY database_id) AS bf
						INNER JOIN ''+ RTRIM(@LinkedServer) + ''.[master].sys.databases db on db.database_id = bf.database_id
						INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.[Servidor] LIKE ''''''+ RTRIM(@LinkedEstancia)+'''''' 
						INNER JOIN [SGBD].[SGBDDatabases] AS D on D.[idSGBD] = SGBD.[idSGBD] AND D.BasedeDados COLLATE DATABASE_DEFAULT = db.name
		
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



--- Database file IO (insert data file IO)', 
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Verifica se o cluster mudou de nó]    Script Date: 19/03/2020 16:51:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Verifica se o cluster mudou de nó', 
		@step_id=7, 
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
					WHERE a.name like ''LNK_SQL_%'' 
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''

Declare @srvClusterOrigem varchar(30)
Declare @srvIdServerHost  INT
Declare @srvClusterAtivo  varchar(30)

	SELECT @srvClusterOrigem = NodeName 
	  FROM ''+ RTRIM(@LinkedServer) + ''.[master].sys.dm_os_cluster_nodes

	SELECT @srvClusterAtivo = HOST.HostName	     
	  FROM [SGBD].[SGBD] AS SGBD
	  INNER JOIN [ServerHost].[ServerHost] AS HOST ON SGBD.[idServerHost] = HOST.[idServerHost]
	  WHERE SGBD.[conectstring] = ''''''+ RTRIM(@LinkedEstancia)+'''''' 

	  SELECT @srvIdServerHost = idServerHost
	  FROM [ServerHost].[ServerHost] 
	  WHERE HostName = @srvClusterOrigem

		IF @srvClusterOrigem <> @srvClusterAtivo
			BEGIN
				UPDATE [SGBD].[SGBD]
					SET idServerHost = @srvIdServerHost
				WHERE [conectstring] = ''''''+ RTRIM(@LinkedEstancia)+'''''' 
			END
	
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



--- Database file IO (insert data file IO)', 
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'A cada 10  minutos', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
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


