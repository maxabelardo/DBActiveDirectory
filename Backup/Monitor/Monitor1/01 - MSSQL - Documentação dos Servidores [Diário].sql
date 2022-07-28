USE [msdb]
GO

/****** Object:  Job [01 - MSSQL - Documentação dos Servidores [Diário]]    Script Date: 19/03/2020 16:51:15 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 19/03/2020 16:51:15 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'01 - MSSQL - Documentação dos Servidores [Diário]', 
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
/****** Object:  Step [Linked Server validadção]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Linked Server validadção', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int
DECLARE @HostName char(50)
DECLARE @Servidor char(50)
DECLARE @SGBD char(30)


DECLARE db_for CURSOR FOR

	SELECT CASE 
	         WHEN ([Estancia] = '''' or [Estancia] = '' '' or [Estancia] is null ) AND [Cluster] = 0 THEN REPLACE([HostName],''-'',''_'')
			 WHEN [Cluster] = 1 THEN [Servidor]
			 ELSE [Estancia] END AS ''HostName'', [Servidor],[conectstring]---, product, Lnk

	  FROM [SGBD].[SGBDServidorProd] AS A 
	  LEFT JOIN (SELECT a.name AS Lnk, a.product 
				   FROM sys.Servers a
					LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
					 LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id) AS B ON B.product = A.[Servidor]
	  WHERE [SGBD] LIKE ''MS SQL Server%'' 
	    AND product IS NULL

OPEN db_for 
FETCH NEXT FROM db_for INTO @HostName, @Servidor,@SGBD
WHILE @@FETCH_STATUS = 0
BEGIN

		EXECUTE @RC = [dbo].[SP_CreateLinkServer_SQL] @HostName,@Servidor,@SGBD

	FETCH NEXT FROM db_for INTO @HostName, @Servidor,@SGBD
END

CLOSE db_for
DEALLOCATE db_for
', 
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database (Inserir novas bases)]    Script Date: 19/03/2020 16:51:15 ******/
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
			INSERT INTO [SGBD].[SGBDDatabases]
					   ([idSGBD]
					   ,[BasedeDados]
					   ,[Descricao]
					   ,[owner]
					   ,[dbid]
					   ,[created]
					   ,[OnlineOffline]
					   ,[RestrictAccess]
					   ,[recovery_model]
					   ,[collation]
					   ,[compatibility_level])
						select SGBD.[idSGBD]
							  ,DB.[name]
							  ,'''''''' AS ''''Descricao''''
							  ,L.[name] AS ''''owner''''
							  ,[database_id] AS ''''dbid''''      
							  ,[create_date]   
							  ,[state_desc]
							  ,[user_access_desc] AS ''''RestrictAccess''''
							  ,[recovery_model_desc] AS ''''recovery_model''''
							  ,[collation_name] AS ''''collation''''
							  ,[compatibility_level]
						from ''+ RTRIM(@LinkedServer) + ''.[master].[sys].[databases] AS DB
						left join ''+ RTRIM(@LinkedServer) + ''.[master].[sys].syslogins  AS L ON L.sid = DB.owner_sid
						inner join [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''
						where NOT EXISTS(select * from [SGBD].[SGBDDatabases] AS D
					                     where D.[idSGBD] = SGBD.[idSGBD] and D.Basededados COLLATE DATABASE_DEFAULT = DB.name COLLATE DATABASE_DEFAULT)''
			

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
/****** Object:  Step [Database (desativar bases que foram deletadas)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database (desativar bases que foram deletadas)', 
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
					WHERE a.name like ''LNK_SQL_%''
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''
						  UPDATE VW
							SET VW.[Ativo] = 0
						  FROM [SGBD].[SGBDDatabases] AS VW
						  INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''
						  WHERE NOT EXISTS(SELECT * 
											FROM ''+ RTRIM(@LinkedServer) + ''.[master].[sys].[databases] AS D 
											 WHERE D.[name] COLLATE DATABASE_DEFAULT = VW.[BasedeDados])
											  AND VW.idSGBD = SGBD.idSGBD
                                    									AND VW.[ativo] <> 0	''
					                     
			

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
/****** Object:  Step [Database (atualização dos dados)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database (atualização dos dados)', 
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
                                    									
							UPDATE VM SET
								  VM.[OnlineOffline]       = LK.[state_desc] 
								, VM.[RestrictAccess]      = LK.[user_access_desc]
								, VM.[recovery_model]      = LK.[recovery_model_desc]
								, VM.[collation]           = LK.[collation_name]
								, VM.[compatibility_level] = LK.[compatibility_level]  
							  FROM [SGBD].[SGBDDatabases] AS VM
							  INNER JOIN [''+ RTRIM(@LinkedServer) + ''].[master].[sys].[databases] AS LK ON LK.[name] COLLATE DATABASE_DEFAULT = VM.[BasedeDados]  
							WHERE VM.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia) + ''''''
							  AND VM.[ativo] <> 0	''
					                     
			

	BEGIN TRY
		exec sp_executesql @ExeScript
	END TRY	
	BEGIN CATCH
		PRINT ''A atualização apresentou erro no servidor '' + @LinkedEstancia;
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
/****** Object:  Step [Database Size (Insert size)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database Size (Insert size)', 
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
	
						INSERT INTO [SGBD].[MtDbSize]
								   ([idDatabases]
								   ,[db_size])
						SELECT D.idDatabases
							  ,VW.[total_size_mb]
						  FROM ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[VW_DBSIZE] AS VW
						  INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.[Servidor] LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''  
						  INNER JOIN [SGBD].[SGBDDatabases] AS D on D.[idSGBD] = SGBD.[idSGBD] AND D.BasedeDados COLLATE DATABASE_DEFAULT = VW.[database_name]

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
/****** Object:  Step [Database file (Inserir novos data files)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database file (Inserir novos data files)', 
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
	
			INSERT INTO [SGBD].[MtDbFile]
					   ([idDatabases]
					   ,[idMtDbFileGroup]
					   ,[NameFiles]
					   ,[typedesc]
					   ,[physical_name])
						select D.[idDatabases]
						     , FG.[idMtDbFileGroup]
							 , mf.name 
							 , mf.type_desc
							 , mf.physical_name
						from ''+ RTRIM(@LinkedServer) + ''.[master].sys.master_files as mf
						inner join ''+ RTRIM(@LinkedServer) + ''.[master].sys.sysdatabases as db on db.dbid = mf.database_id
					    INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.[Servidor] LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''  
						INNER JOIN [SGBD].[SGBDDatabases] AS D on D.[idSGBD] = SGBD.[idSGBD] AND D.BasedeDados COLLATE DATABASE_DEFAULT = db.name
						INNER JOIN [SGBD].[MtDbFileGroup] AS FG ON FG.[idDatabases] = D.[idDatabases] AND FG.[Data_Space_id] = mf.data_space_id
						where NOT EXISTS(select * 
						                  from [SGBD].[MtDbFile] AS dbf 
						                   where dbf.[idDatabases] = D.[idDatabases]
										     and dbf.NameFiles COLLATE DATABASE_DEFAULT = mf.name )    ''
			

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
/****** Object:  Step [Database file Size ( insert data file size)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database file Size ( insert data file size)', 
		@step_id=7, 
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
	
					INSERT INTO [SGBD].[MtDbFilesize]
							   ([idMtDbFile]
							   ,[dbsize]
							   ,[maxsize]
							   ,[growth]
							   ,[txc]
							   ,[DataTimer])			
							select FS.[idMtDbFile]
								 , round((mf.size * 8) / 1024 ,2) as ''''dbsize''''
								 , CASE 
									 WHEN mf.max_size = -1 THEN 0
									 WHEN mf.max_size = 268435456 THEN 0
									 ELSE round((mf.max_size * 8) / 1024 ,2)
								   END AS ''''max_size''''
								 , CASE
									 WHEN mf.growth = 0 THEN ''''Arquivo com tamanho fixo''''     
									 WHEN mf.growth > 0 THEN ''''Arquivo com tamanho automático''''
								   END AS ''''growth''''
								 , CASE 
									WHEN mf.is_percent_growth = ''''0'''' THEN RTRIM(CAST(round((mf.growth * 8) / 1024 ,2) as VarChar(10)))
									WHEN mf.is_percent_growth = ''''1'''' THEN RTRIM(CAST(mf.growth as VarChar(10))) + ''''%''''
									END AS ''''txc'''' 
								 , GETDATE()	 
							from ''+ RTRIM(@LinkedServer) + ''.[master].sys.master_files as mf
							inner join ''+ RTRIM(@LinkedServer) + ''.[master].sys.sysdatabases as db on db.dbid = mf.database_id	
					        INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.[Servidor] LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''  
						    INNER JOIN [SGBD].[SGBDDatabases] AS D on D.[idSGBD] = SGBD.[idSGBD] AND D.BasedeDados COLLATE DATABASE_DEFAULT = db.name
							INNER JOIN [SGBD].[MtDbFile] AS FS ON FS.[idDatabases] = D.[idDatabases] AND FS.[NameFiles] COLLATE DATABASE_DEFAULT = mf.name
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
/****** Object:  Step [File Group ( insert dos files groups)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'File Group ( insert dos files groups)', 
		@step_id=8, 
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
					WHERE a.name like ''LNK_SQL_%'' --and a.product like ''%hml%''
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = ''	
		CREATE TABLE #MtDbFileGroup(
			[Servidor] [varchar](255) NULL,
			[base] [varchar](255) NULL,
			[FileGroup]  [varchar](255) NULL,
			[data_space_id] INT NULL,
			[type_desc] [varchar](255) NULL)

						INSERT INTO #MtDbFileGroup
						EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_FileGroup]
						/**/
			INSERT INTO [SGBD].[MtDbFileGroup]
					   ( [idDatabases]
						,[FileGroup]
						,[Data_Space_id]
						,[Type_Desc])
						SELECT DISTINCT
						       D.idDatabases
						     , TZ.[FileGroup]
							 , TZ.[data_space_id]
							 , TZ.[type_desc]
						FROM #MtDbFileGroup TZ
 						INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR = TZ.[Servidor]
						INNER JOIN [SGBD].[SGBDDatabases] AS D ON D.[idSGBD] = SGBD.[idSGBD] AND RTRIM(LTRIM(D.BasedeDados)) COLLATE DATABASE_DEFAULT = TZ.Base
						WHERE NOT EXISTS(select * 
						                  from [SGBD].[MtDbFileGroup] AS FG
					                       where FG.[idDatabases] = D.[idDatabases]
								             and FG.[FileGroup] COLLATE DATABASE_DEFAULT = TZ.[FileGroup] COLLATE DATABASE_DEFAULT
										     and FG.[Data_Space_id] = TZ.[data_space_id])							   		
										  

						DROP TABLE #MtDbFileGroup
 ''
			

	BEGIN TRY
	print @LinkedServer
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
/****** Object:  Step [Table (Insert novas tabelas vinculadas as dabases)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Table (Insert novas tabelas vinculadas as dabases)', 
		@step_id=9, 
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
DECLARE @Database nchar(30)
DECLARE @idDatabases INT

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
		
		DECLARE db_for2 CURSOR FOR

		SELECT [idDatabases]			  
			  ,[BasedeDados]
		  FROM [SGBD].[SGBDDatabasesProd]
		  WHERE [Servidor] = RTRIM(@LinkedEstancia)
		    AND [dbid] > 4

		OPEN db_for2 
		FETCH NEXT FROM db_for2 INTO @idDatabases, @Database
			WHILE @@FETCH_STATUS = 0
			BEGIN		

			SET @ExeScript = ''
	
				INSERT INTO [SGBD].[MtDbTable]
					   ([idDatabases]
					   ,[schema_name]
					   ,[Table_name])
						select ''''''+ CAST(@idDatabases AS nchar(3))+''''''
						     , INS.TABLE_SCHEMA 
							 , INS.TABLE_NAME 
						FROM ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@Database) + ''.INFORMATION_SCHEMA.TABLES	AS INS					
						WHERE NOT EXISTS(select * from [SGBD].[MtDbTable] AS D
					                     where D.[idDatabases] = ''''''+ CAST(@idDatabases AS nchar(3))+''''''
										   and D.schema_name COLLATE DATABASE_DEFAULT = INS.TABLE_SCHEMA COLLATE DATABASE_DEFAULT
										   and D.Table_name COLLATE DATABASE_DEFAULT = INS.TABLE_NAME COLLATE DATABASE_DEFAULT)
						  AND TABLE_TYPE = ''''BASE TABLE''''


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
				FETCH NEXT FROM db_for2 INTO @idDatabases, @Database
			END

		CLOSE db_for2
		DEALLOCATE db_for2

	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia
END

CLOSE db_for
DEALLOCATE db_for

', 
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Table Index]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Table Index', 
		@step_id=10, 
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
		CREATE TABLE #MtDbTableIndex(
			[Servidor] [varchar](255) NULL,
			[base] [varchar](255) NULL,
			[schema_name] [varchar](255) NULL,
			[table_name] [varchar](255) NULL,
			[Index_name] [varchar](255) NULL,
			[FileGroup] [varchar](255) NULL,
			[type_desc] [varchar](255) NULL)

						INSERT INTO #MtDbTableIndex
						EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_TablesIndex] 
						/**/
			INSERT INTO [SGBD].[MtDbTableIndex]
					   ( [idMtDbTable]
					    ,[idMtDbFileGroup]
						,[Index_name]
						,[type_desc])
						SELECT DBT.[idMtDbTable]
						     , FG.[idMtDbFileGroup]
						     , TZ.[Index_name]
						     , TZ.[type_desc]
						FROM #MtDbTableIndex TZ
 						INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR = TZ.[Servidor]
						INNER JOIN [SGBD].[SGBDDatabases] AS D ON D.[idSGBD] = SGBD.[idSGBD] AND RTRIM(LTRIM(D.BasedeDados)) COLLATE DATABASE_DEFAULT = TZ.Base
						INNER JOIN [SGBD].[MtDbFileGroup] AS FG ON FG.[idDatabases] = D.[idDatabases] AND FG.[FileGroup] COLLATE DATABASE_DEFAULT = TZ.[FileGroup]
						INNER JOIN [SGBD].[MtDbTable] AS DBT 
						        ON DBT.[idDatabases] = D.[idDatabases] 
							   AND RTRIM(LTRIM(DBT.[schema_name])) COLLATE DATABASE_DEFAULT = TZ.schema_name
							   AND RTRIM(LTRIM(DBT.[Table_name]))  COLLATE DATABASE_DEFAULT = TZ.Table_name  		
						WHERE NOT EXISTS(select * 
						                  from [SGBD].[MtDbTableIndex] AS TW
					                       where TW.[idMtDbTable] = DBT.[idMtDbTable]
										     and TW.[idMtDbFileGroup] = FG.[idMtDbFileGroup]
								             and TW.[Index_name] COLLATE DATABASE_DEFAULT = TZ.[Index_name] COLLATE DATABASE_DEFAULT)							   		


						DROP TABLE #MtDbTableIndex
 ''
			

	BEGIN TRY
	print @LinkedServer
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
/****** Object:  Step [Table Size (Insert size)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Table Size (Insert size)', 
		@step_id=11, 
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
		CREATE TABLE #MtDbTableSize(
			[Servidor] [varchar](255) NULL,
			[base] [varchar](255) NULL,
			[schema_name] [varchar](255) NULL,
			[table_name] [varchar](255) NULL,
			[ReservadoKB] [real] NULL,
			[DadosKB] [real] NULL,
			[IndicesKB] [real] NULL,
			[TotalLinhas] [int] NULL)


						INSERT INTO #MtDbTableSize
						EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_TablesSize]
						
			INSERT INTO [SGBD].[MtDbTableSize]
					   ([idMtDbTable]
					   ,[ReservadoKB]
					   ,[DadosKB]
					   ,[IndicesKB]
					   ,[TotalLinhas])
						SELECT DBT.[idMtDbTable]
						     , TZ.[ReservadoKB]
							 , TZ.[DadosKB]
							 , TZ.[IndicesKB]
							 , TZ.[TotalLinhas]
						FROM #MtDbTableSize TZ
 						INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR = TZ.[Servidor]
						INNER JOIN [SGBD].[SGBDDatabases] AS D ON D.[idSGBD] = SGBD.[idSGBD] AND RTRIM(LTRIM(D.BasedeDados)) COLLATE DATABASE_DEFAULT = TZ.Base
						INNER JOIN [SGBD].[MtDbTable] AS DBT 
						        ON DBT.[idDatabases] = D.[idDatabases] 
							   AND RTRIM(LTRIM(DBT.[schema_name])) COLLATE DATABASE_DEFAULT = TZ.schema_name
							   AND RTRIM(LTRIM(DBT.[Table_name]))  COLLATE DATABASE_DEFAULT = TZ.Table_name  		


						DROP TABLE #MtDbTableSize
 ''
			

	BEGIN TRY
	print @LinkedServer
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
/****** Object:  Step [Table index size ( insert index size)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Table index size ( insert index size)', 
		@step_id=12, 
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
		CREATE TABLE #MtDbTableIndexSize(
			[Servidor] [varchar](255) NULL,
			[base] [varchar](255) NULL,
			[schema_name] [varchar](255) NULL,
			[table_name] [varchar](255) NULL,
			[Index_name] [varchar](255) NULL,
			[type_desc] [varchar](255) NULL,
			[IndexSizeKB] [REAL] NULL,
			[row_count] INT NULL)

						INSERT INTO #MtDbTableIndexSize
						EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_TablesIndexSize]
						/**/
			INSERT INTO [SGBD].[MtDbTableIndexSize]
					   ([idMtDbTableIndex]
						,[SizeKB]
						,[RowCount])
						SELECT TI.[idMtDbTableIndex]
						     , TZ.[IndexSizeKB]
							 , TZ.row_count
						FROM #MtDbTableIndexSize TZ
 						INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR = TZ.[Servidor]
						INNER JOIN [SGBD].[SGBDDatabases] AS D ON D.[idSGBD] = SGBD.[idSGBD] AND RTRIM(LTRIM(D.BasedeDados)) COLLATE DATABASE_DEFAULT = TZ.Base
						INNER JOIN [SGBD].[MtDbTable] AS DBT 
						        ON DBT.[idDatabases] = D.[idDatabases] 
							   AND RTRIM(LTRIM(DBT.[schema_name])) COLLATE DATABASE_DEFAULT = TZ.schema_name
							   AND RTRIM(LTRIM(DBT.[Table_name]))  COLLATE DATABASE_DEFAULT = TZ.Table_name  
					    INNER JOIN [SGBD].[MtDbTableIndex] AS TI ON TI.[idMtDbTable] = DBT.[idMtDbTable] 
						       AND TI.[Index_name] COLLATE DATABASE_DEFAULT = TZ.[Index_name]


						DROP TABLE #MtDbTableIndexSize
 ''
			

	BEGIN TRY
	print @LinkedServer
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
/****** Object:  Step [Table index mal utilizados (insert index que estão desbanlanciados em sua utilização)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Table index mal utilizados (insert index que estão desbanlanciados em sua utilização)', 
		@step_id=13, 
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
		CREATE TABLE #MtDbTableIndexMalUtz(
			[Servidor] [varchar](255) NULL,
			[base] [varchar](255) NULL,
			[schema_name] [varchar](255) NULL,
			[table_name] [varchar](255) NULL,
			[Index_name] [varchar](255) NULL,
			[IndexID] INT NULL,
			[TotalWrites] INT NULL,
			[TotalReads] INT NULL,
			[Difference] INT NULL)

						INSERT INTO #MtDbTableIndexMalUtz
						EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_TablesIndexMalUtz]
						/**/
			INSERT INTO [SGBD].[MtDbTableIndexMalUtz]
					   ([idMtDbTableIndex]
						,[TotalWrites]
						,[TotalReads]
						,[Difference])
						SELECT TI.[idMtDbTableIndex]
						     , TZ.[TotalWrites]
						     , TZ.[TotalReads]
						     , TZ.[Difference]
						FROM #MtDbTableIndexMalUtz TZ
 						INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR = TZ.[Servidor]
						INNER JOIN [SGBD].[SGBDDatabases] AS D ON D.[idSGBD] = SGBD.[idSGBD] AND RTRIM(LTRIM(D.BasedeDados)) COLLATE DATABASE_DEFAULT = TZ.Base
						INNER JOIN [SGBD].[MtDbTable] AS DBT 
						        ON DBT.[idDatabases] = D.[idDatabases] 
							   AND RTRIM(LTRIM(DBT.[schema_name])) COLLATE DATABASE_DEFAULT = TZ.schema_name
							   AND RTRIM(LTRIM(DBT.[Table_name]))  COLLATE DATABASE_DEFAULT = TZ.Table_name  
					    INNER JOIN [SGBD].[MtDbTableIndex] AS TI ON TI.[idMtDbTable] = DBT.[idMtDbTable] 
						       AND TI.[Index_name] COLLATE DATABASE_DEFAULT = TZ.[Index_name]

						DROP TABLE #MtDbTableIndexMalUtz
 ''
			

	BEGIN TRY
	print @LinkedServer
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
/****** Object:  Step [Table index fragmentado (insert de index fragmentado)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Table index fragmentado (insert de index fragmentado)', 
		@step_id=14, 
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
		CREATE TABLE  #MtDbTableIndexFrag(  
				[Database] sysname
			  , [Table] sysname
			  , [IndexName] sysname NULL
			  , [IndexType] VARCHAR(20)
			  , [AvgFrag] decimal(5,2)
			  , [RowCt] bigint
			  , [StatsUpdateDt] datetime) 


						INSERT INTO #MtDbTableIndexFrag
						EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_TablesIndexFrag]
						/**/
			INSERT INTO [SGBD].[MtDbTableIndexFrag]
					   ([idMtDbTableIndex]
						,[FragAvg]
						,[TotalRow]
						,[StatsUpdateDt])
						SELECT DISTINCT
						       TI.[idMtDbTableIndex]
						     , TZ.[AvgFrag]
						     , TZ.[RowCt]
							 , TZ.[StatsUpdateDt]
						FROM #MtDbTableIndexFrag TZ
 						INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''
						INNER JOIN [SGBD].[SGBDDatabases] AS D ON D.[idSGBD] = SGBD.[idSGBD] AND RTRIM(LTRIM(D.BasedeDados)) COLLATE DATABASE_DEFAULT = TZ.[Database]
						INNER JOIN [SGBD].[MtDbTable] AS DBT ON DBT.[idDatabases] = D.[idDatabases] AND RTRIM(LTRIM(DBT.[Table_name]))  COLLATE DATABASE_DEFAULT = TZ.[Table]  
					    INNER JOIN [SGBD].[MtDbTableIndex] AS TI ON TI.[idMtDbTable] = DBT.[idMtDbTable] 
						       AND TI.[Index_name] COLLATE DATABASE_DEFAULT = TZ.[IndexName]

						DROP TABLE #MtDbTableIndexFrag
 ''
			

	BEGIN TRY
	print @LinkedServer
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
/****** Object:  Step [Table Index IO ( Insert leitura e escrita do index)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Table Index IO ( Insert leitura e escrita do index)', 
		@step_id=15, 
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
		CREATE TABLE #MtDbTableIndexIO(
			[Servidor] [varchar](255) NULL,
			[base] [varchar](255) NULL,
			[schema_name] [varchar](255) NULL,
			[table_name] [varchar](255) NULL,
			[Index_name] [varchar](255) NULL,
			[IndexID] INT NULL,
			[TotalWrites] INT NULL,
			[TotalReads] INT NULL,
			[Difference] INT NULL)

						INSERT INTO #MtDbTableIndexIO
						EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_TablesIndexIO]
						/**/
			INSERT INTO [SGBD].[MtDbTableIndexIO]
					   ([idMtDbTableIndex]
						,[TotalWrites]
						,[TotalReads])
						SELECT TI.[idMtDbTableIndex]
						     , TZ.[TotalWrites]
						     , TZ.[TotalReads]
						FROM #MtDbTableIndexIO TZ
 						INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR = TZ.[Servidor]
						INNER JOIN [SGBD].[SGBDDatabases] AS D ON D.[idSGBD] = SGBD.[idSGBD] AND RTRIM(LTRIM(D.BasedeDados)) COLLATE DATABASE_DEFAULT = TZ.Base
						INNER JOIN [SGBD].[MtDbTable] AS DBT 
						        ON DBT.[idDatabases] = D.[idDatabases] 
							   AND RTRIM(LTRIM(DBT.[schema_name])) COLLATE DATABASE_DEFAULT = TZ.schema_name
							   AND RTRIM(LTRIM(DBT.[Table_name]))  COLLATE DATABASE_DEFAULT = TZ.Table_name  
					    INNER JOIN [SGBD].[MtDbTableIndex] AS TI ON TI.[idMtDbTable] = DBT.[idMtDbTable] 
						       AND TI.[Index_name] COLLATE DATABASE_DEFAULT = TZ.[Index_name]

						DROP TABLE #MtDbTableIndexIO
 ''
			

	BEGIN TRY
	print @LinkedServer
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
/****** Object:  Step [Table Index Historico ( Insert dos historicos dos index)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Table Index Historico ( Insert dos historicos dos index)', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
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
CREATE TABLE #MtDbTableIndexHist(
	[Servidor] [varchar](255) NULL,
	[base] [varchar](255) NULL,
	[schema_name] [varchar](255) NULL,
	[table_name] [varchar](255) NULL,
	[Index_name] [varchar](255) NULL,     
	[IndexSizeKB] [real] NULL,
	[NumOfSeeks] [int] NOT NULL,
	[NumOfScans] [int] NOT NULL,
	[NumOfLookups] [int] NOT NULL,
	[NumOfUpdates] [int] NOT NULL,
	[LastSeek] [datetime] NULL,
	[LastScan] [datetime] NULL,
	[LastLookup] [datetime] NULL,
	[LastUpdate] [datetime] NULL)


						INSERT INTO #MtDbTableIndexHist
						EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_TablesIndexHist] 
						/**/
			INSERT INTO [SGBD].[MtDbTableIndexHist]
					          ([idMtDbTableIndex]
							  ,[IndexSizeKB]
							  ,[NumOfSeeks]
							  ,[NumOfScans]
							  ,[NumOfLookups]
							  ,[NumOfUpdates]
							  ,[LastSeek]
							  ,[LastScan]
							  ,[LastLookup]
							  ,[LastUpdate])
						SELECT 
						       TI.[idMtDbTableIndex],
							   TZ.[IndexSizeKB],
							   TZ.[NumOfSeeks],
							   TZ.[NumOfScans],
							   TZ.[NumOfLookups],
							   TZ.[NumOfUpdates],
							   TZ.[LastSeek],
						                   TZ.[LastScan],
							   TZ.[LastLookup],
							   TZ.[LastUpdate]
						FROM #MtDbTableIndexHist TZ
 						INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''
						INNER JOIN [SGBD].[SGBDDatabases] AS D ON D.[idSGBD] = SGBD.[idSGBD] AND RTRIM(LTRIM(D.BasedeDados)) COLLATE DATABASE_DEFAULT = TZ.[base]
						INNER JOIN [SGBD].[MtDbTable] AS DBT ON DBT.[idDatabases] = D.[idDatabases] 
						       AND RTRIM(LTRIM(DBT.[schema_name]))  COLLATE DATABASE_DEFAULT = TZ.[schema_name]  
						       AND RTRIM(LTRIM(DBT.[Table_name]))  COLLATE DATABASE_DEFAULT = TZ.[table_name]  
					    INNER JOIN [SGBD].[MtDbTableIndex] AS TI ON TI.[idMtDbTable] = DBT.[idMtDbTable] 
						       AND TI.[Index_name] COLLATE DATABASE_DEFAULT = TZ.[Index_name]

						DROP TABLE #MtDbTableIndexHist
 ''
			

	BEGIN TRY
	print @LinkedServer
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
/****** Object:  Step [Login Servidor (Insert)]    Script Date: 19/03/2020 16:51:15 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Login Servidor (Insert)', 
		@step_id=17, 
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
					INSERT INTO [SGBD].[IvSQLPermissionLogin]
							   ([idSGBD]
							   ,[idDatabases]
							   ,[nameUser]
							   ,[loginname]
							   ,[isntname]
							   ,[sysadmin]
							   ,[securityadmin]
							   ,[serveradmin]
							   ,[setupadmin]
							   ,[processadmin]
							   ,[diskadmin]
							   ,[dbcreator]
							   ,[bulkadmin])
								SELECT  SGBD.idSGBD
									   ,D.[idDatabases]
									   ,L.name     
									   ,L.loginname
									   ,L.isntname 
									   ,L.sysadmin
									   ,L.securityadmin
									   ,L.serveradmin
									   ,L.setupadmin
									   ,L.processadmin
									   ,L.diskadmin
									   ,L.dbcreator
									   ,L.bulkadmin
								from ''+ RTRIM(@LinkedServer) + ''.[master].[sys].syslogins AS L
								inner join [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''  
								inner join [SGBD].[SGBDDatabasesProd] AS D on D.Basededados COLLATE DATABASE_DEFAULT = L.dbname COLLATE DATABASE_DEFAULT
								/**/where NOT EXISTS(select * 
													  from [SGBD].[IvSQLPermissionLogin] AS LG
													   where LG.[idSGBD] = SGBD.[idSGBD] 
														and LG.[idDatabases] = D.[idDatabases]
														 and LG.[nameUser] COLLATE DATABASE_DEFAULT= L.name
														  and LG.[loginname] COLLATE DATABASE_DEFAULT= L.[loginname]) ''
			

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
/****** Object:  Step [Login Servidor (Update)]    Script Date: 19/03/2020 16:51:16 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Login Servidor (Update)', 
		@step_id=18, 
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
	
						UPDATE LG 
						SET LG.[Ativo] = 0 
					  FROM [SGBD].[IvSQLPermissionLogin] AS LG
					  INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''
					  inner join [SGBD].[SGBDDatabasesProd] AS D on  D.[idDatabases] = LG.[idDatabases]
					  WHERE NOT EXISTS(SELECT * 
										FROM ''+ RTRIM(@LinkedServer) + ''.[master].[sys].syslogins  L
										 WHERE L.[name] COLLATE DATABASE_DEFAULT = LG.[nameUser]
										   AND L.dbname COLLATE DATABASE_DEFAULT = D.Basededados) 
					  	 
					  AND LG.[Ativo] <> 0''

					                     
			

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
/****** Object:  Step [Login Servidor (Update status)]    Script Date: 19/03/2020 16:51:16 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Login Servidor (Update status)', 
		@step_id=19, 
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
						 UPDATE LG SET
							   LG.[isntname]      = L.[isntname]
							  ,LG.[sysadmin]      = L.[sysadmin]
							  ,LG.[securityadmin] = L.[securityadmin]
							  ,LG.[serveradmin]   = L.[serveradmin] 
							  ,LG.[setupadmin]    = L.[setupadmin]
							  ,LG.[processadmin]  = L.[processadmin]
							  ,LG.[diskadmin]     = L.[diskadmin]
							  ,LG.[dbcreator]     = L.[dbcreator]
							  ,LG.[bulkadmin]     = L.[bulkadmin]
						  FROM [SGBD].[IvSQLPermissionLogin] AS LG
						  INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''
						  inner join [SGBD].[SGBDDatabasesProd] AS D on  D.[idDatabases] = LG.[idDatabases]
						  inner join ''+ RTRIM(@LinkedServer) + ''.[master].[sys].syslogins AS L ON L.[name] COLLATE DATABASE_DEFAULT = LG.[nameUser]
								 AND L.dbname COLLATE DATABASE_DEFAULT = D.Basededados
								 AND(L.sysadmin <> LG.[sysadmin]
									OR 
									L.[securityadmin] <> LG.[securityadmin]
									OR 
									  L.[serveradmin] <> LG.[serveradmin]
									OR 
									  L.[setupadmin] <> LG.[setupadmin]
									OR 
									  L.[processadmin] <> LG.[processadmin]
									OR 
									  L.[diskadmin] <> LG.[diskadmin]
									OR 
									  L.[dbcreator] <> LG.[dbcreator]
									OR 
									  L.[bulkadmin] <> LG.[bulkadmin]) 
									 
								AND LG.[Ativo] = 1''
				                     
			

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
/****** Object:  Step [Permissões nivel da database (Insert)]    Script Date: 19/03/2020 16:51:16 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Permissões nivel da database (Insert)', 
		@step_id=20, 
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
	
					CREATE TABLE #TPPermissionDB
						   ( Servidor         varchar(100)
							,Base             varchar(100)
							,DbRole           varchar(100)
							,MemberName       varchar(100))


						INSERT INTO #TPPermissionDB
						EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_PermissionDB]

						INSERT INTO [SGBD].[IvSQLPermissionDb]
								   ([idSGBD]
								   ,[idDatabases]
								   ,[idIvSQLPermissionLogin]
								   ,[DbRole]
								   ,[MemberName])
								SELECT 			  
									  SGBD.[idSGBD]
									, D.idDatabases
									, L.[idIvSQLPermissionLogin]
									, DbRole
									, MemberName    
								 FROM #TPPermissionDB DF
 								 INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+'''''' 
								 INNER JOIN [SGBD].[SGBDDatabases] AS D ON D.[idSGBD] = SGBD.[idSGBD] AND  RTRIM(LTRIM(D.BasedeDados)) COLLATE DATABASE_DEFAULT = DF.Base
  								 INNER JOIN [SGBD].[IvSQLPermissionLogin] AS L ON L.[idSGBD] = SGBD.[idSGBD] 
  								              AND L.[loginname] = DF.MemberName
  									WHERE NOT EXISTS(SELECT * 
 											      FROM [SGBD].[IvSQLPermissionDb] EL
  											        WHERE EL.[idIvSQLPermissionLogin] = L.[idIvSQLPermissionLogin])

						DROP TABLE #TPPermissionDB
 ''
			

	BEGIN TRY
	print @LinkedServer
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
/****** Object:  Step [HD]    Script Date: 19/03/2020 16:51:16 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'HD', 
		@step_id=21, 
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

						CREATE TABLE #TPdisk
								   ( Servidor  char(30) null
								   , drive     char(1) null
								   , FreeSpace int null
								   , TotalSize int null
								   , Livre     int null)
										   
							 INSERT INTO #TPdisk
								EXEC ''+ RTRIM(@LinkedServer) + ''.[master].[dbo].[SP_Disk] 

									INSERT INTO [SGBD].[MtSQLDisk]
											   ([idSGBD]
											   ,[drive]
											   ,[FreeSpace]
											   ,[TotalSize]
											   ,[Livre])
										  SELECT SGBD.[idSGBD]
											   , drive     
											   , FreeSpace 
											   , TotalSize 
											   , Livre     
										  FROM #TPdisk 
										  INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''
										
						DROP TABLE #TPdisk	
									
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
/****** Object:  Step [Database (Backups executados)]    Script Date: 19/03/2020 16:51:16 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database (Backups executados)', 
		@step_id=22, 
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
						INSERT INTO [SGBD].[MtSQLDbBackup]
								   ([idDatabases]
								   ,[user_name]
								   ,[physical_device_name]
								   ,[backup_size]
								   ,[BackupType]
								   ,[collation_name]
								   ,[server_name]
								   ,[backup_start_date])
								 SELECT 
										D.idDatabases
									  , BK.user_name
									  , BKM.physical_device_name
									  , CAST(BK.backup_size / 1000000 AS REAL) AS ''''backup_size''''
									  , CASE BK.[type]
											WHEN ''''D'''' THEN ''''Full''''
											WHEN ''''I'''' THEN ''''Differential''''
											WHEN ''''L'''' THEN ''''Transaction Log''''
										END AS BackupType
									  , BK.collation_name
									  , BK.server_name
									  , BK.backup_start_date  
								FROM [''+ RTRIM(@LinkedServer) + ''].msdb.dbo.backupset BK
								INNER JOIN [''+ RTRIM(@LinkedServer) + ''].msdb.dbo.backupmediafamily BKM ON BK.media_set_id = BKM.media_set_id
								INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+'''''' 
								INNER JOIN [SGBD].[SGBDDatabasesProd] AS D ON D.BasedeDados COLLATE DATABASE_DEFAULT = BK.database_name
								WHERE BK.backup_start_date >= ''''2018-01-01 00:00:00'''' AND
									  NOT EXISTS( SELECT *
												  FROM [SGBD].[MtSQLDbBackup] AS D1
												  WHERE D1.idDatabases  = D.idDatabases
													AND D1.user_name COLLATE DATABASE_DEFAULT = BK.user_name COLLATE DATABASE_DEFAULT
													AND D1.physical_device_name COLLATE DATABASE_DEFAULT = BKM.physical_device_name COLLATE DATABASE_DEFAULT
													AND D1.backup_start_date    = BK.backup_start_date)	
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
/****** Object:  Step [Database [Panel de Backup]]    Script Date: 19/03/2020 16:51:16 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database [Panel de Backup]', 
		@step_id=23, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF OBJECT_ID(''[SGBD].[BackupsMsMonitorMes]'', ''U'') IS NOT NULL 
	DROP TABLE [SGBD].[BackupsMsMonitorMes]

SELECT AA.idDatabases
     , AA.Servidor
     , AA.BasedeDados
	 , AA.[DataExecucao]
	 , MAX(AA.[backup_size]) AS ''Tamanho''
	  , CASE 
	      WHEN CONVERT(datetime, RIGHT(AA.[DataExecucao],4)+RIGHT(LEFT(AA.[DataExecucao],5),2)+LEFT(AA.[DataExecucao],2), 126)
		         < 
			   CONVERT(datetime, CONVERT(Nchar(10),GETDATE(),112), 126) 
			   AND MAX(AA.[backup_size]) IS NULL 
--			   AND [Rotineira].[F_BackupWindows] (AA.idSGBD,CONVERT(datetime, RIGHT(AA.[DataExecucao],4)+RIGHT(LEFT(AA.[DataExecucao],5),2)+LEFT(AA.[DataExecucao],2), 126)) = 1
		  THEN 1 --- FALHOU ERRO 		  
		  WHEN CONVERT(datetime, RIGHT(AA.[DataExecucao],4)+RIGHT(LEFT(AA.[DataExecucao],5),2)+LEFT(AA.[DataExecucao],2), 126)
		         > 
			   CONVERT(datetime, CONVERT(Nchar(10),GETDATE(),112), 126) 
			   AND MAX(AA.[backup_size]) IS NULL 
		  THEN 4 --- NÃO EXECUTOU
	      WHEN CONVERT(datetime, RIGHT(AA.[DataExecucao],4)+RIGHT(LEFT(AA.[DataExecucao],5),2)+LEFT(AA.[DataExecucao],2), 126)
		         <= 
			   CONVERT(datetime, CONVERT(Nchar(10),GETDATE(),112), 126) 
			   AND MAX(AA.[backup_size]) IS NULL 
			   --AND [Rotineira].[F_BackupWindows] (A.idSGBD,CONVERT(datetime, RIGHT(A.[DataExecucao],4)+RIGHT(LEFT(A.[DataExecucao],5),2)+LEFT(A.[DataExecucao],2), 126)) = 0
		  THEN 4 --- NÃO EXECUTOU
	     ELSE 3 --- EXECUTADO COM SUCESSO 
	      END AS [BACKUP] 
INTO [SGBD].[BackupsMsMonitorMes]
FROM ( SELECT DISTINCT
               B.idDatabases
			 , B.Servidor
			 , B.BasedeDados
			 , A.[DataExecucao]
			 , C.[backup_size]
		FROM [dbo].[F_RetornoDiaMesAtual]() AS A
		RIGHT JOIN [SGBD].[SGBDDatabasesProd]     AS B ON B.[dbid]  > 4
		LEFT  JOIN [SGBD].[MtSQLDbBackup]         AS C ON C.idDatabases = B.idDatabases ) AS AA 
WHERE AA.Servidor NOT LIKE ''%MySQL%'' 
  AND AA.Servidor NOT LIKE ''%Postgre%''
  AND AA.[DataExecucao] IS NOT NULL
GROUP BY AA.idDatabases, AA.Servidor, AA.BasedeDados, AA.[DataExecucao]
ORDER BY AA.Servidor, AA.BasedeDados, AA.[DataExecucao]', 
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database [Panel de backup (quadro)]]    Script Date: 19/03/2020 16:51:16 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database [Panel de backup (quadro)]', 
		@step_id=24, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[SP_PrcBackupMsQuadroDetalhado]
EXEC [dbo].[SP_AtlBackupMsQuadroDetalhado]', 
		@database_name=N'MonitorGW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Execução diária', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180522, 
		@active_end_date=99991231, 
		@active_start_time=230000, 
		@active_end_time=235959, 
		@schedule_uid=N'a0ae20b6-7ce2-4597-8a3f-115842d3c30e'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


