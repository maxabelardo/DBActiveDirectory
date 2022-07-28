/****************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 10/12/2021
Data de alteração: 

Objetivo:
   Derivar as licenças no campos "[TxLicening]" da tabelas "[AD].[STGADUser]" cruzar o resultado com a tabelas [dbo].[Lincesing] no campo "[String_ Id]"
   O resultado será inserido na tabelas "[dbo].[UserLincesing]" mais o ID do usuário.

****************************************************************************************************/

--Variáveis
	--Receber o script que será executado.
	DECLARE @ScriptCommand nvarchar(4000)

	--Receber a licença.
	DECLARE @TX00 Nvarchar(max)
	
	--Recebe o total de caracteres.
	DECLARE @Mcont INT
	
	--Recebe a possição da virgula.
	DECLARE @Pvirgula INT
	
	--Recebe o id do usuário.
	DECLARE @idSTGADUser INT
	
	--Recebe o id da licença.
	DECLARE @idLincesing INT
	
	--Recebe a licenças do usuário.
	DECLARE @TxLicening Nvarchar(max)

--Variável do Loop.
DECLARE db_for CURSOR FOR
	--Lista todos os usuários e a licenças.
	SELECT [idSTGADUser],RTRIM(LTRIM([TxLicening]))
		FROM [AD].[STGADUser]
--Abre o Loop.
OPEN db_for 
--Carrega os valores nas variáveis.
FETCH NEXT FROM db_for INTO @idSTGADUser, @TxLicening

/*Inicia o Loop, se a Variável "@@FETCH_STATUS" está função muda de 0 para outro valor quando o Loop chega ao fim
ou seja quando a matriz chegar ao fim o valor da função muda e o Loop chega ao fim. */
WHILE @@FETCH_STATUS = 0
BEGIN
	--Subistitui a palavra chave pelo ponto e virgula.
	SET @TxLicening = REPLACE(@TxLicening,'infraerogovbr:',';')
	--Total de caracteres.
	SET @Mcont = LEN(@TxLicening)
		--Enquanto a variável estiver maior que 0 o Loop vai continuar.
		WHILE @Mcont > 0 
		BEGIN

		--Localiza a possição inicial da palavra chave.
		SET @Pvirgula = CHARINDEX(';', @TxLicening)
		
		--Capitura o texto sem o ponto e virgula.
		SET @TX00 = RIGHT(@TxLicening, (@Mcont - @Pvirgula))	

		-- Localizo o proximo ponto e virgula.
		SET @Pvirgula = CHARINDEX(';', @TX00)
			
			--Se a possição da virgular for maior que 0 seguinifica que tem mais licença.
			IF (@Pvirgula > 0)
				BEGIN 
					--Remove o valor que será inserido na tabela.
					SET @TX00 = LEFT(@TX00,(@Pvirgula - 1))
					--Capitura o texto antes do ponto e virgula
					SET @TxLicening = RIGHT(@TxLicening,(@Mcont - @Pvirgula))	
					--Inicia o contator com o numero de caracteres restantes.
					SET @Mcont = LEN(@TxLicening) 				
				END
			ELSE--Se a possição da virgula for zero seguinificaque não tem mais licença, então a variável recebe 0 para finalizar o Loop.
				BEGIN
					SET @Mcont = 0
				END
				
				--Localiza o Id da licença. 
				SELECT @idLincesing = [idLincesing]
				  FROM [dbo].[Lincesing]
				  WHERE [String_ Id] = @TX00
				
				--Verificar se a licença existe.
				--Se o valor for possitivo seginifica que o registro foi encontrado
				IF (@idLincesing > 0 )
				BEGIN
					--Cadastra o resultado na tabela "[dbo].[UserLincesing]".
					SET @ScriptCommand = 'INSERT INTO [dbo].[UserLincesing]([idSTGADUser],[idLincesing])
										  VALUES('+ CAST(@idSTGADUser AS NVARCHAR(30)) +','+ CAST(@idLincesing AS NVARCHAR(30)) +')'
				END

			 --PRINT @ScriptCommand

			 --Executa os script montado logo acima.
			 EXEC sp_executesql @ScriptCommand
		END

	--Carrega o próximo valor nas variáveis.
	FETCH NEXT FROM db_for INTO @idSTGADUser, @TxLicening
END

--Fecha o Loop e desaloca a memória.
CLOSE db_for
DEALLOCATE db_for