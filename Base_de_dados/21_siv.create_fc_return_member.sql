
CREATE FUNCTION [siv].[fc_return_member] (@Member Nvarchar(max), @Grupo Nvarchar(max))
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


