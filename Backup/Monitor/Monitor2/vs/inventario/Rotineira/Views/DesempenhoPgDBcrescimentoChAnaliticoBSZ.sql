



CREATE VIEW [Rotineira].[DesempenhoPgDBcrescimentoChAnaliticoBSZ]
AS
SELECT DISTINCT
       A.[Servidor]
	  ,[BasedeDados]
      ,[ValorDiferencia]
      ,[Periodo]      
  FROM [Rotineira].[DesempenhoDBcrescimentoDiv] AS A
WHERE A.[Servidor] LIKE '%postgres%'
  AND [ValorDiferencia] <> 0 

