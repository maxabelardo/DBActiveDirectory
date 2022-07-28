

/**/
CREATE VIEW [Rotineira].[DesempenhoMsDBcrescimentoRelAnalitico]
as
SELECT A.[Servidor]
     , A.BD AS 'Total de BD.'
     , CASE 
	    WHEN B.CCP IS NULL THEN 0 
		 ELSE B.CCP
	   END AS 'BD. crescimento positivo'
     , CASE 
	    WHEN C.CCN IS NULL THEN 0 
		 ELSE C.CCN
	   END AS 'BD. crescimento negativo'
     , CASE 
	    WHEN B.CCP IS NULL AND C.CCN IS NULL THEN A.BD  
		WHEN B.CCP IS NOT NULL AND C.CCN IS NULL THEN A.BD - B.CCP
		WHEN B.CCP IS NULL AND C.CCN IS NOT NULL THEN A.BD - C.CCN
		WHEN B.CCP IS NOT NULL AND C.CCN IS NOT NULL THEN A.BD - (B.CCP + C.CCN)
	   END AS 'Sem crescimento'	 
	 , D.Total AS 'Volume Atual'
FROM (SELECT [Servidor], COUNT([BasedeDados]) AS 'BD'
             FROM [SGBD].[SGBDEstDB]
			  WHERE [BasedeDados] <> 'master'
			    AND [BasedeDados] <> 'model'
				AND [BasedeDados] <> 'msdb'
				AND [BasedeDados] <> 'tempdb'
              GROUP BY [Servidor] ) AS A 
LEFT JOIN (SELECT DBC.[Servidor], COUNT(DBC.[BasedeDados]) 'CCP'
			FROM (SELECT DISTINCT [Servidor],[BasedeDados] FROM [Rotineira].[DesempenhoDBcrescimentoDiv] WHERE [ValorDiferencia] > 0) AS DBC
			 GROUP BY DBC.[Servidor] ) AS B ON B.Servidor = A.[Servidor]
LEFT JOIN (SELECT DBC.[Servidor], COUNT(DBC.[BasedeDados])'CCN'
			FROM (SELECT DISTINCT [Servidor],[BasedeDados] FROM [Rotineira].[DesempenhoDBcrescimentoDiv] WHERE [ValorDiferencia] < 0) AS DBC
			 GROUP BY DBC.[Servidor] ) AS C ON C.Servidor = A.[Servidor]
LEFT JOIN (SELECT [Servidor], SUM([SizeMB]) AS 'Total'
            FROM [SGBD].[SGBDEstDB]
             GROUP BY [Servidor]) AS D ON D.Servidor = A.[Servidor]


