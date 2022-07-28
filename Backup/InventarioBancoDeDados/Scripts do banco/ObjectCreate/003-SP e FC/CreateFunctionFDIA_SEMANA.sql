/******************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 13/12/2021
Data de alteração: 

Descrição
	A função recebe uma data e retorana um nomero que vai de 1 a 7
	Sendo 1 = Domingo
	      2 = Segunda
		  3 = Terça
		  4 = Quarta
		  5 = Quinta
		  6 = Sexta
		  7 = Sabado

	A função se utiliza de uma função nativa do banco a "DATEPART"

	"DATEPART"- Essa função retorna um inteiro que representa o datepart especificado do argumento date especificado.
	
	O parametro DW seguinifica DIA DA SEMANA.

******************************************************************************************************************/



CREATE FUNCTION [dbo].[FDIA_SEMANA]  (@DATA DATETIME) RETURNS INT  AS
BEGIN
  DECLARE @DIA INT
  SELECT @DIA = (DATEPART(DW,@DATA ))
  RETURN @DIA
END
GO


