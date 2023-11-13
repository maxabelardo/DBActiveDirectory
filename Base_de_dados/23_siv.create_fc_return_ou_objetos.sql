
CREATE FUNCTION [siv].[fc_return_ou_objetos] (@Nome Nvarchar(max),@OU Nvarchar(max))
Returns @res TABLE ([Cont] INT NULL,[Nome] Nvarchar(max) NULL,[OU] Nvarchar(max) NULL, [DistinguishedName] Nvarchar(max) NULL)
AS
BEGIN

DECLARE @TX00 Nvarchar(max)
DECLARE @Mcont INT
DECLARE @McontVirgula INT
DECLARE @McontCN INT
DECLARE @McontOU INT
DECLARE @McontDC INT
DECLARE @Text Nvarchar(max)
DECLARE @Cont INT
SET @Cont = 0
DECLARE @Dir Nvarchar(max) 
SET @Dir =''
/*
--Esta parte é usada para testa a função.
DECLARE @Nome Nvarchar(max)
DECLARE @OU Nvarchar(max)
DECLARE @C INT
DECLARE @O INT

SET @Nome = 'Sebastião Ferreira da Silva'
SET @OU ='CN=Sebastião Ferreira da Silva,OU=TELEFONIA,OU=INFRAESTRUTURA,OU=PRODUCAO,OU=Admins,OU=SEDE,DC=contoso,DC=com,DC=br'
--SET @OU ='OU=SEDE,DC=contoso,DC=com,DC=br'
CREATE TABLE #TBOU ([Cont] INT NULL, [Nome] Nvarchar(max) NULL,[OU] Nvarchar(max) NULL , [DistinguishedName] Nvarchar(max) NULL)
--DROP TABLE #TBOU
*/
	WHILE (SELECT LEN(@OU)) > 1
	BEGIN
		--Retorna o total de Caracteres
		SET @Mcont = (SELECT LEN(@OU))
		SET @Cont = @Cont + 1
		--Localiza o local da chave CN= e OU=
		SET @McontCN = CHARINDEX('CN=', @OU)
		SET @McontOU = CHARINDEX('OU=', @OU)
		SET @McontDC = CHARINDEX('DC=', @OU)

			IF (@McontCN = 1)
			BEGIN
				--Soma a possição da chave CN= , o valor é 1 + 2 por conta do N= assim o valor passa para 3
				SET @McontCN = @McontCN + 2

				--Remover a chave CN=
				SET @TX00 = RIGHT(@OU, @Mcont - @McontCN)

				--Localizar a possição da virgula
				SET @McontVirgula = CHARINDEX(',', @TX00)

				-- Transferi o valor depois da chave até a virgula para variável
				SET @Text = LEFT(@TX00, @McontVirgula - 1)
				
				    --Esta parte é usada para testa a função.
					--SELECT @C = CHARINDEX('CN=', @TX00)
					--SELECT @O = CHARINDEX('OU=', @TX00)

					-- Verifica se existe mas chave CN= no inicio do texto
					IF (SELECT CHARINDEX('CN=', @TX00) ) > 0
					BEGIN 
					   --Retorna o total de Caracteres
						SET @Mcont = (SELECT LEN(@TX00)) 
						--Localiza o local da chave CN=
						SET @McontCN = CHARINDEX('CN=', @TX00)
						--Soma a possição da chave CN= , o valor é 1 + 2 por conta do N= assim o valor passa para 3
						SET @McontCN = @McontCN - 1
						--Remove o texto até a chave DC=
						SET @OU = RIGHT(@TX00,( @Mcont - @McontCN) )

					END -- Verifica se existe mas chave OU= no inicio do texto
					ELSE IF (SELECT CHARINDEX('OU=', @TX00) ) > 0
					BEGIN--Retorna o total de Caracteres
						SET @Mcont = (SELECT LEN(@TX00)) 
						--Localiza o local da chave OU=
						SET @McontOU = CHARINDEX('OU=', @TX00)
						--Soma a possição da chave OU= , o valor é 1 + 2 por conta do N= assim o valor passa para 3
						SET @McontOU = @McontOU - 1
						--Remove o texto até a chave OU=
						SET @OU = RIGHT(@TX00,( @Mcont - @McontOU) )

					END-- Verifica se existe mas chave DC= no inicio do texto
					ELSE IF (SELECT CHARINDEX('DC=', @TX00) ) > 0
					BEGIN--Retorna o total de Caracteres
						SET @Mcont = (SELECT LEN(@TX00)) 
						--Localiza o local da chave OU=
						SET @McontDC = CHARINDEX('DC=', @TX00)
						--Soma a possição da chave OU= , o valor é 1 + 2 por conta do N= assim o valor passa para 3
						SET @McontDC = @McontDC - 1
						--Remove o texto até a chave OU=
						SET @OU = RIGHT(@TX00,( @Mcont - @McontDC) )
					END
					ELSE
					BEGIN
						SET @OU = ''
					END
			END
			ELSE 
			IF (@McontOU = 1)
			BEGIN
				--Soma a possição da chave CN= , o valor é 1 + 2 por conta do N= assim o valor passa para 3
				SET @McontOU = @McontOU + 2

				--Remover a chave CN=
				SET @TX00 = RIGHT(@OU, @Mcont - @McontOU)

				--Localizar a possição da virgula
				 SET @McontVirgula = CHARINDEX(',', @TX00)

				-- Transferi o valor depois da chave até a virgula para variável
				SET @Text = LEFT(@TX00, @McontVirgula - 1)
				
					--Esta parte é usada para testa a função.
					--SELECT @C = CHARINDEX('CN=', @TX00)
					--SELECT @O = CHARINDEX('OU=', @TX00)

					-- Verifica se existe mas chave CN= no inicio do texto
					IF (SELECT CHARINDEX('CN=', @TX00) ) > 0
					BEGIN 
					   --Retorna o total de Caracteres
						SET @Mcont = (SELECT LEN(@TX00)) 
						--Localiza o local da chave CN=
						SET @McontCN = CHARINDEX('CN=', @TX00)
						--Soma a possição da chave CN= , o valor é 1 + 2 por conta do N= assim o valor passa para 3
						SET @McontCN = @McontCN - 1
						--Remove o texto até a chave DC=
						SET @OU = RIGHT(@TX00,( @Mcont - @McontCN) )

					END -- Verifica se existe mas chave OU= no inicio do texto
					ELSE IF (SELECT CHARINDEX('OU=', @TX00) ) > 0
					BEGIN--Retorna o total de Caracteres
						SET @Mcont = (SELECT LEN(@TX00)) 
						--Localiza o local da chave OU=
						SET @McontOU = CHARINDEX('OU=', @TX00)
						--Soma a possição da chave OU= , o valor é 1 + 2 por conta do N= assim o valor passa para 3
						SET @McontOU = @McontOU - 1
						--Remove o texto até a chave OU=
						SET @OU = RIGHT(@TX00,( @Mcont - @McontOU) )

					END-- Verifica se existe mas chave DC= no inicio do texto
					ELSE IF (SELECT CHARINDEX('DC=', @TX00) ) > 0
					BEGIN--Retorna o total de Caracteres
						SET @Mcont = (SELECT LEN(@TX00)) 
						--Localiza o local da chave OU=
						SET @McontDC = CHARINDEX('DC=', @TX00)
						--Soma a possição da chave OU= , o valor é 1 + 2 por conta do N= assim o valor passa para 3
						SET @McontDC = @McontDC - 1
						--Remove o texto até a chave OU=
						SET @OU = RIGHT(@TX00,( @Mcont - @McontDC) )
					END
			END
			ELSE 
			IF (@McontDC = 1)
			BEGIN
				--Soma a possição da chave CN= , o valor é 1 + 2 por conta do N= assim o valor passa para 3
				SET @McontDC = @McontDC + 2

				--Remover a chave CN=
				SET @TX00 = RIGHT(@OU, @Mcont - @McontDC)

				--Localizar a possição da virgula
				SET @McontVirgula = CHARINDEX(',', @TX00)


				-- Transferi o valor depois da chave até a virgula para variável
				IF (@McontVirgula > 0 )
				BEGIN
					SET @Text = LEFT(@TX00, @McontVirgula - 1)
				END
				ELSE
				BEGIN
					SET @Text = RIGHT(@TX00, @Mcont - @McontDC)
				END

					--Esta parte é usada para testa a função.
					--SELECT @C = CHARINDEX('CN=', @TX00)
					--SELECT @O = CHARINDEX('OU=', @TX00)

					-- Verifica se existe mas chave CN= no inicio do texto
					IF (SELECT CHARINDEX('CN=', @TX00) ) > 0
					BEGIN 
					   --Retorna o total de Caracteres
						SET @Mcont = (SELECT LEN(@TX00)) 
						--Localiza o local da chave CN=
						SET @McontCN = CHARINDEX('CN=', @TX00)
						--Soma a possição da chave CN= , o valor é 1 + 2 por conta do N= assim o valor passa para 3
						SET @McontCN = @McontCN - 1
						--Remove o texto até a chave DC=
						SET @OU = RIGHT(@TX00,( @Mcont - @McontCN) )

					END -- Verifica se existe mas chave OU= no inicio do texto
					ELSE IF (SELECT CHARINDEX('OU=', @TX00) ) > 0
					BEGIN--Retorna o total de Caracteres
						SET @Mcont = (SELECT LEN(@TX00)) 
						--Localiza o local da chave OU=
						SET @McontOU = CHARINDEX('OU=', @TX00)
						--Soma a possição da chave OU= , o valor é 1 + 2 por conta do N= assim o valor passa para 3
						SET @McontOU = @McontOU - 1
						--Remove o texto até a chave OU=
						SET @OU = RIGHT(@TX00,( @Mcont - @McontOU) )

					END-- Verifica se existe mas chave DC= no inicio do texto
					ELSE IF (SELECT CHARINDEX('DC=', @TX00) ) > 0
					BEGIN--Retorna o total de Caracteres
						SET @Mcont = (SELECT LEN(@TX00)) 
						--Localiza o local da chave OU=
						SET @McontDC = CHARINDEX('DC=', @TX00)
						--Soma a possição da chave OU= , o valor é 1 + 2 por conta do N= assim o valor passa para 3
						SET @McontDC = @McontDC - 1
						--Remove o texto até a chave OU=
						SET @OU = RIGHT(@TX00,( @Mcont - @McontDC) )
					END

					ELSE
					BEGIN
						SET @OU = ''
					END

			END

		INSERT INTO @res ([Cont],[Nome], [OU], [DistinguishedName]) 
		VALUES (@Cont,@Nome,@Text,@Text)

	END
	--Deleta o primeiro registro que ficou com o nome do usuário
	DELETE FROM @res WHERE [OU] = @Nome

	
	--Transforma a tabela em uma lista
		--Criar o dominio
		DECLARE db_for CURSOR FOR

			SELECT OU FROM @res 
			 WHERE OU LIKE 'br' 
				OR OU LIKE 'com' 
				OR OU LIKE 'contoso' 
			  ORDER BY Cont 

		OPEN db_for 
		FETCH NEXT FROM db_for INTO @OU

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @Dir = @Dir +'.'+ @OU
			FETCH NEXT FROM db_for INTO @OU
		END

		CLOSE db_for
		DEALLOCATE db_for

		--Retorna o total de Caracteres
		SET @Mcont = (SELECT LEN(@Dir))
		SET @Dir = RIGHT(@Dir, @Mcont - 1)

		--Cria a raiz
		DECLARE db_for CURSOR FOR

			SELECT OU FROM @res 
			 WHERE OU NOT LIKE 'br' 
			   AND OU NOT LIKE 'com' 
			   AND OU NOT LIKE 'contoso' 
			  ORDER BY Cont DESC

		OPEN db_for 
		FETCH NEXT FROM db_for INTO @OU



		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @Dir = @Dir +'/'+ @OU
			FETCH NEXT FROM db_for INTO @OU
		END

		CLOSE db_for
		DEALLOCATE db_for

--Separa último pasta
SELECT TOP 1  @OU = OU, @Nome = Nome 
  FROM @res 
   WHERE OU NOT LIKE 'br' 
	 AND OU NOT LIKE 'com' 
	 AND OU NOT LIKE 'contoso' 
ORDER BY Cont 

--Apaga a tabelas
DELETE FROM @res

--Registra uma linha com todas as informções 
INSERT INTO @res ([Nome],[OU], [DistinguishedName]) 
VALUES (@Nome, @OU ,@Dir )

--SELECT * FROM #TBOU

RETURN;
END
GO


