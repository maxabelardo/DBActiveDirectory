/************************************************************************************************
Este script é o banco de dados pronto para receber os dados do Active Directory.
O que contem o script:
	Criação da database
	Criação das funções	
	Criação das tabelas
	Criação das Views
	Criação da Storage procedure.

*************************************************************************************************/
USE [DBActiveDirectory]
GO
/****** Object:  User [usr_DBActiveDirectory]    Script Date: 14/03/2022 13:44:12 ******/
CREATE USER [usr_DBActiveDirectory] FOR LOGIN [usr_DBActiveDirectory] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [usrReportDBActiveDirectory]    Script Date: 14/03/2022 13:44:12 ******/
CREATE USER [usrReportDBActiveDirectory] FOR LOGIN [usrReportDBActiveDirectory] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [usr_DBActiveDirectory]
GO
ALTER ROLE [db_datareader] ADD MEMBER [usrReportDBActiveDirectory]
GO
/****** Object:  Schema [AD]    Script Date: 14/03/2022 13:44:12 ******/
CREATE SCHEMA [AD]
GO
/****** Object:  Schema [Report]    Script Date: 14/03/2022 13:44:12 ******/
CREATE SCHEMA [Report]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_GroupMember]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* Função [dbo].[FN_GroupMember]() 
Esta função é usada para retornar a uma tabela com o grupo e os usuários pertencentes a este grupo.
*/
CREATE FUNCTION [dbo].[FN_GroupMember]()
Returns @res TABLE ([Grupo] Nvarchar(max) NULL,[Tipo] Nvarchar(10) NULL,[SID] Nvarchar(max) NULL, [Member] Nvarchar(max) NULL,[SamAccountName] Nvarchar(max) NULL )
AS
BEGIN
--Variáveis 
DECLARE @SID Nvarchar(max)      -- ID do grupo
DECLARE @Name Nvarchar(max)     -- Nome do grupo
DECLARE @Member Nvarchar(max)   -- Lista dos usuários do grupo porém dentro da extrutura do AD.

--Loop 
DECLARE db_for CURSOR FOR
	-- Lista todos os grupos com mais de um menbro.
	SELECT  [SID],[Name],[Member]
	  FROM [AD].[STGADGroup] 
		WHERE LEN([Member]) > 0

OPEN db_for 
FETCH NEXT FROM db_for INTO @SID, @Name, @Member
-- Quanto a variável for igual a 0 o loop continuara. 
WHILE @@FETCH_STATUS = 0
BEGIN

-- O insert será feito na tabela temporaria criada em tempo de execução da função.
INSERT INTO @res
	SELECT @Name AS 'Group'
	     , CASE 
			WHEN U.SID IS NOT NULL THEN 'Usuário'
			WHEN G.SID IS NOT NULL THEN 'Grupo'
			WHEN C.[Name] IS NOT NULL THEN 'Contato'
			WHEN (U.SID IS NULL) AND (G.SID IS NULL) THEN ''
		   END AS 'Tipo'
	     , CASE 
			WHEN U.SID IS NOT NULL THEN U.SID
			WHEN G.SID IS NOT NULL THEN G.SID
			WHEN (U.SID IS NULL) AND (G.SID IS NULL) THEN ''
		   END AS 'SID'
	     , CASE 
			WHEN U.SID IS NOT NULL THEN U.Name
			WHEN G.SID IS NOT NULL THEN G.Name
			WHEN C.[Name] IS NOT NULL THEN C.Name
			WHEN (U.SID IS NULL) AND (G.SID IS NULL) THEN M.[Member]
		   END AS 'Member'
	     , CASE 
			WHEN U.SID IS NOT NULL THEN U.[SamAccountName]
			WHEN G.SID IS NOT NULL THEN G.[SamAccountName]
			WHEN C.[Name] IS NOT NULL THEN C.[DisplayName]
			WHEN (U.SID IS NULL) AND (G.SID IS NULL) THEN ''
		   END AS 'SamAccountName'	
	FROM [dbo].[FN_ReturnMember] (@Member, @Name) AS M  -- Esta linha é uma funão que separa os usuários.
	LEFT JOIN [AD].[STGADUser] AS U ON U.[Name] = M.[Member]
	LEFT JOIN [AD].[STGADGroup] AS G ON G.[Name] =  M.[Member]
	LEFT JOIN [AD].[STGADcontact] AS C ON C.[Name] = M.[Member]

	FETCH NEXT FROM db_for INTO  @SID, @Name, @Member
END

CLOSE db_for
DEALLOCATE db_for

RETURN;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[FN_OrganizationalUnitMember]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* Função [dbo].[FN_OrganizationalUnitMember]() 
Esta função é usada para retornar a uma tabela com a OU e os usuários pretencente a ele.
*/
CREATE FUNCTION [dbo].[FN_OrganizationalUnitMember]()
Returns @res TABLE ([OUName] Nvarchar(max) NULL, [OU] Nvarchar(max) NULL,[Tipo] Nvarchar(20) NULL,[SID] Nvarchar(max) NULL, [Member] Nvarchar(max) NULL,[SamAccountName] Nvarchar(max) NULL )
AS
BEGIN
--Variáveis
DECLARE @SID Nvarchar(max)                -- ID da OU
DECLARE @Name Nvarchar(max)               -- Nome da OU
DECLARE @DistinguishedName Nvarchar(max)  -- informações da conta do usuário
DECLARE @SamAccountName Nvarchar(max)     -- Login

--Loop
DECLARE db_for CURSOR FOR
	-- Retorna a lista de usuário.
	SELECT  [SID],[Name],[DistinguishedName],[SamAccountName]
	  FROM  [AD].[STGADUser]
		WHERE LEN(DistinguishedName) > 0

OPEN db_for 
FETCH NEXT FROM db_for INTO @SID, @Name, @DistinguishedName, @SamAccountName

WHILE @@FETCH_STATUS = 0
BEGIN

	INSERT INTO @res
		SELECT M.OU
		     , M.[DistinguishedName]
			 , 'organizationalUnit'
			 , @SID
			 , @Name
			 , @SamAccountName
		FROM [dbo].[FN_ReturnOrganizationalUnit] (@Name,@DistinguishedName) AS M 
		-- Função que separa os dados do campo DistinguishedName

	FETCH NEXT FROM db_for INTO  @SID, @Name, @DistinguishedName, @SamAccountName
END

CLOSE db_for
DEALLOCATE db_for

RETURN;
END;

GO

/****** Object:  UserDefinedFunction [dbo].[FN_ReturnMember]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FN_ReturnMember] (@Member Nvarchar(max), @Grupo Nvarchar(max))
Returns @res TABLE ([Grupo] Nvarchar(max) NULL,[Member] Nvarchar(max) NULL)
AS
BEGIN
--DECLARE @Member Nvarchar(max)
DECLARE @TX00 Nvarchar(max)
DECLARE @Mcont INT
DECLARE @McontVirgula INT
DECLARE @McontCN INT
DECLARE @Nome Nvarchar(max)


--CREATE TABLE #TBMember ([Member] Nvarchar(max) NULL)


--SET @Member ='CN=Vagner Palmeira Rosa,OU=Todos,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Eunice Armani Porto,OU=Todos,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Israel Flores Pujol,OU=Todos,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Isabel Soares Martins Ostroski,OU=Todos,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Isaac Luiz Ribeiro Oselame,OU=Todos,OU=Usuarios,OU=SBPA,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Andre Damas,OU=Bloqueados,OU=Usuarios,OU=SBPA,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Anelise Rambo Guardiola,OU=Todos,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Valter de Oliveira Maluf,OU=Todos,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Gilberto Antonio Madeira Peres,OU=Todos,OU=Usuarios,OU=SBPA,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Debora dos Santos Freitas,OU=Todos,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Rodrigo Cardoso Moreira Borges,OU=Todos,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Maria Kazumi Mihara Matsuda,OU=Todos,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Marcia Aparecida Rodrigues,OU=Todos,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Paulo Cesar Ribas de Oliveira,OU=Todos,OU=Usuarios,OU=SBPA,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Marilia Cristina Silveira de Souza,OU=Todos,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Daiana Ribeiro Blaskowski,OU=Todos,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Rodolfo Estacio Costa,OU=Todos,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Renato Machado,OU=Todos,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Sandra Mara Coelho Maciel,OU=Todos,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Fabiano dos Santos Fernandes,OU=Bloqueados,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Walysson Harmata,OU=Bloqueados,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Cleo Marcus Garcia,OU=Bloqueados,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Ana Maria Bringhenti da Silva,OU=Todos,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Marcia Regina Romao,OU=Todos,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Amaury Costa Ferreira,OU=Todos,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Janaina da Silva Barbosa,OU=Todos,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Luiz Claudio Nunes Martinez,OU=Bloqueados,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Marilu Barcelos de Oliveira,OU=Todos,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Tatiana de Boni Petrocchi,OU=Todos,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Thiago Guerra de Gusmao,OU=Todos,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Elton Bitencourt,OU=Todos,OU=Usuarios,OU=SRSU,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Adriana Schaker da Silva,OU=Bloqueados,OU=Usuarios,OU=SBPA,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Joao Carlos Coelho,OU=Bloqueados,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Gerson Rouber de Melo,OU=Todos,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Ivan Orsi,OU=Todos,OU=Usuarios,OU=SBNF,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Jose Eduardo Severo Guimaraes,OU=Todos,OU=Usuarios,OU=SBPA,OU=Localidades,DC=infraero,DC=gov,DC=br CN=Carla Rossana Schiefferdecker,OU=Bloqueados,OU=Usuarios,OU=SBFL,OU=Localidades,DC=infraero,DC=gov,DC=br'

	WHILE (SELECT LEN(@Member)) > 1
	BEGIN
		SET @Mcont = (SELECT LEN(@Member))

		SET @McontCN = CHARINDEX('CN=', @Member)
		SET @McontCN = @McontCN + 2

		--Remover "CN="
		SET @TX00 = RIGHT(@Member, @Mcont - @McontCN)

		--Localizar a possição da virgula
		SET @McontVirgula = CHARINDEX(',', @TX00)

		SET @Nome = LEFT(@TX00, @McontVirgula - 1)
				
			-- Verifica se existe mais algume menbro no grupo
			IF (SELECT CHARINDEX('CN=', @TX00) ) > 0
			BEGIN 
				SET @Mcont = (SELECT LEN(@TX00)) 
				SET @McontCN = CHARINDEX('CN=', @TX00)
				SET @McontCN = @McontCN - 1

				SET @Member = RIGHT(@TX00,( @Mcont - @McontCN) )
			END 
			ELSE
			BEGIN
				SET @Member = ''
			END

		INSERT INTO @res ([Member],[Grupo] ) 
		VALUES (@Nome,@Grupo)

	END
RETURN;
END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_ReturnOrganizationalUnit]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FN_ReturnOrganizationalUnit] (@Nome Nvarchar(max),@OU Nvarchar(max))
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
SET @OU ='CN=Sebastião Ferreira da Silva,OU=TELEFONIA,OU=INFRAESTRUTURA,OU=PRODUCAO,OU=Admins,OU=SEDE,DC=infraero,DC=gov,DC=br'
--SET @OU ='OU=SEDE,DC=infraero,DC=gov,DC=br'
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
				OR OU LIKE 'gov' 
				OR OU LIKE 'infraero' 
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
			   AND OU NOT LIKE 'gov' 
			   AND OU NOT LIKE 'infraero' 
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
	 AND OU NOT LIKE 'gov' 
	 AND OU NOT LIKE 'infraero' 
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
/****** Object:  Table [AD].[ADUserAccountControl]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD].[ADUserAccountControl](
	[PropertyFlag] [nvarchar](255) NULL,
	[ValueInHexadecimal] [nvarchar](255) NULL,
	[ValueInDecimal] [float] NULL,
	[StatusAccount] [nvarchar](max) NULL,
	[Statusdescription] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [AD].[STGADUser]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD].[STGADUser](
	[idSTGADUser] [int] IDENTITY(1,1) NOT NULL,
	[SID] [varchar](100) NULL,
	[Name] [varchar](100) NULL,
	[DisplayName] [varchar](100) NULL,
	[SamAccountName] [varchar](100) NULL,
	[mail] [varchar](100) NULL,
	[Title] [varchar](max) NULL,
	[Department] [varchar](100) NULL,
	[Description] [varchar](max) NULL,
	[employeeType] [varchar](30) NULL,
	[Company] [varchar](max) NULL,
	[Office] [varchar](max) NULL,
	[City] [varchar](max) NULL,
	[DistinguishedName] [nvarchar](max) NULL,
	[MemberOf] [nvarchar](max) NULL,
	[createTimeStamp] [datetime] NULL,
	[Deleted] [datetime] NULL,
	[Modified] [datetime] NULL,
	[PasswordLastSet] [datetime] NULL,
	[AccountExpirationDate] [datetime] NULL,
	[msExchWhenMailboxCreated] [datetime] NULL,
	[LastLogonDate] [datetime] NULL,
	[EmailAddress] [varchar](200) NULL,
	[MobilePhone] [varchar](100) NULL,
	[msExchRemoteRecipientType] [int] NULL,
	[ObjectClass] [varchar](30) NULL,
	[PasswordExpired] [bit] NULL,
	[PasswordNeverExpires] [bit] NULL,
	[PasswordNotRequired] [bit] NULL,
	[Enabled] [bit] NULL,
	[LockedOut] [bit] NULL,
	[CannotChangePassword] [bit] NULL,
	[userAccountControl] [int] NULL,
	[LastUpdateEtl] [datetime] NULL,
 CONSTRAINT [PK_idSTGADUser] PRIMARY KEY CLUSTERED 
(
	[idSTGADUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [AD].[VW_User]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [AD].[VW_User]
as
SELECT [idSTGADUser]
      ,[SID]
      ,[Name] 
      ,[DisplayName] 
      ,[SamAccountName]
      ,[mail]
      ,[Title]
      ,[Department]
      ,[Description]
      ,[employeeType]
      ,[Company]
      ,[Office]
      ,[City]
      ,[DistinguishedName]
      ,[MemberOf]
      ,[createTimeStamp]
      ,[Deleted]
      ,[Modified]
      ,[PasswordLastSet]
      ,[AccountExpirationDate]
      ,[msExchWhenMailboxCreated]
      ,[LastLogonDate]
      ,[EmailAddress]
      ,[MobilePhone]
      ,[msExchRemoteRecipientType]
      ,[ObjectClass]
      ,[PasswordExpired]
      ,[PasswordNeverExpires]
      ,[PasswordNotRequired]
      ,[Enabled]
      ,[LockedOut]
      ,[CannotChangePassword]
      ,[userAccountControl]
	  ,C.[PropertyFlag]
      ,[LastUpdateEtl]
  FROM [AD].[STGADUser] AS U
  LEFT JOIN [AD].[ADUserAccountControl] AS C ON C.[ValueInDecimal] = [userAccountControl]

GO
/****** Object:  View [AD].[VW_AccountEnable]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [AD].[VW_AccountEnable] 
as
SELECT [SamAccountName]
      ,[Name]
	  ,[Title]
      ,[Department]
      ,[employeeType]
      ,[Company]
      ,[Office]
	  ,[AccountExpirationDate]
  FROM [AD].[STGADUser]
  WHERE [userAccountControl] = 512
GO
/****** Object:  View [AD].[VW_AccountDisabled]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [AD].[VW_AccountDisabled]
AS
SELECT count(*) AS 'Valor'
	 , CONVERT(DATE,[AccountExpirationDate], 111) AS 'Data'
  FROM [AD].[STGADUser]
  WHERE [AccountExpirationDate] >= GETDATE() AND [AccountExpirationDate] <= DATEADD(DAY,60,GETDATE())
    AND [userAccountControl] = 512
GROUP BY CONVERT(DATE,[AccountExpirationDate], 111) 
GO
/****** Object:  View [Report].[VW_AccountEnableExpirationDate]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Report].[VW_AccountEnableExpirationDate] 
as
SELECT [SID]
      ,[SamAccountName]
      ,[Name]
	  ,[Title]
      ,[Department]
      ,[employeeType]
      ,[Company]
      ,[Office]
	  ,[AccountExpirationDate]
  FROM [AD].[STGADUser]
  WHERE [AccountExpirationDate] >= DATEADD(DAY,-60,GETDATE())  AND [AccountExpirationDate] <= GETDATE() 
	AND [userAccountControl] = 512
GO
/****** Object:  View [Report].[VW_AccountCedido]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Report].[VW_AccountCedido]
as
SELECT [SID]
      ,[Name]
      ,[DisplayName]
      ,[SamAccountName]
	  ,[userAccountControl]
  FROM [AD].[STGADUser]
  WHERE [Department] = 'CEDIDO'
GO
/****** Object:  Table [AD].[STGADOrganizationalUnitMember]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD].[STGADOrganizationalUnitMember](
	[OU] [nvarchar](max) NULL,
	[DistinguishedName] [nvarchar](max) NULL,
	[Tipo] [nvarchar](20) NULL,
	[SID] [nvarchar](max) NULL,
	[Member] [nvarchar](max) NULL,
	[SamAccountName] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [Report].[VW_AccountDisabledOutsideBloqueados]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Report].[VW_AccountDisabledOutsideBloqueados] 
AS
SELECT U.[SID]
      ,U.[SamAccountName]
      ,[Name]
	  ,O.OU
	  ,O.[DistinguishedName]
	  ,[Title]
      ,[Department]
      ,[employeeType]
      ,[Company]
      ,[Office]
	  ,[AccountExpirationDate]
  FROM [AD].[STGADUser] AS U 
  INNER JOIN [AD].[STGADOrganizationalUnitMember] AS O ON O.SID = U.SID
  WHERE U.[userAccountControl] = 514
    AND O.OU NOT LIKE 'Bloqueados'
GO
/****** Object:  View [Report].[VW_AccountEnableWillExpiratioDate]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Report].[VW_AccountEnableWillExpiratioDate] 
as
SELECT [SID]
      ,[SamAccountName]
      ,[Name]
	  ,[Title]
      ,[Department]
      ,[employeeType]
      ,[Company]
      ,[Office]
	  ,[AccountExpirationDate]
  FROM [AD].[STGADUser]
  WHERE [AccountExpirationDate] >= GETDATE() AND [AccountExpirationDate] <=  DATEADD(DAY,+60,GETDATE())
	AND [userAccountControl] = 512
GO
/****** Object:  View [Report].[VW_AccountCasa]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Report].[VW_AccountCasa] 
as
SELECT SID
      ,[SamAccountName]
      ,[Name]
	  ,[Title]
      ,[Department]
      ,[employeeType]
      ,[Company]
      ,[Office]
	  ,[AccountExpirationDate]
  FROM [AD].[STGADUser]
  WHERE [userAccountControl] = 512  
    AND [SamAccountName] LIKE 'i%'
GO
/****** Object:  View [Report].[VW_AccountTerceiro]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [Report].[VW_AccountTerceiro] 
as
SELECT SID
      ,[SamAccountName]
      ,[Name]
	  ,[Title]
      ,[Department]
      ,[employeeType]
      ,[Company]
      ,[Office]
	  ,[AccountExpirationDate]
  FROM [AD].[STGADUser]
  WHERE [userAccountControl] = 512  
    AND [SamAccountName] LIKE 't%'
GO
/****** Object:  Table [AD].[STGADComputer]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD].[STGADComputer](
	[idSTGADComputer] [int] IDENTITY(1,1) NOT NULL,
	[SID] [varchar](100) NULL,
	[Name] [varchar](max) NULL,
	[DisplayName] [varchar](max) NULL,
	[SamAccountName] [varchar](max) NULL,
	[Description] [varchar](max) NULL,
	[ObjectClass] [varchar](30) NULL,
	[PrimaryGroup] [nvarchar](max) NULL,
	[MemberOf] [nvarchar](max) NULL,
	[OperatingSystem] [varchar](max) NULL,
	[OperatingSystemHotfix] [varchar](max) NULL,
	[OperatingSystemServicePack] [varchar](max) NULL,
	[OperatingSystemVersion] [varchar](max) NULL,
	[CanonicalName] [varchar](max) NULL,
	[Enabled] [bit] NULL,
	[IPv4Address] [varchar](max) NULL,
	[Created] [datetime] NULL,
	[Deleted] [datetime] NULL,
	[Modified] [datetime] NULL,
	[LastLogonDate] [datetime] NULL,
	[logonCount] [int] NULL,
	[PasswordExpired] [bit] NULL,
	[PasswordLastSet] [datetime] NULL,
	[AuthenticationPolicy] [varchar](max) NULL,
	[LastUpdateEtl] [datetime] NULL,
 CONSTRAINT [PK_idSTGADComputer] PRIMARY KEY CLUSTERED 
(
	[idSTGADComputer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [AD].[STGADcontact]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD].[STGADcontact](
	[idSTGADcontact] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NULL,
	[DisplayName] [varchar](100) NULL,
	[mailNickname] [varchar](100) NULL,
	[mail] [varchar](100) NULL,
	[CanonicalName] [varchar](max) NULL,
	[DistinguishedName] [nvarchar](max) NULL,
	[created] [datetime] NULL,
	[Deleted] [datetime] NULL,
	[Modified] [datetime] NULL,
	[LastUpdateEtl] [datetime] NULL,
 CONSTRAINT [PK_idSTGADcontact] PRIMARY KEY CLUSTERED 
(
	[idSTGADcontact] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [AD].[STGADDomainController]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD].[STGADDomainController](
	[idSTGADDomainController] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](max) NULL,
	[HostName] [varchar](max) NULL,
	[IPv4Address] [varchar](max) NULL,
	[OperatingSystem] [varchar](max) NULL,
	[OperatingSystemVersion] [varchar](max) NULL,
	[Site] [varchar](max) NULL,
	[Enabled] [bit] NULL,
	[LastUpdateEtl] [datetime] NULL,
 CONSTRAINT [PK_idSTGADDomainController] PRIMARY KEY CLUSTERED 
(
	[idSTGADDomainController] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [AD].[STGADGPO]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD].[STGADGPO](
	[idSTGADGPO] [int] IDENTITY(1,1) NOT NULL,
	[ID] [varchar](100) NULL,
	[DisplayName] [varchar](max) NULL,
	[DomainName] [varchar](100) NULL,
	[Owner] [varchar](100) NULL,
	[GpoStatus] [varchar](100) NULL,
	[Description] [text] NULL,
	[UserVersion] [varchar](100) NULL,
	[ComputerVersion] [varchar](100) NULL,
	[CreationTime] [datetime] NULL,
	[ModificationTime] [datetime] NULL,
	[LastUpdateEtl] [datetime] NULL,
 CONSTRAINT [PK_idSTGADGPO] PRIMARY KEY CLUSTERED 
(
	[idSTGADGPO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [AD].[STGADGroup]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD].[STGADGroup](
	[idSTGADGroup] [int] IDENTITY(1,1) NOT NULL,
	[SID] [varchar](max) NULL,
	[Name] [varchar](max) NULL,
	[DisplayName] [varchar](max) NULL,
	[SamAccountName] [varchar](max) NULL,
	[Description] [varchar](max) NULL,
	[CanonicalName] [varchar](max) NULL,
	[DistinguishedName] [nvarchar](max) NULL,
	[GroupCategory] [varchar](max) NULL,
	[Member] [nvarchar](max) NULL,
	[MemberOf] [nvarchar](max) NULL,
	[GroupScope] [varchar](30) NULL,
	[ObjectClass] [varchar](30) NULL,
	[ProtectedFromAccidentalDeletion] [bit] NULL,
	[Created] [datetime] NULL,
	[Deleted] [datetime] NULL,
	[Modified] [datetime] NULL,
	[LastUpdateEtl] [datetime] NULL,
 CONSTRAINT [PK_idSTGADGroup] PRIMARY KEY CLUSTERED 
(
	[idSTGADGroup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [AD].[STGADGroupMember]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD].[STGADGroupMember](
	[Grupo] [nvarchar](max) NULL,
	[Tipo] [nvarchar](10) NULL,
	[SID] [nvarchar](max) NULL,
	[Member] [nvarchar](max) NULL,
	[SamAccountName] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [AD].[STGADOrganizationalUnit]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD].[STGADOrganizationalUnit](
	[idSTGADOrganizationalUnit] [int] IDENTITY(1,1) NOT NULL,
	[ObjectGUID] [varchar](100) NULL,
	[Name] [varchar](100) NULL,
	[ObjectClass] [varchar](30) NULL,
	[DistinguishedName] [nvarchar](max) NULL,
	[ManagedBy] [nvarchar](max) NULL,
	[LastUpdateEtl] [datetime] NULL,
 CONSTRAINT [PK_idSTGADOrganizationalUnit] PRIMARY KEY CLUSTERED 
(
	[idSTGADOrganizationalUnit] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [AD].[STGADComputer] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO
ALTER TABLE [AD].[STGADcontact] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO
ALTER TABLE [AD].[STGADDomainController] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO
ALTER TABLE [AD].[STGADGPO] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO
ALTER TABLE [AD].[STGADGroup] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO
ALTER TABLE [AD].[STGADOrganizationalUnit] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO
ALTER TABLE [AD].[STGADUser] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO
/****** Object:  StoredProcedure [dbo].[SP_GroupMember]    Script Date: 14/03/2022 13:44:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_GroupMember]
AS
BEGIN

DECLARE @SID Nvarchar(max)
DECLARE @Name Nvarchar(max)
DECLARE @Member Nvarchar(max)
DECLARE @Cont INT

SET @Cont = 0

CREATE TABLE #res([Grupo] Nvarchar(max) NULL,[Tipo] Nvarchar(10) NULL,[SID] Nvarchar(max) NULL, [Member] Nvarchar(max) NULL,[SamAccountName] Nvarchar(max) NULL )

CREATE TABLE #US ([SID] [varchar](100) NULL,[Name] [varchar](100) NULL,[SamAccountName] [varchar](100) NULL)
CREATE TABLE #GO ([SID] [varchar](max) NULL,[Name] [varchar](max) NULL,[SamAccountName] [varchar](max) NULL)
CREATE TABLE #TC ([Name] [varchar](100) NULL,[DisplayName] [varchar](100) NULL)


INSERT INTO #US
SELECT [SID], [Name], [SamAccountName] FROM [AD].[STGADUser]

INSERT INTO #GO
SELECT [SID], [Name], [SamAccountName] FROM [AD].[STGADGroup]

INSERT INTO #TC
SELECT [Name], [DisplayName] FROM [AD].[STGADcontact]


DECLARE db_for CURSOR FOR

	SELECT  [SID],[Name],[Member]
	  FROM [AD].[STGADGroup] 
		WHERE LEN([Member]) > 0

OPEN db_for 
FETCH NEXT FROM db_for INTO @SID, @Name, @Member

WHILE @@FETCH_STATUS = 0
BEGIN

INSERT INTO #res
	SELECT @Name AS 'Group'
	     , CASE 
			WHEN U.SID IS NOT NULL THEN 'Usuário'
			WHEN G.SID IS NOT NULL THEN 'Grupo'
			WHEN C.[Name] IS NOT NULL THEN 'Contato'
			WHEN (U.SID IS NULL) AND (G.SID IS NULL) THEN ''
		   END AS 'Tipo'
	     , CASE 
			WHEN U.SID IS NOT NULL THEN U.SID
			WHEN G.SID IS NOT NULL THEN G.SID
			WHEN (U.SID IS NULL) AND (G.SID IS NULL) THEN ''
		   END AS 'SID'
	     , CASE 
			WHEN U.SID IS NOT NULL THEN U.Name
			WHEN G.SID IS NOT NULL THEN G.Name
			WHEN C.[Name] IS NOT NULL THEN C.Name
			WHEN (U.SID IS NULL) AND (G.SID IS NULL) THEN M.[Member]
		   END AS 'Member'
	     , CASE 
			WHEN U.SID IS NOT NULL THEN U.[SamAccountName]
			WHEN G.SID IS NOT NULL THEN G.[SamAccountName]
			WHEN C.[Name] IS NOT NULL THEN C.[DisplayName]
			WHEN (U.SID IS NULL) AND (G.SID IS NULL) THEN ''
		   END AS 'SamAccountName'		
	FROM [dbo].[FN_ReturnMember] (@Member, @Name) AS M
	LEFT JOIN #US AS U ON U.[Name] = M.[Member]
	LEFT JOIN #GO AS G ON G.[Name] = M.[Member]
	LEFT JOIN #TC AS C ON C.[Name] = M.[Member]

	SET @Cont = @Cont + 1

	PRINT CAST(@Cont AS CHAR(10))
	
	FETCH NEXT FROM db_for INTO  @SID, @Name, @Member
END

CLOSE db_for
DEALLOCATE db_for

	IF EXISTS
	(
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'AD.STGADGroupMember')
	)
		BEGIN
			DROP TABLE AD.STGADGroupMember
	END;

	SELECT Grupo, Tipo, SID, Member, SamAccountName INTO AD.STGADGroupMember FROM #res

DROP TABLE #res
DROP TABLE #US 
DROP TABLE #GO 
DROP TABLE #TC 

END;
GO
