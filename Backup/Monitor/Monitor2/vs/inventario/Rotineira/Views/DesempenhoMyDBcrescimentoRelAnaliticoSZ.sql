
CREATE VIEW [Rotineira].[DesempenhoMyDBcrescimentoRelAnaliticoSZ]
AS

SELECT A.Servidor
     , CASE 
	    WHEN B.Total IS NULL THEN 0
		 ELSE B.Total 
	   END AS 'Total (GB)'
FROM (SELECT [Servidor], COUNT([BasedeDados]) AS 'BD'
             FROM [SGBD].[SGBDEstDB]
			  WHERE [BasedeDados] <> 'mysql'
			    AND [BasedeDados] <> 'model'
				AND [BasedeDados] <> 'msdb'
				AND [BasedeDados] <> 'tempdb'
				AND [SGBD] LIKE '%MySQL%'
              GROUP BY [Servidor] ) AS A 
LEFT JOIN (SELECT [Servidor]/*(,[BasedeDados]*/,ROUND(SUM([ValorDiferencia])/1024,2) AS 'Total'
            FROM [Rotineira].[F_DesempenhoDBcrescimentoDiv] (DATEADD(DAY,-15, GETDATE()))
             WHERE [ValorDiferencia] > 0               
             GROUP BY [Servidor]/*,[BasedeDados]*/) AS B ON B.Servidor = A.[Servidor] 
--WHERE A.[Servidor] NOT LIKE 'SR-DFNTBDP064'

UNION ALL

SELECT 'CRESCIMENTO:' AS 'Servidor'
     , ROUND(SUM(B.Total),2) AS 'Total (GB)'
FROM (SELECT [Servidor], COUNT([BasedeDados]) AS 'BD'
             FROM [SGBD].[SGBDEstDB]
			  WHERE [BasedeDados] <> 'master'
			    AND [BasedeDados] <> 'model'
				AND [BasedeDados] <> 'msdb'
				AND [BasedeDados] <> 'tempdb'
				AND [SGBD] LIKE '%MySQL%'
              GROUP BY [Servidor] ) AS A 
LEFT JOIN (SELECT [Servidor]/*(,[BasedeDados]*/,ROUND(SUM([ValorDiferencia])/1024,2) AS 'Total'
            FROM [Rotineira].[F_DesempenhoDBcrescimentoDiv] (DATEADD(DAY,-15, GETDATE()))
             WHERE [ValorDiferencia] > 0               
             GROUP BY [Servidor]/*,[BasedeDados]*/) AS B ON B.Servidor = A.[Servidor] 
--WHERE A.[Servidor] NOT LIKE 'SR-DFNTBDP064'

UNION ALL

SELECT 'DECRESCIMENTO:' AS 'Servidor'
     , ROUND(SUM(B.Total),2) AS 'Total (GB)'
FROM (SELECT [Servidor], COUNT([BasedeDados]) AS 'BD'
             FROM [SGBD].[SGBDEstDB]
			  WHERE [BasedeDados] <> 'master'
			    AND [BasedeDados] <> 'model'
				AND [BasedeDados] <> 'msdb'
				AND [BasedeDados] <> 'tempdb'
				AND [SGBD] LIKE '%MySQL%'
              GROUP BY [Servidor] ) AS A 
LEFT JOIN (SELECT [Servidor]/*(,[BasedeDados]*/,ROUND(SUM([ValorDiferencia])/1024,2) AS 'Total'
            FROM [Rotineira].[F_DesempenhoDBcrescimentoDiv] (DATEADD(DAY,-15, GETDATE()))
             WHERE [ValorDiferencia] < 0               
             GROUP BY [Servidor]/*,[BasedeDados]*/) AS B ON B.Servidor = A.[Servidor] 
--WHERE A.[Servidor] NOT LIKE 'SR-DFNTBDP064'


UNION ALL 

SELECT 'VOLUME TOTAL:' AS 'Servidor', ROUND(AA.Total - (- BB.Total) ,2) AS 'Total (GB)'
FROM (SELECT  ROUND(SUM(B.Total),2) AS 'Total'
		FROM (SELECT [Servidor], COUNT([BasedeDados]) AS 'BD'
					 FROM [SGBD].[SGBDEstDB]
					  WHERE [BasedeDados] <> 'master'
						AND [BasedeDados] <> 'model'
						AND [BasedeDados] <> 'msdb'
						AND [BasedeDados] <> 'tempdb'
				AND [SGBD] LIKE '%MySQL%'
					  GROUP BY [Servidor] ) AS A 
		LEFT JOIN (SELECT [Servidor]/*(,[BasedeDados]*/,ROUND(SUM([ValorDiferencia])/1024,2) AS 'Total'
					FROM [Rotineira].[F_DesempenhoDBcrescimentoDiv] (DATEADD(DAY,-15, GETDATE()))
					 WHERE [ValorDiferencia] > 0               
					 GROUP BY [Servidor]/*,[BasedeDados]*/) AS B ON B.Servidor = A.[Servidor] 
		--WHERE A.[Servidor] NOT LIKE 'SR-DFNTBDP064'
		) AS AA
		  , (SELECT  ROUND(SUM(B.Total),2) AS 'Total'
		FROM (SELECT [Servidor], COUNT([BasedeDados]) AS 'BD'
					 FROM [SGBD].[SGBDEstDB]
					  WHERE [BasedeDados] <> 'master'
						AND [BasedeDados] <> 'model'
						AND [BasedeDados] <> 'msdb'
						AND [BasedeDados] <> 'tempdb'
				AND [SGBD] LIKE '%MySQL%'
					  GROUP BY [Servidor] ) AS A 
		LEFT JOIN (SELECT [Servidor]/*(,[BasedeDados]*/,ROUND(SUM([ValorDiferencia])/1024,2) AS 'Total'
					FROM [Rotineira].[F_DesempenhoDBcrescimentoDiv] (DATEADD(DAY,-15, GETDATE()))
					 WHERE [ValorDiferencia] < 0               
					 GROUP BY [Servidor]/*,[BasedeDados]*/) AS B ON B.Servidor = A.[Servidor] 
		--WHERE A.[Servidor] NOT LIKE 'SR-DFNTBDP064'
		) BB 
