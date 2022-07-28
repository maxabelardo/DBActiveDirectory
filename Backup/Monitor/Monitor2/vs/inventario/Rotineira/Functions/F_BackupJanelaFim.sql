

CREATE function [Rotineira].[F_BackupJanelaFim](@idSGBD INT, @DATA DATETIME) RETURNS datetime  AS
BEGIN
/*
DECLARE @idSGBD INT
DECLARE @DATA DATETIME
SET @idSGBD = 6
SET @DATA = '2021-11-05 00:00:00'
*/

DECLARE @Convert   datetime

--Tipo de ocorrência
DECLARE @TipoOcorrencia INT


--Se a configuração da janela de backup estiver como diário as configurações de janelas estaram na tabela "SGBDBackupJanela"
--Se caso seja semanal ou mensal vão está na tabela "[SGBDBackupJlDatabase]"

	--Verifica se o tipo de ocorrência
	-- 1 Diário, 2 Semanal e 3 Mensal
	SELECT @TipoOcorrencia = idTipoOcorrencia
		FROM [SGBD].[SGBDBackupJanela]


	--Condicional que ira controla qual o retorno
	IF ( @TipoOcorrencia = 1) -- Backup Diário
	BEGIN 
	--
	SET @Convert = GETDATE()

	END ELSE
	IF ( @TipoOcorrencia = 2 ) --Backup Semanal
	BEGIN
		SELECT @Convert = 
			 CASE
				WHEN JB.[endJanela] < JB.[startJanela]  THEN CONVERT(CHAR(10),DATEADD(DAY,1,@DATA),120)+' '+CONVERT(CHAR(8),JB.[endJanela],14)
				ELSE CONVERT(CHAR(10),DATEADD(DAY,0,@DATA),120)+' '+CONVERT(CHAR(8),JB.[endJanela],14)
				END
		  FROM [SGBD].[SGBDBackupJlDatabase] AS JB
		  INNER JOIN [SGBD].[SGBDBackupJanela] AS J ON J.idSGBDBackupJanela = JB.idSGBDBackupJanela
		  WHERE J.[idSGBD] =  @idSGBD


	END


RETURN @Convert 

END

