USE [master]
GO

/****** Object:  StoredProcedure [dbo].[SP_TablesIndexSize]    Script Date: 19/03/2020 16:57:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Object:  StoredProcedure [dbo].[SP_TablesIndexSize]    Script Date: 19/03/2020 11:28:08 ******/






-- =============================================
-- Author:		José Abelardo 
-- Create date: 11/03/2020
-- Description:	SP de documentação
-- =============================================
/**/
CREATE PROCEDURE [dbo].[SP_TablesIndexSize]
AS
BEGIN
/* *************************************************************************************************/
/*                     Estes script tem a finalidade de monitora todas as bases                    */
/*                            e seus resulados seram utilizados                                    */
/*                                para criação de  relatorios								       */
/***************************************************************************************************/

 ----------------------------------------------------------------------------------------------------
 ---- Descrição do Script 
 ---- Este script lista todas os index
 ----------------------------------------------------------------------------------------------------


/******* Criação das trabelas temporarias *********/

	
		/*** Tebela que vai receber as informações das index por databases ***/
		CREATE TABLE #MtDbTableIndexSize(
			[Servidor] [varchar](255) NULL,
			[base] [varchar](255) NULL,
			[schema_name] [varchar](255) NULL,
			[table_name] [varchar](255) NULL,
			[Index_name] [varchar](255) NULL,
			[type_desc] [varchar](255) NULL,
			[IndexSizeKB] [REAL] NULL,
			[row_count] INT NULL)

			declare @SqlCommand nvarchar(4000)

	set @SqlCommand = 'USE ['+ '?'  +']' 
				+'  '+
				'insert into #MtDbTableIndexSize
							([Servidor],
							 [base],
							 [schema_name],
		  					 [table_name],
							 [Index_name],
							 [type_desc],
							 [IndexSizeKB],
							 [row_count] )
				SELECT @@SERVERNAME AS [Servidor]
				     ,''' + '?' + ''' as base
					 , s.name       AS [schema_name]
					 , tn.[name]    AS [Table_name]
					 , ix.[name]    AS [Index_name]
					 , ix.type_desc
					 , SUM(sz.[used_page_count]) * 8 AS [IndexSizeKB]
					 , sz.row_count
				FROM sys.dm_db_partition_stats AS sz
				INNER JOIN sys.indexes AS ix ON sz.[object_id] = ix.[object_id] AND sz.[index_id] = ix.[index_id]
				INNER JOIN sys.tables tn ON tn.OBJECT_ID = ix.object_id
				INNER JOIN sys.schemas s on s.schema_id = tn.schema_id
				WHERE ix.[name] IS NOT NULL
				GROUP BY s.name, tn.[name], ix.[name], ix.type_desc, sz.row_count

	'				
				--PRINT @SqlCommand					
				EXEC sp_MSforeachdb @SqlCommand		

SELECT * FROM #MtDbTableIndexSize 
WHERE base <> 'master'
  AND base <> 'msdb'
  AND base <> 'model'
  AND base <> 'tempdb'				   
                       
DROP TABLE #MtDbTableIndexSize 

END






GO


