
CREATE VIEW [Rotineira].[DesempenhoNetWork]
as
SELECT DISTINCT
       B.HostName
      ,[Componente]
      --,[Tipo]
      ,[Dia]
      ,[Hora]
      ,[Valor]
  FROM [Zabbix].[HostNetWork] AS A
  INNER JOIN [ServerHost].[ServerHost] AS B ON B.idServerHost = A.idServerHost
  WHERE CAST((RIGHT(A.[Dia],4)+'-'+RIGHT(LEFT(A.[Dia],5),2)+'-'+LEFT(A.[Dia],2)+' '+'00:00:00') AS DATETIME) >= DATEADD(DAY,-15,GETDATE())
