

CREATE VIEW [Report].[DatabaseSize]
as
SELECT VA.idSGBD
     , VA.idDatabases
	 , VA.DT
	 , CONVERT(CHAR(8), VA.HM, 114) AS 'HM'
	 , VZ.DataTimer
	 , CAST(CAST(VZ.db_size AS REAL) AS DECIMAL(20,2)) AS 'TamanhoMB'
	 , CAST(CAST(VZ.db_size / 1024 AS REAL) AS DECIMAL(20,2)) AS 'TamanhoGM'
	 
FROM (SELECT V.idSGBD, V.idDatabases, V.DT, MAX(CAST(VH.DataTimer AS TIME)) AS 'HM'
		FROM (SELECT idSGBD, idDatabases, MAX(CAST([DataTimer] as DATE)) AS 'DT', MAX(CAST([DataTimer] as time)) AS 'HM'
				FROM [SGBD].[MtDbSize]
				GROUP BY idSGBD, idDatabases, CAST([DataTimer] as DATE)) AS V
		INNER JOIN [SGBD].[MtDbSize] AS VH ON VH.idSGBD = V.idSGBD AND VH.idDatabases = V.idDatabases AND CAST(VH.DataTimer AS DATE) = V.DT
		GROUP BY  V.idSGBD, V.idDatabases, V.DT ) AS VA
INNER JOIN [SGBD].[MtDbSize] AS VZ ON VZ.idSGBD = VA.idSGBD 
       AND VZ.idDatabases = VA.idDatabases 
	   AND CAST(VZ.DataTimer AS DATE) = VA.DT 
	   AND CAST(VZ.DataTimer AS TIME) = VA.HM
INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = VA.idDatabases
