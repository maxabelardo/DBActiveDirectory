USE [inventario]
GO

DECLARE @idSGBD		   INT
DECLARE @Servidor      nvarchar(50)
DECLARE @BasedeDados   nvarchar(50)
DECLARE @IP			   nvarchar(50)
DECLARE @LinkdName     nvarchar(50)
DECLARE @ExeScript     nvarchar(4000)
DECLARE @lError        SMALLINT



DECLARE lnk CURSOR FOR

	SELECT [idSGBD], Servidor, [IP]
		FROM [SGBD].[SGBDEst]
			WHERE [SGBD] = 'PostgreSQL' 
			--AND Servidor LIKE 'PENTAHO_PDI%'

OPEN lnk 
		FETCH NEXT FROM lnk INTO @idSGBD, @Servidor, @IP
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			DECLARE db CURSOR FOR

				SELECT BasedeDados
				 FROM [SGBD].[SGBDEstDB]
				   WHERE [idSGBD] = @idSGBD 

			OPEN db 
			FETCH NEXT FROM db INTO @BasedeDados

				WHILE @@FETCH_STATUS = 0
				BEGIN

				    SET @LinkdName = '_'+ RTRIM(REPLACE(@Servidor,'\POSTGRESQL','')) +'_'+ RTRIM(@BasedeDados)

					SET @ExeScript = 'EXEC master.dbo.sp_addlinkedserver @server = N''LinkedServerJob'+@LinkdName+''', @srvproduct=N'''+RTRIM(@Servidor)+''', @provider=N''MSDASQL'', @provstr=N''Driver=PostgreSQL Unicode(x64);uid=usrsm;Server='+RTRIM(@IP)+';database='+ RTRIM(@BasedeDados)+';pwd=Z34azI8ChLpmLIy3''
'
									 +'EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N''LinkedServerJob'+@LinkdName+''',@useself=N''False'',@locallogin=NULL,@rmtuser=N''usrsm'',@rmtpassword=''Z34azI8ChLpmLIy3'' 
'
									 +'EXEC master.dbo.sp_serveroption @server=N''LinkedServerJob'+@LinkdName+''', @optname=N''collation compatible'', @optvalue=N''false'' 
'
									 +'EXEC master.dbo.sp_serveroption @server=N''LinkedServerJob'+@LinkdName+''', @optname=N''data access'', @optvalue=N''true'' 
'
									 +'EXEC master.dbo.sp_serveroption @server=N''LinkedServerJob'+@LinkdName+''', @optname=N''dist'', @optvalue=N''false'' 
'
									 +'EXEC master.dbo.sp_serveroption @server=N''LinkedServerJob'+@LinkdName+''', @optname=N''pub'', @optvalue=N''false'' 
'
									 +'EXEC master.dbo.sp_serveroption @server=N''LinkedServerJob'+@LinkdName+''', @optname=N''rpc'', @optvalue=N''true'' 
'
									 +'EXEC master.dbo.sp_serveroption @server=N''LinkedServerJob'+@LinkdName+''', @optname=N''rpc out'', @optvalue=N''true'' 
'
									 +'EXEC master.dbo.sp_serveroption @server=N''LinkedServerJob'+@LinkdName+''', @optname=N''sub'', @optvalue=N''false'' 
'
									 +'EXEC master.dbo.sp_serveroption @server=N''LinkedServerJob'+@LinkdName+''', @optname=N''connect timeout'', @optvalue=N''0'' 
'
									 +'EXEC master.dbo.sp_serveroption @server=N''LinkedServerJob'+@LinkdName+''', @optname=N''collation name'', @optvalue=null 
'
									 +'EXEC master.dbo.sp_serveroption @server=N''LinkedServerJob'+@LinkdName+''', @optname=N''lazy schema validation'', @optvalue=N''false'' 
'
									 +'EXEC master.dbo.sp_serveroption @server=N''LinkedServerJob'+@LinkdName+''', @optname=N''query timeout'', @optvalue=N''0'' 
'
									 +'EXEC master.dbo.sp_serveroption @server=N''LinkedServerJob'+@LinkdName+''', @optname=N''use remote collation'', @optvalue=N''true'' 
'
									 +'EXEC master.dbo.sp_serveroption @server=N''LinkedServerJob'+@LinkdName+''', @optname=N''remote proc transaction promotion'', @optvalue=N''true'' '

					     
						BEGIN TRY
						   --PRINT @ExeScript
							exec sp_executesql @ExeScript
							WAITFOR DELAY '00:00:05'
						END TRY	
						BEGIN CATCH
							PRINT 'Criação do LinkedServer apresentou erro: ' +RTRIM(@Servidor) ;
							
						END CATCH	
					
						--PRINT @ExeScript				
					

						--IF OBJECT_ID(N'@LinkdName')), N'U')   IS NOT NULL
						--BEGIN
							SET @ExeScript = '
UPDATE TB SET
       TB.[reservedkb] = CASE 
							WHEN LEFT(A.table_size, 1) = 0 THEN 0
							WHEN LEFT(A.table_size, 1) > 0 
								AND LEFT(RTRIM(RIGHT(A.table_size,(LEN(A.table_size)-CHARINDEX('' '', A.table_size)))),1) =''b'' THEN CAST(LTRIM(LEFT(A.table_size,CHARINDEX('' '', A.table_size))) AS INT) / 1024
							WHEN LEFT(A.table_size, 1) > 0 
								AND LEFT(RTRIM(RIGHT(A.table_size,(LEN(A.table_size)-CHARINDEX('' '', A.table_size)))),1) =''K'' THEN CAST(LTRIM(LEFT(A.table_size,CHARINDEX('' '', A.table_size))) AS INT)
							WHEN LEFT(A.table_size, 1) > 0 
								AND LEFT(RTRIM(RIGHT(A.table_size,(LEN(A.table_size)-CHARINDEX('' '', A.table_size)))),1) =''M'' THEN CAST(LTRIM(LEFT(A.table_size,CHARINDEX('' '', A.table_size))) AS INT) * 1024
							WHEN LEFT(A.table_size, 1) > 0 
								AND LEFT(RTRIM(RIGHT(A.table_size,(LEN(A.table_size)-CHARINDEX('' '', A.table_size)))),1) =''G'' THEN CAST(LTRIM(LEFT(A.table_size,CHARINDEX('' '', A.table_size))) AS INT) * 1024 * 1024
							END
      ,TB.[datakb]     = CASE 
							WHEN LEFT(A.table_size, 1) = 0 THEN 0
							WHEN LEFT(A.table_size, 1) > 0 
								AND LEFT(RTRIM(RIGHT(A.table_size,(LEN(A.table_size)-CHARINDEX('' '', A.table_size)))),1) =''b'' THEN CAST(LTRIM(LEFT(A.table_size,CHARINDEX('' '', A.table_size))) AS INT) / 1024
							WHEN LEFT(A.table_size, 1) > 0 
								AND LEFT(RTRIM(RIGHT(A.table_size,(LEN(A.table_size)-CHARINDEX('' '', A.table_size)))),1) =''K'' THEN CAST(LTRIM(LEFT(A.table_size,CHARINDEX('' '', A.table_size))) AS INT)
							WHEN LEFT(A.table_size, 1) > 0 
								AND LEFT(RTRIM(RIGHT(A.table_size,(LEN(A.table_size)-CHARINDEX('' '', A.table_size)))),1) =''M'' THEN CAST(LTRIM(LEFT(A.table_size,CHARINDEX('' '', A.table_size))) AS INT) * 1024
							WHEN LEFT(A.table_size, 1) > 0 
								AND LEFT(RTRIM(RIGHT(A.table_size,(LEN(A.table_size)-CHARINDEX('' '', A.table_size)))),1) =''G'' THEN CAST(LTRIM(LEFT(A.table_size,CHARINDEX('' '', A.table_size))) AS INT) * 1024 * 1024
							END
      ,TB.[sumline]    = A.table_row
      ,TB.[dataupdate] = GETDATE()
FROM [SGBD].[SGBDTable] TB
INNER JOIN [SGBD].[SGBDEstDB] AS D ON D.[idSGBD] = '+ RTRIM(@idSGBD)+' AND D.[BasedeDados] LIKE '''+ RTRIM(@BasedeDados) + '''
INNER JOIN OPENQUERY(LinkedServerJob'+@LinkdName+', '' select table_catalog
									, table_schema
									, table_name
									, pg_size_pretty(pg_relation_size(''''"''''||table_schema||''''"."''''||table_name||''''"'''')) as "table_size"
									, cl.reltuples as "table_row"
							from information_schema.tables AS TB
							inner join pg_class as cl on relname = TB.table_name
							where table_schema <> ''''pg_catalog''''
								and table_schema <> ''''information_schema''''
								and table_type = ''''BASE TABLE'''' '' ) AS A ON A.table_schema COLLATE Latin1_General_CI_AS = TB.schema_name AND A.Table_Name COLLATE Latin1_General_CI_AS = TB.table_name
WHERE TB.[idDatabases]  = D.[idDatabases] 
  AND TB.[schema_name] COLLATE Latin1_General_CI_AS = A.table_schema	
  AND TB.[table_name]  COLLATE Latin1_General_CI_AS = A.Table_Name  '

	
						
							BEGIN TRY
								exec sp_executesql @ExeScript
							END TRY	
							BEGIN CATCH
								PRINT 'Extração apresentou errro, Servidor ' +RTRIM(@Servidor) + ' Base de dados: '+RTRIM(@BasedeDados);
							END CATCH
			
						---PRINT @ExeScript

						SET @ExeScript ='EXEC master.dbo.sp_dropserver @server=N''LinkedServerJob' +@LinkdName+''', @droplogins=''droplogins'' '
						
						exec sp_executesql @ExeScript
						WAITFOR DELAY '00:00:05'
						--PRINT @ExeScript

				FETCH NEXT FROM db INTO @BasedeDados
				END



				CLOSE db
				DEALLOCATE db

		FETCH NEXT FROM lnk INTO @idSGBD, @Servidor, @IP
		END

CLOSE lnk
DEALLOCATE lnk