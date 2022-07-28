USE [msdb]
GO

/****** Object:  Job [MSSQL - Documentação dos Servidores]    Script Date: 10/11/2021 18:37:09 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/11/2021 18:37:09 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'MSSQL - Documentação dos Servidores', 
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
/****** Object:  Step [Linked Server validação]    Script Date: 10/11/2021 18:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Linked Server validação', 
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
	  WHERE [SGBD] LIKE ''MSSQLServer%'' 
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
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database (Inserir novas bases)]    Script Date: 10/11/2021 18:37:10 ******/
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
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database (desativar bases que foram deletadas)]    Script Date: 10/11/2021 18:37:10 ******/
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
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database (atualização dos dados)]    Script Date: 10/11/2021 18:37:10 ******/
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
							  FROM [SGBD].[SGBDEstDB] AS VM
							  INNER JOIN [''+ RTRIM(@LinkedServer) + ''].[master].[sys].[databases] AS LK ON LK.[name] COLLATE DATABASE_DEFAULT = VM.[BasedeDados]  
							WHERE VM.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia) + ''''''
							  AND VM.[ativo] <> 0	''
					                     
			

	BEGIN TRY
		exec sp_executesql @ExeScript
	END TRY	
	BEGIN CATCH
		PRINT ''A atualiza��o apresentou erro no servidor '' + @LinkedEstancia;
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
/****** Object:  Step [Database Size (Insert size)]    Script Date: 10/11/2021 18:37:10 ******/
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
								   ([idSGBD]
								   ,[idDatabases]
								   ,[db_size])
						SELECT SGBD.[idSGBD]
							  ,D.idDatabases
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
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Table (Inserir novas tabelas)]    Script Date: 10/11/2021 18:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Table (Inserir novas tabelas)', 
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
DECLARE @idDatabases INT
DECLARE @idSGBD INT
DECLARE @BasedeDados nchar(255)
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

	DECLARE db_forA CURSOR FOR

		SELECT idDatabases, idSGBD, BasedeDados
		 FROM [SGBD].[SGBDEstDB]
		  WHERE [dbid] > 4
		    AND Servidor = @LinkedEstancia
			AND [OnlineOffline] = ''ONLINE''
	     ORDER BY Servidor, BasedeDados

	OPEN db_forA
		FETCH NEXT FROM db_forA INTO @idDatabases, @idSGBD, @BasedeDados

			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				SET @ExeScript = ''
if object_id(''''Tempdb..#tabelas'''') is not null drop table #tabelas

	;with table_space_usage (schema_name,table_Name,index_Name,used,reserved,ind_rows,tbl_rows,type_Desc,table_type)
	AS(select s.name, o.name,coalesce(i.name,''''heap''''),p.used_page_Count*8,p.reserved_page_count*8, p.row_count,
	case when i.index_id in (0,1) then p.row_count else 0 end, i.type_Desc,o.type_desc AS table_type
	from ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@BasedeDados) + ''.sys.dm_db_partition_stats p
	join ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@BasedeDados) + ''.sys.objects o on o.object_id = p.object_id
	join ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@BasedeDados) + ''.sys.schemas s on s.schema_id = o.schema_id
	left join ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@BasedeDados) + ''.sys.indexes i on i.object_id = p.object_id and i.index_id = p.index_id
	where o.type_desc = ''''user_Table'''' and o.is_Ms_shipped = 0)
	SELECT t.schema_name
			, t.table_Name
			, t.table_type
			, t.index_name
			, type_Desc
			, sum(t.used) as used_in_kb
			, sum(t.reserved) as reserved_in_kb
			, case grouping (t.index_name) 
			when 0 then sum(t.ind_rows) 
			else sum(t.tbl_rows) 
			end as rows
	into #tabelas
	FROM table_space_usage t
	group by t.schema_name
			, t.table_Name
			, t.table_type
			, t.index_Name
			, type_Desc
	with rollup
	order by grouping(t.schema_name),t.schema_name
			,grouping(t.table_Name),t.table_Name
			,grouping(t.table_type),t.table_type
			,grouping(t.index_Name),t.index_name

if object_id(''''Tempdb..#Resultado_Final'''') is not null drop table #Resultado_Final

	select Schema_Name
			, Table_Name 
			, table_type
			, sum(reserved_in_kb) [Reservado(KB)]
			, sum(case 
				when Type_Desc in (''''CLUSTERED'''',''''HEAP'''') then reserved_in_kb 
				else 0 
				end) [Dados(KB)]
			, sum(case 
					when Type_Desc in (''''NONCLUSTERED'''') then reserved_in_kb 
					else 0 
				end) [Indices(KB)]
			, max(rows) Qtd_Linhas		
	into #Resultado_Final
	from #tabelas
	where index_Name is not null
			and Type_Desc is not null
	group by Schema_Name, Table_Name ,table_type
	--having sum(reserved_in_kb) > 10000
	order by 3 desc

	INSERT INTO [SGBD].[SGBDTable]
				([idDatabases]
				,[schema_name]
				,[table_name]
				,[reservedkb]
				,[datakb]
				,[Indiceskb]
				,[sumline]
				,[dataupdate])
				SELECT D.[idDatabases]
						, R.Schema_Name
						, R.Table_Name
						, CAST(R.[Reservado(KB)] AS REAL) AS Reservado
						, CAST(R.[Dados(KB)] AS REAL) AS Dados
						, CAST(R.[Indices(KB)] AS REAL) AS Indices
						, R.Qtd_Linhas
						, GETDATE()
				FROM #Resultado_Final AS R
				INNER JOIN [SGBD].[SGBDEstDB] AS D ON D.[Servidor] LIKE ''''''+ RTRIM(@LinkedEstancia)+'''''' AND D.[BasedeDados] LIKE ''''''+ RTRIM(@BasedeDados) + ''''''
				WHERE NOT EXISTS (SELECT * FROM [SGBD].[SGBDTable] AS T WHERE T.[idDatabases]  = D.[idDatabases] 
				AND T.[schema_name] COLLATE Latin1_General_CI_AS = R.Schema_Name	
				AND T.[table_name]  COLLATE Latin1_General_CI_AS = R.Table_Name

)
				''
				
				BEGIN TRY
					exec sp_executesql @ExeScript
				END TRY	
				BEGIN CATCH
					PRINT ''Este insert foi ignorado!'';
				END CATCH

				--print @ExeScript
				FETCH NEXT FROM db_forA INTO @idDatabases, @idSGBD, @BasedeDados
			END

	CLOSE db_forA
	DEALLOCATE db_forA

	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia
END

CLOSE db_for
DEALLOCATE db_for
', 
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Table (Atualiza as estatísticas)]    Script Date: 10/11/2021 18:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Table (Atualiza as estatísticas)', 
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
DECLARE @idDatabases INT
DECLARE @idSGBD INT
DECLARE @BasedeDados nchar(255)
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

	DECLARE db_forA CURSOR FOR

		SELECT  idDatabases, idSGBD, BasedeDados
		 FROM [SGBD].[SGBDEstDB]
		  WHERE [dbid] > 4
		    AND Servidor = @LinkedEstancia
			AND [OnlineOffline] = ''ONLINE''
	     ORDER BY Servidor, BasedeDados

	OPEN db_forA
		FETCH NEXT FROM db_forA INTO @idDatabases, @idSGBD, @BasedeDados

			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				SET @ExeScript = ''
if object_id(''''Tempdb..#tabelas'''') is not null drop table #tabelas

	;with table_space_usage (schema_name,table_Name,index_Name,used,reserved,ind_rows,tbl_rows,type_Desc,table_type)
	AS(select s.name, o.name,coalesce(i.name,''''heap''''),p.used_page_Count*8,p.reserved_page_count*8, p.row_count,
	case when i.index_id in (0,1) then p.row_count else 0 end, i.type_Desc,o.type_desc AS table_type
	from ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@BasedeDados) + ''.sys.dm_db_partition_stats p
	join ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@BasedeDados) + ''.sys.objects o on o.object_id = p.object_id
	join ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@BasedeDados) + ''.sys.schemas s on s.schema_id = o.schema_id
	left join ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@BasedeDados) + ''.sys.indexes i on i.object_id = p.object_id and i.index_id = p.index_id
	where o.type_desc = ''''user_Table'''' and o.is_Ms_shipped = 0)
	SELECT t.schema_name
			, t.table_Name
			, t.table_type
			, t.index_name
			, type_Desc
			, sum(t.used) as used_in_kb
			, sum(t.reserved) as reserved_in_kb
			, case grouping (t.index_name) 
			when 0 then sum(t.ind_rows) 
			else sum(t.tbl_rows) 
			end as rows
	into #tabelas
	FROM table_space_usage t
	group by t.schema_name
			, t.table_Name
			, t.table_type
			, t.index_Name
			, type_Desc
	with rollup
	order by grouping(t.schema_name),t.schema_name
			,grouping(t.table_Name),t.table_Name
			,grouping(t.table_type),t.table_type
			,grouping(t.index_Name),t.index_name

if object_id(''''Tempdb..#Resultado_Final'''') is not null drop table #Resultado_Final

	select Schema_Name
			, Table_Name 
			, table_type
			, sum(reserved_in_kb) [Reservado(KB)]
			, sum(case 
				when Type_Desc in (''''CLUSTERED'''',''''HEAP'''') then reserved_in_kb 
				else 0 
				end) [Dados(KB)]
			, sum(case 
					when Type_Desc in (''''NONCLUSTERED'''') then reserved_in_kb 
					else 0 
				end) [Indices(KB)]
			, max(rows) Qtd_Linhas		
	into #Resultado_Final
	from #tabelas
	where index_Name is not null
			and Type_Desc is not null
	group by Schema_Name, Table_Name ,table_type
	--having sum(reserved_in_kb) > 10000
	order by 3 desc
				
UPDATE TB SET
       TB.[reservedkb] = CAST(R.[Reservado(KB)] AS REAL)
      ,TB.[datakb]     = CAST(R.[Dados(KB)] AS REAL)
      ,TB.[Indiceskb]  = CAST(R.[Indices(KB)] AS REAL)
      ,TB.[sumline]    = R.Qtd_Linhas
      ,TB.[dataupdate] = GETDATE()
FROM [SGBD].[SGBDTable] TB
INNER JOIN [SGBD].[SGBDEstDB] AS D ON D.[Servidor] LIKE ''''''+ RTRIM(@LinkedEstancia)+'''''' AND D.[BasedeDados] LIKE ''''''+ RTRIM(@BasedeDados) + ''''''
INNER JOIN #Resultado_Final AS R ON R.schema_name COLLATE Latin1_General_CI_AS = TB.schema_name AND R.table_Name COLLATE Latin1_General_CI_AS = TB.table_name
WHERE TB.[idDatabases]  = D.[idDatabases] 
  AND TB.[schema_name] COLLATE Latin1_General_CI_AS = R.Schema_Name	
  AND TB.[table_name]  COLLATE Latin1_General_CI_AS = R.Table_Name''
				
				BEGIN TRY
					exec sp_executesql @ExeScript
				END TRY	
				BEGIN CATCH
					PRINT ''Este insert foi ignorado!'';
				END CATCH
/*
				print @ExeScript
*/
				FETCH NEXT FROM db_forA INTO @idDatabases, @idSGBD, @BasedeDados
			END

	CLOSE db_forA
	DEALLOCATE db_forA

	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia
END

CLOSE db_for
DEALLOCATE db_for
', 
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Index (Inserir novos index)]    Script Date: 10/11/2021 18:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Index (Inserir novos index)', 
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
DECLARE @idDatabases INT
DECLARE @idSGBD INT
DECLARE @BasedeDados nchar(255)
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

	DECLARE db_forA CURSOR FOR

		SELECT  idDatabases, idSGBD, BasedeDados
		 FROM [SGBD].[SGBDEstDB]
		  WHERE [dbid] > 4
		    AND Servidor = @LinkedEstancia
			AND [OnlineOffline] = ''ONLINE''
	     ORDER BY Servidor, BasedeDados

	OPEN db_forA
		FETCH NEXT FROM db_forA INTO @idDatabases, @idSGBD, @BasedeDados

			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				SET @ExeScript = ''

					INSERT INTO [SGBD].[SGBDTableIndex]
							   ([idSGBDTable]
							   ,[Index_name]
							   ,[FileGroup]
							   ,[type_desc])
					SELECT DISTINCT T.idSGBDTable
						 , coalesce(I.name,''''heap'''') AS ''''Index_name''''
						 , E.[name]  AS [FileGroup]
						 , I.type_desc ''''Type_index''''
					FROM LNK_SQL_ARES.master.sys.dm_db_index_usage_stats A
					INNER JOIN ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@BasedeDados) + ''.sys.objects B on B.object_id = A.object_id
					INNER JOIN ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@BasedeDados) + ''.sys.schemas S on S.schema_id = B.schema_id
					INNER JOIN ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@BasedeDados) + ''.sys.indexes I on I.object_id = A.object_id
					INNER JOIN ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@BasedeDados) + ''.sys.data_spaces E on E.data_space_id = I.data_space_id
					INNER JOIN ''+ RTRIM(@LinkedServer) + ''.[master].[sys].[databases] AS C ON C.database_id = A.database_id
					INNER JOIN [SGBD].[SGBDEstDB] AS D ON D.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia) + '''''' AND D.BasedeDados COLLATE Latin1_General_CI_AS = C.name
					INNER JOIN [SGBD].[SGBDTable] AS T ON T.idDatabases = D.idDatabases AND T.schema_name COLLATE Latin1_General_CI_AS = s.name AND T.table_name COLLATE Latin1_General_CI_AS = B.name
					WHERE A.database_id > 4 and B.is_Ms_shipped = 0 
					  AND NOT EXISTS(SELECT * FROM [SGBD].[SGBDTableIndex] IX WHERE IX.idSGBDTable = T.idSGBDTable AND IX.[Index_name] COLLATE Latin1_General_CI_AS = coalesce(I.name,''''heap'''')  )
					
					
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
				FETCH NEXT FROM db_forA INTO @idDatabases, @idSGBD, @BasedeDados
			END

	CLOSE db_forA
	DEALLOCATE db_forA

	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia
END

CLOSE db_for
DEALLOCATE db_for
', 
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Coluna (Inserir novas colunas)]    Script Date: 10/11/2021 18:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Coluna (Inserir novas colunas)', 
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
DECLARE @idDatabases INT
DECLARE @idSGBD INT
DECLARE @BasedeDados nchar(255)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT  a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like ''LNK_SQL_%'' 
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	DECLARE db_forA CURSOR FOR

		SELECT idDatabases, idSGBD, BasedeDados
		 FROM [SGBD].[SGBDEstDB]
		  WHERE [dbid] > 4
		    AND Servidor = @LinkedEstancia
			AND [OnlineOffline] = ''ONLINE''
	     ORDER BY Servidor, BasedeDados

	OPEN db_forA
		FETCH NEXT FROM db_forA INTO @idDatabases, @idSGBD, @BasedeDados

			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				SET @ExeScript = ''
	INSERT INTO [SGBD].[SGBDTableColumn]
			   ([idSGBDTable]
			   ,[colunn_name]
			   ,[ordenal_positon]
			   ,[data_type])
				SELECT T.[idSGBDTable],	C.column_name, C.ordinal_position, C.data_type 
				FROM ''+ RTRIM(@LinkedServer) + ''.''+ RTRIM(@BasedeDados) + ''.INFORMATION_SCHEMA.COLUMNS AS C
				INNER JOIN [SGBD].[SGBDEstDB] AS D ON D.[Servidor] LIKE ''''''+ RTRIM(@LinkedEstancia)+'''''' AND D.[BasedeDados] LIKE ''''''+ RTRIM(@BasedeDados) + ''''''
				INNER JOIN [SGBD].[SGBDTable] AS T ON T.[idDatabases] = D.[idDatabases] AND T.[schema_name] COLLATE Latin1_General_CI_AS = C.table_schema AND T.[table_name] COLLATE Latin1_General_CI_AS = C.table_name
				WHERE NOT EXISTS(SELECT * FROM [SGBD].[SGBDTableColumn] AS TC WHERE TC.[idSGBDTable] = T.[idSGBDTable]
				                                                                AND TC.[colunn_name] COLLATE Latin1_General_CI_AS = C.column_name
																				)

				''
				/**/
				BEGIN TRY
					exec sp_executesql @ExeScript
				END TRY	
				BEGIN CATCH
					PRINT ''Este insert foi ignorado!'';
				END CATCH
				
				--print @ExeScript

				FETCH NEXT FROM db_forA INTO @idDatabases, @idSGBD, @BasedeDados
			END

	CLOSE db_forA
	DEALLOCATE db_forA

	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia
END

CLOSE db_for
DEALLOCATE db_for
', 
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Login Servidor (Insert)]    Script Date: 10/11/2021 18:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Login Servidor (Insert)', 
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
								inner join [SGBD].[SGBDDatabasesProd] AS D on D.[idSGBD] = SGBD.[idSGBD] 
									   and D.Basededados COLLATE DATABASE_DEFAULT = L.dbname COLLATE DATABASE_DEFAULT
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
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Login Servidor (Update)]    Script Date: 10/11/2021 18:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Login Servidor (Update)', 
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
	
						UPDATE LG 
						SET LG.[Ativo] = 0 
					  FROM [SGBD].[IvSQLPermissionLogin] AS LG
					  INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+''''''
					  inner join [SGBD].[SGBDDatabasesProd] AS D on D.[idSGBD] = SGBD.[idSGBD] AND D.[idDatabases] = LG.[idDatabases]
					  WHERE NOT EXISTS(SELECT * 
										FROM ''+ RTRIM(@LinkedServer) + ''.[master].[sys].syslogins  L
										 WHERE L.[name] COLLATE DATABASE_DEFAULT = LG.[nameUser]
										   AND L.dbname COLLATE DATABASE_DEFAULT = D.Basededados) 
					  AND LG.idSGBD = SGBD.idSGBD	 
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
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Login Servidor (Update status)]    Script Date: 10/11/2021 18:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Login Servidor (Update status)', 
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
						  inner join [SGBD].[SGBDDatabasesProd] AS D on D.[idSGBD] = SGBD.[idSGBD] AND D.[idDatabases] = LG.[idDatabases]
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
								AND LG.idSGBD = SGBD.idSGBD	 
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
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Permissões nivel da database (Insert)]    Script Date: 10/11/2021 18:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Permissões nivel da database (Insert)', 
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
								 INNER JOIN [SGBD].[SGBDDatabasesProd] AS D ON D.[idSGBD] = SGBD.[idSGBD] AND D.BasedeDados COLLATE DATABASE_DEFAULT = DF.Base
  								 INNER JOIN [SGBD].[IvSQLPermissionLogin] AS L ON L.[idSGBD] = SGBD.[idSGBD] 
  								        AND L.idDatabases = D.idDatabases
  										AND L.[loginname] = DF.MemberName
  									WHERE NOT EXISTS(SELECT * 
 											      FROM [SGBD].[IvSQLPermissionDb] EL
  											        WHERE EL.[idSGBD] = D.[idSGBD]
  											         AND EL.idDatabases = D.idDatabases
  											           AND EL.[idIvSQLPermissionLogin] = L.[idIvSQLPermissionLogin])

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
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [HD]    Script Date: 10/11/2021 18:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'HD', 
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
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database (Backups executados)]    Script Date: 10/11/2021 18:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database (Backups executados)', 
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
						INSERT INTO [SGBD].[MtSQLDbBackup]
								   ([idSGBD]
								   ,[idDatabases]
								   ,[user_name]
								   ,[physical_device_name]
								   ,[backup_size]
								   ,[BackupType]
								   ,[collation_name]
								   ,[server_name]
								   ,[backup_start_date])
								 SELECT 
										SGBD.[idSGBD]
									  , D.idDatabases
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
								INNER JOIN [''+ RTRIM(@LinkedServer) + ''].msdb.dbo.Backupmediafamily BKM ON BK.media_set_id = BKM.media_set_id
								INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR LIKE ''''''+ RTRIM(@LinkedEstancia)+'''''' 
								INNER JOIN [SGBD].[SGBDDatabasesProd] AS D ON D.[idSGBD] = SGBD.[idSGBD] AND D.BasedeDados COLLATE DATABASE_DEFAULT = BK.database_name
								WHERE BK.backup_start_date >= ''''2018-01-01 00:00:00'''' AND
									  NOT EXISTS( SELECT *
												  FROM [SGBD].[MtSQLDbBackup] AS D1
												  WHERE D1.[idSGBD]     = SGBD.[idSGBD]
													AND D1.idDatabases  = D.idDatabases
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
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database [Panel de Backup]]    Script Date: 10/11/2021 18:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database [Panel de Backup]', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF OBJECT_ID(''[Rotineira].[BackupsMsMonitorMes]'', ''U'') IS NOT NULL 
	DROP TABLE [Rotineira].[BackupsMsMonitorMes]

SELECT AA.idSGBD
     , AA.Servidor
     , AA.BasedeDados
	 , AA.[DataExecucao]
	 , MAX(AA.[backup_size]) AS ''Tamanho''
	  , CASE 
	      WHEN CONVERT(datetime, RIGHT(AA.[DataExecucao],4)+RIGHT(LEFT(AA.[DataExecucao],5),2)+LEFT(AA.[DataExecucao],2), 126)
		         < 
			   CONVERT(datetime, CONVERT(Nchar(10),GETDATE(),112), 126) 
			   AND MAX(AA.[backup_size]) IS NULL 
			   AND [Rotineira].[F_BackupWindows] (AA.idSGBD,CONVERT(datetime, RIGHT(AA.[DataExecucao],4)+RIGHT(LEFT(AA.[DataExecucao],5),2)+LEFT(AA.[DataExecucao],2), 126)) = 1
		  THEN 1 --- FALHOU ERRO 		  
		  WHEN CONVERT(datetime, RIGHT(AA.[DataExecucao],4)+RIGHT(LEFT(AA.[DataExecucao],5),2)+LEFT(AA.[DataExecucao],2), 126)
		         > 
			   CONVERT(datetime, CONVERT(Nchar(10),GETDATE(),112), 126) 
			   AND MAX(AA.[backup_size]) IS NULL 
		  THEN 4 --- N�O EXECUTOU
	      WHEN CONVERT(datetime, RIGHT(AA.[DataExecucao],4)+RIGHT(LEFT(AA.[DataExecucao],5),2)+LEFT(AA.[DataExecucao],2), 126)
		         <= 
			   CONVERT(datetime, CONVERT(Nchar(10),GETDATE(),112), 126) 
			   AND MAX(AA.[backup_size]) IS NULL 
			   --AND [Rotineira].[F_BackupWindows] (A.idSGBD,CONVERT(datetime, RIGHT(A.[DataExecucao],4)+RIGHT(LEFT(A.[DataExecucao],5),2)+LEFT(A.[DataExecucao],2), 126)) = 0
		  THEN 4 --- N�O EXECUTOU
	     ELSE 3 --- EXECUTADO COM SUCESSO 
	      END AS [BACKUP] 
INTO [Rotineira].[BackupsMsMonitorMes]
FROM ( SELECT DISTINCT
               B.idSGBD
			 , B.Servidor
			 , B.BasedeDados
			 , A.[DataExecucao]
			 , C.[backup_size]
		FROM [Rotineira].[F_RetornoDiaMesAtual]() AS A
		RIGHT JOIN [SGBD].[SGBDDatabasesProd]     AS B ON B.[dbid]  > 4
		INNER JOIN [SGBD].[MnSQLBackupJanela]     AS J ON J.idSGBD = B.idSGBD
		LEFT  JOIN [SGBD].[MtSQLDbBackup]         AS C ON C.idSGBD = B.idSGBD
		                   AND C.idDatabases = B.idDatabases 
			   AND C.[backup_start_date] BETWEEN [Rotineira].[F_BackupJanelaInicio](B.idSGBD, A.[DataExecucaoDT]) AND  [Rotineira].[F_BackupJanelaFim](B.idSGBD, A.[DataExecucaoDT])
	) AS AA 
WHERE AA.Servidor NOT LIKE ''%MySQL%'' 
  AND AA.Servidor NOT LIKE ''%Postgre%''
  AND AA.[DataExecucao] IS NOT NULL
GROUP BY AA.idSGBD, AA.Servidor, AA.BasedeDados, AA.[DataExecucao]
ORDER BY AA.Servidor, AA.BasedeDados, AA.[DataExecucao]', 
		@database_name=N'inventario', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database [Panel de backup (quadro)]]    Script Date: 10/11/2021 18:37:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database [Panel de backup (quadro)]', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [Rotineira].[SP_PrcBackupMsQuadroDetalhado]
EXEC [Rotineira].[SP_AtlBackupMsQuadroDetalhado]', 
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
		@active_start_date=20180522, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
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


