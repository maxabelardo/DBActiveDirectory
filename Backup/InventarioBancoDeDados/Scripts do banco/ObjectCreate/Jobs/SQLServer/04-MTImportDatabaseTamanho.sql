/*******************************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 10/12/2021
Data de alteração: 

Titulo: Extrai o tamnho atual da base de dados, para controle e previsão de crescimento.

	Description: 
		O script do laço vai retornar todos os Linkd Server e os servidores que serão acessados, dentro do laço o script
	irar retornar todas as bases que não existem mas na origem mas foram cadastrada no sistema.

	Campo ativo será mudado para 0.

	Tabela de origem:
		-".master.sys.master_files" - Retorna o tamanho dos arquivos das bases de dados.

	Tabelas relacionadas com o destino:
		-"[dbo].[Trilha]" Tabelas com as trilhas dos ambientes.
		-"[ServerHost].[Servidor]" - Tabelas com os servidores Virtuais ou Fisícos.
		-"[SGBD].[Servidor]" - Tabela com as Estâncias de Banco de dados "SGBD".
		-"[SGBD].[BaseDeDados]" - Tabelas com as bases de dados.

	Observação: para facilitar o trabalho foi utilizado um View que retorna os dados das três tabelas acimas
		- [SGBD].[VW_BaseDeDados]

	Tabelas de destino:
		-[SGBD].[MTBDTamanho] = Tabela de Metrica "MT".

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
INSERT INTO [SGBD].[MTBDTamanho]
           ([idBaseDeDados]
           ,[Tamanho])
SELECT S.idBaseDeDados  
		,total_size_mb = CAST(SUM(size) * 8. / 1024 AS DECIMAL(10,2))
	FROM '+ RTRIM(@LinkedServer) + '.master.sys.master_files AS Z WITH(NOWAIT) 
	INNER JOIN [SGBD].[VW_BaseDeDados] AS S ON S.[Servidor] LIKE '''+ RTRIM(@LinkedEstancia)+'''  
											AND S.dbid = Z.database_id
GROUP BY S.idBaseDeDados	
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
*/
--Carrega a variáveis com um novo valor
	FETCH NEXT FROM db_for INTO @LinkedServer, @LinkedEstancia
END

--Finalizado o Loop a variável e fechada e desaloca a memória.
CLOSE db_for
DEALLOCATE db_for

