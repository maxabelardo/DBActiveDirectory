USE [master]
GO

/****** Object:  StoredProcedure [dbo].[SP_PermissionDB]    Script Date: 09/03/2020 10:15:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		José Abelardo 
-- Create date: 01/03/2013
-- Description:	SP de documentação
-- =============================================

CREATE PROCEDURE [dbo].[SP_PermissionDB]
AS
BEGIN
/* *************************************************************************************************/
/*                     Estes script tem a finalidade de monitora todas as bases                    */
/*                            e seus resulados seram utilizados                                    */
/*                                para criação de  relatorios								       */
/***************************************************************************************************/

 ----------------------------------------------------------------------------------------------------
 ---- Descrição do Script 
 ---- Este script lista todas os usuários com acesso direto ao Database e suas permissões.
 ----		1º Listas os usuários das Databases
 ----		2º Listas o nivel de acesso de cada usuário
 ----		3º Verifica se o usuário existe no servidor se não adiciona
 ----		4º Verifica se o usuário que esta no servidor foi retirado da Database, se sim ele e desativado
 ----		5º Verifica se o usuário que foi desativa voltou a ser ativo e atualzia o mesmo. 
 ----------------------------------------------------------------------------------------------------


/******* Criação das trabelas temporarias *********/

	
		/*** Tebela que vai receber as contas com acesso a base de dados ***/
		CREATE TABLE #PermissionsDB(
			[Servidor] [varchar](255) NULL,
			[base] [varchar](255) NULL,
			[DbRole] [varchar](100) NULL,
			[MemberName] [nvarchar](100) NULL
			)
			
			declare @SqlCommand nvarchar(4000)

	        -- Se o servidor de sql for da versão 2000 ou 2008 executa este script.
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
			Else -- Se não for 2008 ou superior executa este
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
				   
/**** Role e user não existe no servidor ****/ 

                       
DROP TABLE #PermissionsDB 

END

GO


