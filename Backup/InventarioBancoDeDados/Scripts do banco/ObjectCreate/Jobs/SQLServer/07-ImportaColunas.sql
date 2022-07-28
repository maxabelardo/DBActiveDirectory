/*******************************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 10/12/2021
Data de alteração: 

Titulo: Extrai todas as colunas das tabelas dos banco de dados.

	Description: 
		O script do laço vai retornar todos os Linkd Server e os servidores que serão acessados, dentro do laço o script
	irar retornar todas as bases que não existem mas na origem mas foram cadastrada no sistema.
		O segundo laço lista todas as bases de dados do servidor selecionado no laço acima
		O script extrai todas tas tabelas e seus metadados.

	Tabela de origem, vinvuladas a base de dados indicada pelo segundo laço:
	.INFORMATION_SCHEMA.COLUMNS = obtenha informações sobre todas as colunas para todas as tabelas.

	Tabelas relacionadas com o destino:
		-"[dbo].[Trilha]" Tabelas com as trilhas dos ambientes.
		-"[ServerHost].[Servidor]" - Tabelas com os servidores Virtuais ou Fisícos.
		-"[SGBD].[Servidor]" - Tabela com as Estâncias de Banco de dados "SGBD".
		-"[SGBD].[BaseDeDados]" - Tabelas com as bases de dados.

	Observação: para facilitar o trabalho foi utilizado um View que retorna os dados das três tabelas acimas
		- [SGBD].[VW_BaseDeDados]
		- [SGBD].[BDTabela] 

	Tabelas de destino:
		- [SGBD].[TBColuna] 

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
	INSERT INTO [SGBD].[TBColuna]
			   ([idBDTabela]
			   ,[colunn_name]
			   ,[ordenal_positon]
			   ,[data_type])
				SELECT T.[idBDTabela],	C.column_name, C.ordinal_position, C.data_type 
				FROM '+ RTRIM(@LinkedServer) + '.'+ RTRIM(@BasedeDados) + '.INFORMATION_SCHEMA.COLUMNS AS C
				INNER JOIN [SGBD].[VW_BaseDeDados] AS D ON D.[Servidor] LIKE '''+ RTRIM(@LinkedEstancia)+''' AND D.[BasedeDados] LIKE '''+ RTRIM(@BasedeDados) + '''
				INNER JOIN [SGBD].[BDTabela] AS T ON T.[idBaseDeDados] = D.[idBaseDeDados] AND T.[schema_name] COLLATE Latin1_General_CI_AS = C.table_schema AND T.[table_name] COLLATE Latin1_General_CI_AS = C.table_name
				WHERE NOT EXISTS(SELECT * FROM [SGBD].[TBColuna] AS TC WHERE TC.[idBDTabela] = T.[idBDTabela]
				                                                         AND TC.[colunn_name] COLLATE Latin1_General_CI_AS = C.column_name)
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
