
CREATE VIEW [Rotineira].[DesempenhoDBcrescimento]
as
SELECT B.Servidor	
	  ,B.BasedeDados
      ,[db_size]
	  ,B.SGBD
      ,CONVERT([varchar], C.[DataTimer], 111) AS 'Periodo'
  FROM [SGBD].[MtDbSize] AS C
INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idSGBD = C.idSGBD AND B.[idDatabases] = C.[idDatabases] 
WHERE C.[DataTimer] >= '2018-12-31 23:59:59'--DATEADD(DAY,-1, GETDATE())
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


--ORDER BY B.idSGBD,B.idDatabases, C.[DataTimer]
