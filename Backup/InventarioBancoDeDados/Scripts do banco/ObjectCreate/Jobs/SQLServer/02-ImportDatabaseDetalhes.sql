/*******************************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 8/12/2021
Data de alteração: 

Titulo: Database (Inserir os tetalhes das novas bases)

Objetivo: Estrair os meta dados DOS DETALHES das bases de dados dos servidores de cadastrados na tabelas "[SGBD].[Servidor]".

	Description: 
		O script do laço vai retornar todos os Linkd Server e os servidores que serão acessados, dentro do laço o script
	irar retornar todas as bases que ainda não foram cadastrada, o filtro é feito atraves do "WHERE NOT EXISTIS".

	Tabelas de origem:
		-"[master].[sys].[databases]" - Retorna todas as bases de dados
		-"[master].[sys].syslogins" - Retorna o usuário owner da base.

	Tabelas relacionadas com o destino:
		-"[dbo].[Trilha]" Tabelas com as trilhas dos ambientes.
		-"[ServerHost].[Servidor]" - Tabelas com os servidores Virtuais ou Fisícos.
		-"[SGBD].[Servidor]" - Tabela com as Estâncias de Banco de dados "SGBD".
		-"[SGBD].[BaseDeDados]" - Tabelas com as bases de dados.

	Observação: para facilitar o trabalho foi utilizado um View que retorna os dados das três tabelas acimas
		- [SGBD].[VW_BaseDeDados]

	Tabelas de destino:
		-[SGBD].[BaseDeDados]

*******************************************************************************************************************************/
--Variáveis de ambiente.
DECLARE @LinkedServer nchar(50)
DECLARE @LinkedEstancia nchar(50)
DECLARE @ExeScript nchar(3000)
DECLARE @lError SMALLINT

--Variável do Loop
DECLARE db_for CURSOR FOR
	--Select do Loop, listas todos o Linked Server e os Servidores a quais eles estão ligados
	SELECT a.name, a.product
		FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
				LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
					WHERE a.name like 'LNK_SQL_%' 
						ORDER BY a.name
--Abre o Loop
OPEN db_for				 --Variáveis que receberam os dados extraidos no select acima.
FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia

--Loop: Enquanto a variável "@@FETCH_STATUS" for igual a Zero o Loop continuará ser executados.
--Quanto o Loope chegar ao fim das lista criadas no select do Loop a variável "@@FETCH_STATUS" muda automaticamente.
WHILE @@FETCH_STATUS = 0
BEGIN
--A variável @ExeScript recebe o script montado com os valores das variáves do Loop
SET @ExeScript = '
INSERT INTO [SGBD].[BDSQLServer]
           ([idBaseDeDados]
           ,[owner]
           ,[dbid]
           ,[OnlineOffline]
           ,[RestrictAccess]
           ,[recovery_model]
           ,[collation]
           ,[compatibility_level])
						select S.[idBaseDeDados]
							  ,L.[name]
							  ,[database_id]
							  ,[state_desc] 
							  ,[user_access_desc]
							  ,[recovery_model_desc]
							  ,[collation_name] 
							  ,DB.[compatibility_level]
			from '+ RTRIM(@LinkedServer) + '.[master].[sys].[databases] AS DB
			left join '+ RTRIM(@LinkedServer) + '.[master].[sys].syslogins  AS L ON L.sid = DB.owner_sid
			INNER JOIN [SGBD].[VW_BaseDeDados] AS S ON S.SERVIDOR LIKE '''+ RTRIM(@LinkedEstancia)+'''  AND S.[BasedeDados] = DB.name COLLATE DATABASE_DEFAULT 
			WHERE NOT EXISTS(select * from [SGBD].[VW_BaseDeDados] AS D
					            where D.[idDBServidor] = S.[idDBServidor] 
								and D.Basededados COLLATE DATABASE_DEFAULT = DB.name COLLATE DATABASE_DEFAULT
								and D.[dbid] = DB.[database_id])  '
			
--Caso aconteça algum erro na execução do script montado o mesmo é ignorado.
	BEGIN TRY
		exec sp_executesql @ExeScript
	END TRY	
	BEGIN CATCH
		PRINT 'Este insert foi ignorado!';
	END CATCH	
/*
	print @ExeScript
*/	
--Carrega a variáveis com um novo valor
	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia
END

--Finalizado o Loop a variável e fechada e desaloca a memória.
CLOSE db_for
DEALLOCATE db_for

