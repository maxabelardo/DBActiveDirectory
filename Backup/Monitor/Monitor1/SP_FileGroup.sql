USE [master]
GO

/****** Object:  StoredProcedure [dbo].[SP_FileGroup]    Script Date: 19/03/2020 16:54:29 ******/
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
CREATE PROCEDURE [dbo].[SP_FileGroup]
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
		CREATE TABLE #MtDbFileGroup(
			[Servidor] [varchar](255) NULL,
			[base] [varchar](255) NULL,
			[FileGroup]  [varchar](255) NULL,
			[data_space_id] INT NULL,
			[type_desc] [varchar](255) NULL)


			declare @SqlCommand nvarchar(4000)

	set @SqlCommand = 'USE ['+ '?'  +']' 
				+'  '+
				'insert into #MtDbFileGroup
							([Servidor],
							 [base],
							 [FileGroup],
							 [data_space_id],
							 [type_desc] )
				SELECT @@SERVERNAME AS [Servidor]
				     ,''' + '?' + ''' as base
					 , name as [FileGroup]
					 , data_space_id
					 , type_desc
				FROM sys.filegroups 

                insert into #MtDbFileGroup
							([Servidor],
							 [base],
							 [FileGroup],
							 [data_space_id],
							 [type_desc] )
				SELECT @@SERVERNAME AS [Servidor]
				     ,''' + '?' + ''' as base
					 , ''LOG'' as [FileGroup]
					 ,  0 AS [data_space_id]
					 , ''ROWS_FILEGROUP'' AS type_desc

	'				
				--PRINT @SqlCommand					
				EXEC sp_MSforeachdb @SqlCommand		

SELECT * 
FROM #MtDbFileGroup 
WHERE base <> 'master'
  AND base <> 'msdb'
  AND base <> 'model'
  AND base <> 'tempdb'				   
                       
DROP TABLE #MtDbFileGroup 
/**/
END





GO


