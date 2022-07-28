CREATE VIEW [Rotineira].[DesempenhoDBcrescimentoFULL]
as
SELECT DISTINCT 
       A.[Servidor]
      ,A.[BasedeDados]
      ,C.[db_size] AS 'TM. inicio do ano' 
	  ,A.[SizeMB] AS 'TM. atual'
	  ,ROUND((A.[SizeMB] - C.[db_size]),2) AS 'Crescimento acumulado'
      ,A.[SGBD]
  FROM [SGBD].[SGBDDatabasesProd] AS A
  INNER JOIN (SELECT [idDatabases],[idSGBD],MIN([DataTimer]) AS 'DT'
			   FROM [SGBD].[MtDbSize]
				WHERE [DataTimer] >='2018-01-01 00:00:00'
				 GROUP BY [idSGBD],[idDatabases]) AS B ON B.idSGBD = A.idSGBD AND B.idDatabases = A.idDatabases 
 INNER JOIN [SGBD].[MtDbSize] AS C  ON C.idSGBD = B.idSGBD AND C.idDatabases = B.idDatabases AND C.DataTimer = B.DT

