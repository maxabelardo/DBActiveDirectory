


CREATE VIEW [Rotineira].[DesempenhoMyDBcrescimentoChAnaliticoBSZ]
AS
SELECT DISTINCT
       A.[Servidor]
	  ,[BasedeDados]
      ,[ValorDiferencia]
      ,[Periodo]      
  FROM [Rotineira].[DesempenhoDBcrescimentoDiv] AS A
WHERE A.[Servidor] LIKE '%mysql'
  AND [ValorDiferencia] <> 0 

