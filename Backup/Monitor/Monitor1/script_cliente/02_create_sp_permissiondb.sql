USE [master]
GO

/****** Object:  StoredProcedure [dbo].[SP_PermissionDB]    Script Date: 09/03/2020 10:15:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Jos� Abelardo 
-- Create date: 01/03/2013
-- Description:	SP de documenta��o
-- =============================================

CREATE PROCEDURE [dbo].[SP_PermissionDB]
AS
BEGIN
/* *************************************************************************************************/
/*                     Estes script tem a finalidade de monitora todas as bases                    */
/*                            e seus resulados seram utilizados                                    */
/*                                para cria��o de  relatorios								       */
/***************************************************************************************************/

 ----------------------------------------------------------------------------------------------------
 ---- Descri��o do Script 
 ---- Este script lista todas os usu�rios com acesso direto ao Database e suas permiss�es.
 ----		1� Listas os usu�rios das Databases
 ----		2� Listas o nivel de acesso de cada usu�rio
 ----		3� Verifica se o usu�rio existe no servidor se n�o adiciona
 ----		4� Verifica se o usu�rio que esta no servidor foi retirado da Database, se sim ele e desativado
 ----		5� Verifica se o usu�rio que foi desativa voltou a ser ativo e atualzia o mesmo. 
 ----------------------------------------------------------------------------------------------------


/******* Cria��o das trabelas temporarias *********/

	
		/*** Tebela que vai receber as contas com acesso a base de dados ***/
		CREATE TABLE #PermissionsDB(
			[Servidor] [varchar](255) NULL,
			[base] [varchar](255) NULL,
			[DbRole] [varchar](100) NULL,
			[MemberName] [nvarchar](100) NULL
			)
			
			declare @SqlCommand nvarchar(4000)

	        -- Se o servidor de sql for da vers�o 2000 ou 2008 executa este script.
			IF EXISTS(select @@version where @@version like '%Microsoft SQL Server  2000%' or @@version like '%Microsoft SQL Server 2005%')
			Begin
				
				set @SqlCommand = 'USE ['+ '?'  +']' 
									+'  '+
								   'insert into #PermissionsDB
								   ([Servidor],
									[base],
									[DbRole],
									[MemberName])
								   (select  @@SERVERNAME as  [Servidor]
										  , ''' + '?' + ''' as base
										  , USER_NAME(groupuid) AS [Role]
										  , USER_NAME(memberuid) AS [User]
									FROM  sysmembers)'				
					
				EXEC sp_MSForEachDB @SqlCommand		
									
			End	
			Else -- Se n�o for 2008 ou superior executa este
			Begin

				set @SqlCommand = 'USE ['+ '?'  +']' 
									+'  '+
								   'insert into #PermissionsDB
								   ([Servidor],
									[base],
									[DbRole],
									[MemberName])
								   (select @@SERVERNAME as  [Servidor]
										 ,''' + '?' + ''' as base
										 , g.name as  [DbRole]
										 , u.name as [MemberName]
									from sys.database_principals u
									, sys.database_principals g
									, sys.database_role_members m 
									where g.principal_id = m.role_principal_id and u.principal_id = m.member_principal_id)'				
									
				EXEC sp_MSForEachDB @SqlCommand		

			End

SELECT * FROM #PermissionsDB pdb
				   
/**** Role e user n�o existe no servidor ****/ 

                       
DROP TABLE #PermissionsDB 

END

GO


