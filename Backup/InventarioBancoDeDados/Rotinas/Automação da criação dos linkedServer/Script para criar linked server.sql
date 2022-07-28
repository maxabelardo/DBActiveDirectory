/****************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 05/12/2021
Data de alteração: 

Objetivo:
    Este script são usuado para verificar se para cadas estância de banco cadastrada no banco existe
um linke Server para ele.

Descrição:
    O script executa verifica dentro do lop o select com verifica se existe um Linked Server para cadas 
Estância cadastrada no banco, o retorno será apenas o servidores sem Linked Server, o paramêtro dentro 
do Select que flitra é "WHERE product IS NULL"

****************************************************************************************************/

DECLARE @RC int
DECLARE @HostName nvarchar(50)
DECLARE @Servidor nvarchar(50)
DECLARE @SGBD nvarchar(30)
DECLARE @conectstring nvarchar(30)
DECLARE @product nvarchar(30)
DECLARE @Lnk nvarchar(30)

DECLARE db_for CURSOR FOR
    --Retorna todas as estância sem Linked Server.
	SELECT TOP 1  CASE 
	         WHEN ([Estancia] = '' or [Estancia] = ' ' or [Estancia] is null ) AND [Cluster] = 0 THEN REPLACE([HostName],'-','_')
			 WHEN [Cluster] = 1 THEN [Servidor]
			 ELSE [Estancia] END AS 'HostName', [Servidor],[SGBD],[conectstring], product, Lnk
	  FROM [SGBD].[Estancias] AS A 
	  LEFT JOIN (SELECT a.name AS Lnk, a.product 
				   FROM sys.Servers a
					LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
					 LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id) AS B ON B.product = A.[Servidor]
	  WHERE product IS NULL
	    AND [SGBD] =  'PostgreSQL'

OPEN db_for 
FETCH NEXT FROM db_for INTO @HostName, @Servidor, @SGBD, @conectstring, @product,@Lnk
WHILE @@FETCH_STATUS = 0
BEGIN
/* A variável "@SGBD" armazena a tecnologia do SGBD da estância, com isto para cada estância 
exite um SP que deverá criar o Linked Server.
*/
	IF (@SGBD = 'SQL Server')
		BEGIN
			EXECUTE @RC = [dbo].[SP_CreateLinkServer_SQL] @HostName,@Servidor,@conectstring
			--PRINT @conectstring
		END
	IF (@SGBD = 'MySQL')
		BEGIN
			EXECUTE @RC = [dbo].[SP_CreateLinkServer_MySQL] @HostName,@Servidor,@conectstring
			--PRINT @conectstring
		END
	IF (@SGBD = 'PostgreSQL')
		BEGIN
			EXECUTE @RC = [dbo].[SP_CreateLinkServer_PostgreSQL] @HostName,@Servidor,@conectstring
			--PRINT @conectstring
		END
	IF (@SGBD = 'ORACLE')
		BEGIN
			--EXECUTE @RC = [dbo].[SP_CreateLinkServer_SQL] @HostName,@Servidor,@conectstring
			PRINT @conectstring
		END

--		EXECUTE @RC = [dbo].[SP_CreateLinkServer_SQL] @HostName,@Servidor,@conectstring

	FETCH NEXT FROM db_for INTO @HostName, @Servidor,@SGBD, @conectstring, @product,@Lnk
END

CLOSE db_for
DEALLOCATE db_for
