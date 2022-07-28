
CREATE VIEW [Rotineira].[DesempenhoMsDBcrescimentoPanel]
as
SELECT A.SRV AS 'Servidor'
      , A.mbsize AS 'Total anterior (GB)'
      , ROUND(B.Total - A.mbsize,2) AS 'Evulução (GB)'
	  , ROUND(B.Total,2) AS 'Total atual (GB)'
  FROM [Rotineira].[F_RetornoDBszAcumulado] () AS A
  INNER JOIN (SELECT [Servidor] ,ROUND(SUM([SizeMB])/1024,2) AS 'Total'
				FROM [SGBD].[SGBDDatabasesProd] GROUP BY [Servidor]) AS B ON B.Servidor = A.srv
  WHERE (A.SRV NOT LIKE '%mysql%' AND A.SRV NOT LIKE '%postgre%')
    AND A.MONTHN = MONTH(DATEADD(MONTH,-1, GETDATE()))
  --ORDER BY 1
