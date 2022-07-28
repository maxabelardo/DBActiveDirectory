DECLARE @LinkedServer nchar(50)
DECLARE @LinkedEstancia nchar(50)
DECLARE @ExeScript nchar(3000)
DECLARE @lError SMALLINT

DECLARE db_for CURSOR FOR

	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like 'LNK_SQL_%' 
						ORDER BY a.name

OPEN db_for 
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @ExeScript = '	
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
						EXEC '+ RTRIM(@LinkedServer) + '.[master].[dbo].[SP_TablesIndexSize]
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
	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia
END

CLOSE db_for
DEALLOCATE db_for

