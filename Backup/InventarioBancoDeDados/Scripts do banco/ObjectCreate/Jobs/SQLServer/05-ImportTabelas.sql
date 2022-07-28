/*******************************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 10/12/2021
Data de alteração: 

Titulo: Extra todas as tabelas dos banco de dados.

	Description: 
		O script do laço vai retornar todos os Linkd Server e os servidores que serão acessados, dentro do laço o script
	irar retornar todas as bases que não existem mas na origem mas foram cadastrada no sistema.
		O segundo laço lista todas as bases de dados do servidor selecionado no laço acima
		O script extrai todas tas tabelas e seus metadados.

	Tabela de origem, vinvuladas a base de dados indicada pelo segundo laço:
	.sys.dm_db_partition_stats = Retorna informações de contagem de linhas e páginas para toda partição no banco de dados atual.
	.sys.objects = Contém uma linha para cada objeto definido pelo usuário com escopo de esquema criado em um banco de dados.
	.sys.schemas = Contém uma linha para cada esquema de banco de dados
	.sys.indexes = Contém uma linha por índice ou heap de um objeto tabular, como uma tabela, visão ou função com valor de tabela.

	Tabelas relacionadas com o destino:
		-"[dbo].[Trilha]" Tabelas com as trilhas dos ambientes.
		-"[ServerHost].[Servidor]" - Tabelas com os servidores Virtuais ou Fisícos.
		-"[SGBD].[Servidor]" - Tabela com as Estâncias de Banco de dados "SGBD".
		-"[SGBD].[BaseDeDados]" - Tabelas com as bases de dados.

	Observação: para facilitar o trabalho foi utilizado um View que retorna os dados das três tabelas acimas
		- [SGBD].[VW_BaseDeDados]

	Tabelas de destino:
		- [SGBD].[BDTabela] 

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
if object_id(''Tempdb..#tabelas'') is not null drop table #tabelas

	;with table_space_usage (schema_name,table_Name,index_Name,used,reserved,ind_rows,tbl_rows,type_Desc,table_type)
	AS(select s.name, o.name,coalesce(i.name,''heap''),p.used_page_Count*8,p.reserved_page_count*8, p.row_count,
	case when i.index_id in (0,1) then p.row_count else 0 end, i.type_Desc,o.type_desc AS table_type
	from '+ RTRIM(@LinkedServer) + '.'+ RTRIM(@BasedeDados) + '.sys.dm_db_partition_stats p
	join '+ RTRIM(@LinkedServer) + '.'+ RTRIM(@BasedeDados) + '.sys.objects o on o.object_id = p.object_id
	join '+ RTRIM(@LinkedServer) + '.'+ RTRIM(@BasedeDados) + '.sys.schemas s on s.schema_id = o.schema_id
	left join '+ RTRIM(@LinkedServer) + '.'+ RTRIM(@BasedeDados) + '.sys.indexes i on i.object_id = p.object_id and i.index_id = p.index_id
	where o.type_desc = ''user_Table'' and o.is_Ms_shipped = 0)
	SELECT t.schema_name
			, t.table_Name
			, t.table_type
			, t.index_name
			, type_Desc
			, sum(t.used) as used_in_kb
			, sum(t.reserved) as reserved_in_kb
			, case grouping (t.index_name) 
			when 0 then sum(t.ind_rows) 
			else sum(t.tbl_rows) 
			end as rows
	into #tabelas
	FROM table_space_usage t
	group by t.schema_name
			, t.table_Name
			, t.table_type
			, t.index_Name
			, type_Desc
	with rollup
	order by grouping(t.schema_name),t.schema_name
			,grouping(t.table_Name),t.table_Name
			,grouping(t.table_type),t.table_type
			,grouping(t.index_Name),t.index_name

if object_id(''Tempdb..#Resultado_Final'') is not null drop table #Resultado_Final

	select Schema_Name
			, Table_Name 
			, table_type
			, sum(reserved_in_kb) [Reservado(KB)]
			, sum(case 
				when Type_Desc in (''CLUSTERED'',''HEAP'') then reserved_in_kb 
				else 0 
				end) [Dados(KB)]
			, sum(case 
					when Type_Desc in (''NONCLUSTERED'') then reserved_in_kb 
					else 0 
				end) [Indices(KB)]
			, max(rows) Qtd_Linhas		
	into #Resultado_Final
	from #tabelas
	where index_Name is not null
			and Type_Desc is not null
	group by Schema_Name, Table_Name ,table_type
	--having sum(reserved_in_kb) > 10000
	order by 3 desc

INSERT INTO [SGBD].[BDTabela]
           ([idBaseDeDados]
           ,[schema_name]
           ,[table_name]
           ,[reservedkb]
           ,[datakb]
           ,[Indiceskb]
           ,[sumline]
           ,[dataupdate])
				SELECT D.[idBaseDeDados]
						, R.Schema_Name
						, R.Table_Name
						, CAST(R.[Reservado(KB)] AS REAL) AS Reservado
						, CAST(R.[Dados(KB)] AS REAL) AS Dados
						, CAST(R.[Indices(KB)] AS REAL) AS Indices
						, R.Qtd_Linhas
						, GETDATE()
				FROM #Resultado_Final AS R
				INNER JOIN [SGBD].[VW_BaseDeDados] AS D ON D.[Servidor] LIKE '''+ RTRIM(@LinkedEstancia)+''' AND D.[BasedeDados] LIKE '''+ RTRIM(@BasedeDados) + '''
				    WHERE NOT EXISTS (SELECT * FROM [SGBD].[BDTabela] AS T WHERE T.[idBaseDeDados]  = D.[idBaseDeDados] 
				      AND T.[schema_name] COLLATE Latin1_General_CI_AS = R.Schema_Name	
				      AND T.[table_name]  COLLATE Latin1_General_CI_AS = R.Table_Name)
				'
				
				--Caso aconteça algum erro na execução do script montado o mesmo é ignorado.
				BEGIN TRY
					exec sp_executesql @ExeScript
				END TRY	
				BEGIN CATCH
					PRINT 'Este insert foi ignorado!';
				END CATCH
/*
				print @ExeScript
*/				--Carrega a variáveis com um novo valor
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
