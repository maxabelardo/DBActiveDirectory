USE [master]
GO

/****** Object:  StoredProcedure [dbo].[SP_TablesIndexHist ]    Script Date: 19/03/2020 16:56:38 ******/
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
CREATE PROCEDURE [dbo].[SP_TablesIndexHist ]
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

	declare @SqlCommand nvarchar(4000)


	set @SqlCommand = 'USE ['+ '?'  +']' 
				+'  '+
				'INSERT INTO #MtDbTableIndexHist
						   ([Servidor],
							[base],
							[schema_name],
							[table_name],
							[Index_name],     
							[IndexSizeKB],
							[NumOfSeeks],
							[NumOfScans],
							[NumOfLookups],
							[NumOfUpdates],
							[LastSeek],
							[LastScan],
							[LastLookup],
							[LastUpdate])
					SELECT  
							@@SERVERNAME
						   ,''' + '?' + ''' as base
						   ,s.name as schema_name
						   ,tn.name    AS Table_name
						   ,IX.name AS Index_Name
						   ,SUM(PS.[used_page_count]) * 8 IndexSizeKB
						   ,SUM(IXUS.user_seeks) AS NumOfSeeks
						   ,SUM(IXUS.user_scans) AS NumOfScans
						   ,SUM(IXUS.user_lookups) AS NumOfLookups
						   ,SUM(IXUS.user_updates) AS NumOfUpdates
						   ,MAX(IXUS.last_user_seek) AS LastSeek
						   ,MAX(IXUS.last_user_scan) AS LastScan
						   ,MAX(IXUS.last_user_lookup) AS LastLookup
						   ,MAX(IXUS.last_user_update) AS LastUpdate
					FROM sys.indexes IX
					INNER JOIN sys.dm_db_index_usage_stats IXUS ON IXUS.index_id = IX.index_id AND IXUS.OBJECT_ID = IX.OBJECT_ID
					INNER JOIN sys.dm_db_partition_stats PS on PS.object_id=IX.object_id
					INNER JOIN sys.tables tn ON tn.OBJECT_ID = IX.object_id
					INNER JOIN sys.schemas s on s.schema_id = tn.schema_id
					WHERE OBJECTPROPERTY(IX.OBJECT_ID,''IsUserTable'') = 1
					GROUP BY s.name, tn.name, IX.name  '			

--PRINT @SqlCommand					
EXEC sp_MSforeachdb @SqlCommand		

		SELECT * 
		FROM #MtDbTableIndexHist 
		WHERE base <> 'master'
		  AND base <> 'msdb'
		  AND base <> 'model'
		  AND base <> 'tempdb'				   
                       
DROP TABLE #MtDbTableIndexHist 

END




GO


