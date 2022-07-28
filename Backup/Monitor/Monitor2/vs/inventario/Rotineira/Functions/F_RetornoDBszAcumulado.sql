




CREATE FUNCTION [Rotineira].[F_RetornoDBszAcumulado]()
RETURNS @table TABLE(  
         idsgbd int
       , srv varchar(30)
	   , mbsize real
	   , monthN int
	   , monthC char(20))
AS
BEGIN
	DECLARE @cont int 
	DECLARE @x int 
	DECLARE @Valor REAL

	SET @cont = 1
	SET @x = MONTH(DATEADD(MONTH, - 1, GETDATE())) 

		WHILE @cont <= @x 
		BEGIN


			INSERT INTO @table (idsgbd,srv, mbsize, monthN, monthC)
					SELECT
					        SG.idSGBD
						 ,  UPPER(SG.[Servidor])
						 , CASE 
								WHEN ROUND(SUM(SZ.db_size/1024), 2) IS NULL THEN 0 
								ELSE ROUND(SUM(SZ.db_size)/1024, 2) 
							END AS 'SizeMB'
						 , @cont
						 , CASE @cont 
								WHEN 1 THEN 'Janeiro' 
								WHEN 2 THEN 'Fevereiro' 
								WHEN 3 THEN 'Março' 
								WHEN 4 THEN 'Abril' 
								WHEN 5 THEN 'Maio' 
								WHEN 6 THEN 'Junho' 
								WHEN 7 THEN 'Julho' 
								WHEN 8 THEN 'Agosto' 
								WHEN 9 THEN 'Setembro' 
								WHEN 10 THEN 'Outubro' 
								WHEN 11 THEN 'Novembro' 
								WHEN 12 THEN 'Dezembro' 
							END AS Mes
					FROM [SGBD].[SGBDDatabases] AS DB 
					INNER JOIN [SGBD].[SGBDEst] AS SG ON SG.[idSGBD] = DB.idSGBD 
					LEFT JOIN (SELECT [idSGBD], [idDatabases], MAX([DataTimer]) AS 'DataTimer'
								FROM [SGBD].[MtDbSize]
								WHERE [DataTimer] >= [dbo].[F_HoraDiaNowZero]([dbo].[F_UltimmoDiaMesDT](CAST(CAST(YEAR(GETDATE()) AS CHAR(4))+ '-' + CASE WHEN @cont > 9 THEN CAST(@cont AS CHAR(2)) ELSE '0' + CAST(@cont AS CHAR(1)) END + '-' + '01 00:00:00' AS datetime))) 
								  AND [DataTimer] <= [dbo].[F_HoraDiaNow24]([dbo].[F_UltimmoDiaMesDT](CAST(CAST(YEAR(GETDATE()) AS CHAR(4))+ '-' + CASE WHEN @cont > 9 THEN CAST(@cont AS CHAR(2)) ELSE '0' + CAST(@cont AS CHAR(1)) END + '-' + '01 00:00:00' AS datetime)))
								GROUP BY [idSGBD], [idDatabases]) AS ST ON ST.idSGBD = DB.idSGBD AND ST.idDatabases = DB.idDatabases 
					LEFT JOIN [SGBD].[MtDbSize] AS SZ ON SZ.idSGBD = DB.idSGBD AND SZ.idDatabases = DB.idDatabases AND SZ.DataTimer = ST.DataTimer
					--WHERE [SGBD] LIKE 'MSSQLServer%'
					GROUP BY SG.idSGBD, SG.[Servidor]
					ORDER BY SG.[Servidor]


			SET @cont = @cont + 1 

		END

	SET @cont = 3
	SELECT @Valor = CASE 
						WHEN ROUND(SUM(SZ.db_size/1024), 2) IS NULL THEN 0 
						ELSE ROUND(SUM(SZ.db_size)/1024, 2) 
					END 
	FROM [SGBD].[SGBDDatabases] AS DB 
	INNER JOIN [SGBD].[SGBDEst] AS SG ON SG.[idSGBD] = DB.idSGBD 
	LEFT JOIN (SELECT [idSGBD], [idDatabases], MAX([DataTimer]) AS 'DataTimer'
			FROM [SGBD].[MtDbSize]
			WHERE [idSGBD] = 83
				AND [DataTimer] >= '2019-03-28 00:00:00' 
				AND [DataTimer] <= '2019-03-29 00:00:00' 
			GROUP BY [idSGBD], [idDatabases]) AS ST ON ST.idSGBD = DB.idSGBD AND ST.idDatabases = DB.idDatabases 
	LEFT JOIN [SGBD].[MtDbSize] AS SZ ON SZ.idSGBD = DB.idSGBD AND SZ.idDatabases = DB.idDatabases AND SZ.DataTimer = ST.DataTimer
	WHERE SG.idSGBD = 83
	GROUP BY SG.idSGBD, SG.[Servidor]
	ORDER BY SG.[Servidor]

	UPDATE @table 
	    SET mbsize = @Valor
	WHERE idsgbd = 83 
	  AND monthN = 3


	RETURN
END
