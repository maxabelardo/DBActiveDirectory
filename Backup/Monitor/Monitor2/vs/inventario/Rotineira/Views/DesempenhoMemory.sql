

CREATE VIEW [Rotineira].[DesempenhoMemory]
as
SELECT DISTINCT
       B.HostName
      ,A.[Dia]
      ,A.[Hora]
	  ,ROUND(C.[Valor] /1024,2) AS 'Total memory'
	  ,(ROUND(C.[Valor] /1024,2) - ROUND(A.[Valor] /1024,2)) AS  'User memory'
      ,ROUND(A.[Valor] /1024,2) AS 'Free memory'
	  
	  --, CAST((RIGHT([Dia],4)+'-'+RIGHT(LEFT([Dia],5),2)+'-'+LEFT([Dia],2)+' '+'00:00:00') AS DATETIME)
  FROM [Zabbix].[HostMemory] AS A
  INNER JOIN [ServerHost].[ServerHost] AS B ON B.idServerHost = A.idServerHost
  INNER JOIN [Zabbix].[HostMemory] AS C ON C.idServerHost = A.idServerHost 
         AND C.[Dia] = A.[Dia]
		 AND C.[Componente] = 'Total memory'
  WHERE /*(B.HostName LIKE 'SR-DFNTBDP%'
    OR B.HostName LIKE 'PIRRO%') 
	AND */
	A.[Componente] = 'Free memory'
    AND
	CAST((RIGHT(A.[Dia],4)+'-'+RIGHT(LEFT(A.[Dia],5),2)+'-'+LEFT(A.[Dia],2)+' '+'00:00:00') AS DATETIME) >= DATEADD(DAY,-15,GETDATE())
--ORDER BY B.HostName,A.[Dia],A.[Hora]--, CAST((RIGHT([Dia],4)+'-'+RIGHT(LEFT([Dia],5),2)+'-'+LEFT([Dia],2)+' '+'00:00:00') AS DATETIME)
