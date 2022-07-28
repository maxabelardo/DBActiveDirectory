USE [master]
GO

/****** Object:  StoredProcedure [dbo].[SP_TablesIndex]    Script Date: 19/03/2020 16:56:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









-- =============================================
-- Author:		José Abelardo 
-- Create date: 11/03/2020
-- Description:	SP de documentação
-- =============================================
/**/
CREATE PROCEDURE [dbo].[SP_TablesIndex]
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
		CREATE TABLE #MtDbTableIndex(
			[Servidor] [varchar](255) NULL,
			[base] [varchar](255) NULL,
			[schema_name] [varchar](255) NULL,
			[table_name] [varchar](255) NULL,
			[Index_name] [varchar](255) NULL,
			[FileGroup]  [varchar](255) NULL,
			[type_desc] [varchar](255) NULL)

			declare @SqlCommand nvarchar(4000)

	set @SqlCommand = 'USE ['+ '?'  +']' 
				+'  '+
				'insert into #MtDbTableIndex
							([Servidor],
							 [base],
							 [schema_name],
		  					 [table_name],
							 [Index_name],
							 [FileGroup],
							 [type_desc] )
				SELECT @@SERVERNAME AS [Servidor]
				     ,''' + '?' + ''' as base
					 , s.name       AS [schema_name]
					 , tn.[name]    AS [Table_name]
					 , ix.[name]    AS [Index_name]
					 , d.[name]       AS [FileGroup]
					 , ix.type_desc
				FROM sys.dm_db_partition_stats AS sz
				INNER JOIN sys.indexes AS ix ON sz.[object_id] = ix.[object_id] AND sz.[index_id] = ix.[index_id]
				INNER JOIN sys.tables tn ON tn.OBJECT_ID = ix.object_id
				INNER JOIN sys.schemas s on s.schema_id = tn.schema_id
				INNER JOIN sys.data_spaces d on d.data_space_id = ix.data_space_id
				WHERE ix.[name] IS NOT NULL

	'				
				--PRINT @SqlCommand					
				EXEC sp_MSforeachdb @SqlCommand		

SELECT * 
FROM #MtDbTableIndex 
WHERE base <> 'master'
  AND base <> 'msdb'
  AND base <> 'model'
  AND base <> 'tempdb'				   
                       
DROP TABLE #MtDbTableIndex 
/**/
END





GO


