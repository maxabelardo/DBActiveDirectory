/*******************************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 10/12/2021
Data de alteração: 

Titulo: Extrai as estatisticas dos index de tabela de um banco de dados.

	Description: 
		O script do laço vai retornar todos os Linkd Server e os servidores que serão acessados, dentro do laço o script
	irar retornar todas as bases que não existem mas na origem mas foram cadastrada no sistema.
		O segundo laço lista todas as bases de dados do servidor selecionado no laço acima
		O script extrai todas tas tabelas e seus metadados.

	Tabela de origem, vinvuladas a base de dados indicada pelo segundo laço:
		.master.sys.dm_db_index_usage_stats = Retorna contas de tipos diferentes de operações de índice e a hora em que cada tipo de operação foi executada pela última vez.
		.sys.objects = Contém uma linha para cada objeto definido pelo usuário com escopo de esquema criado em um banco de dados.
		.sys.schemas = Contém uma linha para cada esquema de banco de dados.
		.sys.indexes = Contém uma linha por índice ou heap de um objeto tabular, como uma tabela, visão ou função com valor de tabela.
		.sys.data_spaces = Contém uma linha para cada espaço de dados. Esse pode ser um grupo de arquivos, esquema de partição ou grupo de arquivos de dados FILESTREAM.

	Tabelas relacionadas com o destino:
		-"[dbo].[Trilha]" Tabelas com as trilhas dos ambientes.
		-"[ServerHost].[Servidor]" - Tabelas com os servidores Virtuais ou Fisícos.
		-"[SGBD].[Servidor]" - Tabela com as Estâncias de Banco de dados "SGBD".
		-"[SGBD].[BaseDeDados]" - Tabelas com as bases de dados.

	Observação: para facilitar o trabalho foi utilizado um View que retorna os dados das três tabelas acimas
		- [SGBD].[VW_BaseDeDados]
		- [SGBD].[BDTabela] 

	Tabelas de destino:
	

*******************************************************************************************************************************/
--Variáveis de ambiente.
DECLARE @LinkedServer nchar(50)
DECLARE @LinkedEstancia nchar(50)
DECLARE @ExeScript nchar(3000)
DECLARE @idBaseDeDados INT
DECLARE @idDBServidor INT
DECLARE @BasedeDados nchar(255)
DECLARE @lError SMALLINT

--1º Loop
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
--2º Loop
--Variável do Loop
	DECLARE db_forA CURSOR FOR
	    --Select do Loop, listas toda as bases de dados que estiverem online.
		SELECT [idBaseDeDados], [idDBServidor], BasedeDados
		 FROM [SGBD].[VW_BaseDeDados]
		  WHERE [dbid] > 4
		    AND Servidor = @LinkedEstancia
			AND [OnlineOffline] = 'ONLINE'
	     ORDER BY Servidor, BasedeDados
	--Abre o Loop
	OPEN db_forA                     --Variáveis que receberam os dados extraidos no select acima.
		FETCH NEXT FROM db_forA INTO @idBaseDeDados, @idDBServidor, @BasedeDados

			--Loop: Enquanto a variável "@@FETCH_STATUS" for igual a Zero o Loop continuará ser executados.
			--Quanto o Loope chegar ao fim das lista criadas no select do Loop a variável "@@FETCH_STATUS" muda automaticamente.
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
SET @ExeScript = '
SELECT DISTINCT
		X.[idTBIndex]						
	, last_user_seek
	, last_user_scan
	, last_user_lookup
	, last_user_update
	, user_seeks
	, user_scans
	, user_lookups
	, user_updates
FROM '+ RTRIM(@LinkedServer) + '.master.sys.dm_db_index_usage_stats A
INNER JOIN '+ RTRIM(@LinkedServer) + '.'+ RTRIM(@BasedeDados) + '.sys.objects B on B.object_id = A.object_id
INNER JOIN '+ RTRIM(@LinkedServer) + '.'+ RTRIM(@BasedeDados) + '.sys.schemas S on S.schema_id = B.schema_id
INNER JOIN '+ RTRIM(@LinkedServer) + '.'+ RTRIM(@BasedeDados) + '.sys.indexes I on I.object_id = A.object_id AND I.index_id = A.index_id
INNER JOIN '+ RTRIM(@LinkedServer) + '.'+ RTRIM(@BasedeDados) + '.sys.data_spaces E on E.data_space_id = I.data_space_id
INNER JOIN [SGBD].[VW_BaseDeDados] AS D ON D.SERVIDOR LIKE '''+ RTRIM(@LinkedEstancia) + ''' AND D.[dbid] = A.database_id
INNER JOIN [SGBD].[BDTabela] AS T ON T.idBaseDeDados = D.idBaseDeDados AND T.schema_name COLLATE Latin1_General_CI_AS = s.name AND T.table_name COLLATE Latin1_General_CI_AS = B.name
INNER JOIN [SGBD].[TBIndex] AS X ON X.idBDTabela = T.idBDTabela AND X.Index_name = I.Name COLLATE Latin1_General_CI_AS 
WHERE A.database_id > 4 and B.is_Ms_shipped = 0 
					
				'
				
				--Caso aconteça algum erro na execução do script montado o mesmo é ignorado.
				BEGIN TRY
					exec sp_executesql @ExeScript
				END TRY	
				BEGIN CATCH
					PRINT 'Este insert foi ignorado!';
				END CATCH

				/*print @ExeScript*/
				--Carrega a variáveis com um novo valor
				FETCH NEXT FROM db_forA INTO  @idBaseDeDados, @idDBServidor, @BasedeDados
			END
	--Finalizado o 2º Loop a variável e fechada e desaloca a memória.
	CLOSE db_forA
	DEALLOCATE db_forA
	--Carrega a variáveis com um novo valor
	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia
END
--Finalizado o 1º Loop a variável e fechada e desaloca a memória.
CLOSE db_for
DEALLOCATE db_for
