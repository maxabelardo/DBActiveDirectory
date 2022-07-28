/**/
CREATE VIEW dbo.SRVsgbd
as
SELECT IdServer 
      ,[Servidor]
	  ,CASE
	    WHEN ASCII(RIGHT(LEFT([Local],4),1)) = 45 THEN LEFT([Local],2)
		WHEN [Local] = 'Data Center' THEN 'DF'
		ELSE LEFT([Local],2)
	   END AS 'UF'
     , CASE 
	    WHEN LEFT([Local],2) = 'AC' THEN 'Acre'
		WHEN LEFT([Local],2) = 'AL' THEN 'Alagoas'  
		WHEN LEFT([Local],2) = 'AM' THEN 'Amazonas'
		WHEN LEFT([Local],2) = 'AP' THEN 'Amapá'
		WHEN LEFT([Local],2) = 'BA' THEN 'Bahia'
		WHEN LEFT([Local],2) = 'CE' THEN 'Ceará'
		WHEN LEFT([Local],2) = 'Da' THEN 'Distrito Federal'		
		WHEN LEFT([Local],2) = 'ES' THEN 'Espírito Santo'
		WHEN LEFT([Local],2) = 'GO' THEN 'Goiás'
		WHEN LEFT([Local],2) = 'MA' THEN 'Maranhão'
		WHEN LEFT([Local],2) = 'MG' THEN 'Minas Gerais'
		WHEN LEFT([Local],2) = 'MS' THEN 'Mato Grosso do Sul'
		WHEN LEFT([Local],2) = 'MT' THEN 'Mato Grosso'
		WHEN LEFT([Local],2) = 'PA' THEN 'Pará'
		WHEN LEFT([Local],2) = 'PB' THEN 'Paraíba'
		WHEN LEFT([Local],2) = 'PE' THEN 'Pernambuco'
		WHEN LEFT([Local],2) = 'PI' THEN 'Piauí'
		WHEN LEFT([Local],2) = 'PR' THEN 'Paraná'
		WHEN LEFT([Local],2) = 'RJ' THEN 'Rio de Janeiro'
		WHEN LEFT([Local],2) = 'RN' THEN 'Rio Grande do Norte'
		WHEN LEFT([Local],2) = 'RO' THEN 'Rondônia'
		WHEN LEFT([Local],2) = 'RR' THEN 'Roraima'
		WHEN LEFT([Local],2) = 'RS' THEN 'Rio Grande do Sul'
		WHEN LEFT([Local],2) = 'SC' THEN 'Santa Catarina'
		WHEN LEFT([Local],2) = 'SE' THEN 'Sergipe'
		WHEN LEFT([Local],2) = 'SP' THEN 'São Paulo'
		WHEN LEFT([Local],2) = 'TO' THEN 'Tocantins'
		ELSE 'Distrito Federal'
	   END AS 'Estado'
      ,CASE
	    WHEN ASCII(RIGHT(LEFT([Local],4),1)) = 45 THEN 'RM'
		WHEN [Local] = 'Data Center' AND RIGHT(RTRIM([Servidor]),3) = '\RM' THEN 'RM'
		ELSE 'GERAL'
	   END AS 'Tipo'
  FROM [dbo].[Servidores]
GO

