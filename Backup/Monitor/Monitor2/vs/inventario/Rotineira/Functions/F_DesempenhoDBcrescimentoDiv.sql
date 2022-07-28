

CREATE FUNCTION [Rotineira].[F_DesempenhoDBcrescimentoDiv](@DataExecucaoDT DATETIME)
RETURNS TABLE
AS
RETURN(
		SELECT B.Servidor	
				,B.BasedeDados
				, CASE 
				WHEN [db_size] IS NULL THEN 0
				ELSE [db_size] END AS 'Tamanho'
				, CASE 
					WHEN B.Servidor = LAG(B.Servidor, 1) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))
					AND B.BasedeDados = LAG(B.BasedeDados, 1) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))		  
					THEN LAG([db_size], 1, null) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))
					ELSE 0
				END AS 'ValorAnterior'
				, CASE 
					WHEN B.Servidor = LAG(B.Servidor, 1) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))
					AND B.BasedeDados = LAG(B.BasedeDados, 1) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))		  
					THEN ROUND([db_size] - LAG([db_size], 1)OVER(ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111)),2) 
					ELSE 0 --ROUND([db_size],2) 
				END AS 'ValorDiferencia'
			,CONVERT([varchar], C.[DataTimer], 111) AS 'Periodo'
			,B.SGBD
			FROM [SGBD].[MtDbSize] AS C
		INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idSGBD = C.idSGBD AND B.[idDatabases] = C.[idDatabases] 
		WHERE C.[DataTimer] >= @DataExecucaoDT
			AND C.[DataTimer] <= GETDATE()
		AND B.Descricao = 'Produção'
		AND (B.BasedeDados <> 'master'
			AND B.BasedeDados <> 'model'
			AND B.BasedeDados <> 'msdb'
			AND B.BasedeDados <> 'tempdb'
			AND B.BasedeDados <> 'postgres'
			AND B.BasedeDados <> 'mysql'
			AND B.BasedeDados <> 'information_schema'
			AND B.BasedeDados <> 'performance_schema'
			AND B.BasedeDados NOT LIKE 'Report%')
		);
