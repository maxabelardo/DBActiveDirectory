DECLARE @LinkedServer nchar(50)
DECLARE @LinkedEstancia nchar(50)
DECLARE @Database nchar(50)
DECLARE @ExeScript nchar(3000)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like 'LNK_SQL_%' --AND a.product LIKE '%prd%'
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	DECLARE db_for2 CURSOR FOR

		SELECT B.BasedeDados
		 FROM [SGBD].[SGBDServidorProd] AS A
		  INNER JOIN [SGBD].[SGBDDatabasesProd] AS B ON B.idSGBD = A.idSGBD
		   WHERE A.[Servidor] = @LinkedEstancia -- AND B.BasedeDados = 'GEACupax'

	OPEN db_for2 
	FETCH NEXT FROM db_for2 INTO @Database

		WHILE @@FETCH_STATUS = 0
		BEGIN

				SET @ExeScript = '	
					CREATE TABLE  #MtDbTableIndexFrag(  
							[Database] sysname
						  , [Table] sysname
						  , [IndexName] sysname NULL
						  , [IndexType] VARCHAR(20)
						  , [AvgFrag] decimal(5,2)
						  , [RowCt] bigint
						  , [StatsUpdateDt] datetime) 


									INSERT INTO #MtDbTableIndexFrag
									EXEC '+ RTRIM(@LinkedServer) + '.[master].[dbo].[SP_TablesIndexFragR] '''+RTRIM(@Database) +'''
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
 									INNER JOIN [SGBD].[SGBDServidorProd] AS SGBD ON SGBD.SERVIDOR LIKE '''+ RTRIM(@LinkedEstancia)+'''
									INNER JOIN [SGBD].[SGBDDatabases] AS D ON D.[idSGBD] = SGBD.[idSGBD] AND RTRIM(LTRIM(D.BasedeDados)) COLLATE DATABASE_DEFAULT = TZ.[Database]
									INNER JOIN [SGBD].[MtDbTable] AS DBT ON DBT.[idDatabases] = D.[idDatabases] AND RTRIM(LTRIM(DBT.[Table_name]))  COLLATE DATABASE_DEFAULT = TZ.[Table]  
									INNER JOIN [SGBD].[MtDbTableIndex] AS TI ON TI.[idMtDbTable] = DBT.[idMtDbTable] 
										   AND TI.[Index_name] COLLATE DATABASE_DEFAULT = TZ.[IndexName]

									DROP TABLE #MtDbTableIndexFrag
			 '
			

				BEGIN TRY
				print @LinkedServer
					exec sp_executesql @ExeScript
				END TRY	
				BEGIN CATCH
					PRINT 'Este insert foi ignorado!';
				END CATCH	
/*			
				print @ExeScript
*/				
			

			
				FETCH NEXT FROM db_for2 INTO @Database
				END

				CLOSE db_for2
				DEALLOCATE db_for2

	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia
END

CLOSE db_for
DEALLOCATE db_for

