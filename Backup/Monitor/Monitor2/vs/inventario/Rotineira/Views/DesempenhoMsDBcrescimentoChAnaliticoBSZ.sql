

CREATE VIEW [Rotineira].[DesempenhoMsDBcrescimentoChAnaliticoBSZ]
AS
SELECT DISTINCT
       A.[Servidor]
	  ,[BasedeDados]
      ,[ValorDiferencia]
      ,[Periodo]      
  FROM [Rotineira].[DesempenhoDBcrescimentoDiv] AS A
WHERE (A.[Servidor] LIKE 'SR-DFNT%' OR A.[Servidor] LIKE 'PIRRO%' OR A.[Servidor] LIKE 'SQL%')
  AND A.[Servidor] NOT LIKE 'SR-DFNTBDP058'
  AND A.[Servidor] NOT LIKE 'SR-DFNTBDP059'
  AND [ValorDiferencia] <> 0 

