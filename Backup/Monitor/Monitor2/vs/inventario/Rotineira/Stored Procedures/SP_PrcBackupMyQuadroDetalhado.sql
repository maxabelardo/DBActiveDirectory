




CREATE PROCEDURE [Rotineira].[SP_PrcBackupMyQuadroDetalhado]
AS
	DECLARE @ultimodia  int
	DECLARE @cont       int
	DECLARE @campoCont  varchar(20)
	DECLARE @scritp1    varchar(2000)
	DECLARE @scritp2    varchar(500)
	DECLARE @scritpExec nchar(3000)

	SELECT @ultimodia =  DAY(dbo.F_UltimmoDiaMesDT(GETDATE()))

	SET @cont = 1
	SET @campoCont = '[]'
	SET @scritp1 = ''
	SET @scritp2 = ''

	WHILE @cont <= @ultimodia
	BEGIN

		IF @cont <= 9 
			BEGIN		
				SET @campoCont = '[0' + LTRIM(STR(@cont)) + ']'
			END
			ELSE
			BEGIN
				SET @campoCont = '[' + LTRIM(STR(@cont)) + ']'
			END	



		SET @scritp1 = @scritp1 + ', CASE WHEN ' + @campoCont + ' IS NULL THEN 4 ELSE 4 END AS ' + @campoCont	

		IF @cont < @ultimodia
				SET @scritp2 = @scritp2  + @campoCont + ', '
			ELSE
				SET @scritp2 = @scritp2  + @campoCont 

		SET @cont = @cont + 1

	
	END

		SET @scritpExec = '
		
					IF OBJECT_ID(''[Rotineira].[BackupMySQLQuadroDetalhado]'', ''U'') IS NOT NULL 
						DROP TABLE [Rotineira].[BackupMySQLQuadroDetalhado]
		
		
						    SELECT Servidor
								, BasedeDados'
								+ @scritp1 +
							 'INTO Rotineira.BackupMySQLQuadroDetalhado
							  FROM (SELECT [Servidor]
										  ,[BasedeDados]
										  ,ROUND(SUM([Tamanho]),2) AS ''Tamanho''
										  ,[Dia]
									  FROM [Report].[BackupsMyMonitorMes]
									  GROUP BY [Servidor],[BasedeDados],[Dia]) AS A
							 PIVOT (SUM(A.Tamanho) FOR [Dia] IN('+ @scritp2 +')) AS B
							ORDER BY Servidor, BasedeDados'

		 EXEC sp_executesql @scritpExec







